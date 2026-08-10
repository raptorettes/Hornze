@tool
extends Control
@onready var credits_label : RichTextLabel = %CreditsLabel
@onready var horse : AnimatedSprite2D = %Horse
@export var input_scroll_speed : float = 200.0
@export var auto_scroll_speed : float = 40.0
signal end_reached

var _scroll_position : float = 0.0
var _finished_scrolling : bool = false

func _on_visibility_changed() -> void:
	if visible:
		if Engine.is_editor_hint() or not is_inside_tree():
			return
		_finished_scrolling = true
		await get_tree().process_frame
		await get_tree().process_frame
		_scroll_position = 0.0
		credits_label.position.y = 0
		grab_focus()
		_finished_scrolling = false
		horse.play("run")
		var sb = credits_label.get_v_scroll_bar()
		print("scroll_active: ", credits_label.scroll_active)
		print("max_value: ", sb.max_value, " page: ", sb.page)

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _process(delta : float) -> void:
	if Engine.is_editor_hint() or not visible or _finished_scrolling:
		return
	var input_axis = Input.get_axis("ui_up", "ui_down")
	var scrollbar = credits_label.get_v_scroll_bar()
	var max_scroll = scrollbar.max_value - scrollbar.page

	if max_scroll <= 0:
		return  # not enough content to scroll, or not laid out yet

	if abs(input_axis) > 0.5:
		_scroll_position += input_axis * delta * input_scroll_speed
	else:
		_scroll_position += delta * auto_scroll_speed

	if _scroll_position < 0:
		_scroll_position = 0
	if _scroll_position >= max_scroll:
		_scroll_position = max_scroll
		_finished_scrolling = true

	scrollbar.value = _scroll_position

func _input(event : InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		return  # let these scroll instead of closing
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			end_reached.emit()
