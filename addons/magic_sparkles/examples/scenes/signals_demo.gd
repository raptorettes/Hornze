extends Control

@onready var _status: Label = $Center/VBox/Status
@onready var _sparkle: MagicSparkleLight = $Center/VBox/Button/MagicSparkleLight
@onready var _cursor: MagicSparkleCursor = $MagicSparkleCursor


func _ready() -> void:
	_sparkle.activated.connect(func(): _status.text = "Sparkles: activated")
	_sparkle.deactivated.connect(func(): _status.text = "Sparkles: deactivated")
	_sparkle.hover_entered.connect(func(): _status.text = "Sparkles: hover entered")
	_sparkle.hover_exited.connect(func(): _status.text = "Sparkles: hover exited")
	_cursor.burst_triggered.connect(func(_pos, _i): _status.text = "Cursor: burst!")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not $Center/VBox/Button.get_global_rect().has_point(event.position):
			_cursor.burst_at_global(event.position, 1.2)
