extends Node

@onready var last_screen := get_window().current_screen
@onready var last_position := get_position_in_screen()
@onready var last_mode := get_window().mode


func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		return

	if what == NOTIFICATION_WM_POSITION_CHANGED:
		if not EngineDebugger.is_active():
			return

		var screen := get_window().current_screen
		if screen != last_screen:
			last_screen = screen
			EngineDebugger.send_message("remember_window_placement:screen_changed", [screen])

		var mode := get_window().mode
		if mode != last_mode:
			last_mode = mode
			EngineDebugger.send_message("remember_window_placement:mode_changed", [mode])

		if mode == Window.MODE_WINDOWED:
			var position := get_position_in_screen()
			if position != last_position:
				last_position = position
				EngineDebugger.send_message("remember_window_placement:position_changed", [position])


func get_position_in_screen() -> Vector2i:
	var screen_rect := DisplayServer.screen_get_usable_rect(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	return get_window().position - screen_rect.position
