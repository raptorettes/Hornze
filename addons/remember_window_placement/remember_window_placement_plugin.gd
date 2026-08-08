@tool
extends EditorPlugin

## Change these flags to selectively remember/ignore specific attributes ##
const REMEMBER_SCREEN := true
const REMEMBER_POSITION := true
const REMEMBER_WINDOW_MODE := true
###########################################################################

var debugger_plugin := DebuggerPlugin.new()

enum WindowPlacement {
	TOP_LEFT,
	CENTERED,
	CUSTOM_POS,
	FORCE_MAXIMIZED,
	FORCE_FULLSCREEN,
}


func _enable_plugin() -> void:
	add_autoload_singleton("RememberWindowPlacement", "./remember_window_placement.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("RememberWindowPlacement")


func _enter_tree() -> void:
	add_debugger_plugin(debugger_plugin)


func _exit_tree() -> void:
	remove_debugger_plugin(debugger_plugin)


class DebuggerPlugin extends EditorDebuggerPlugin:
	func _has_capture(capture: String) -> bool:
		return capture == "remember_window_placement"


	func _capture(message: String, data: Array, session_id: int) -> bool:
		match message:
			"remember_window_placement:screen_changed" when REMEMBER_SCREEN:
				if len(data) > 0 and data[0] is int:
					set_setting("run/window_placement/screen", data[0])
					return true
			"remember_window_placement:position_changed" when REMEMBER_POSITION:
				if len(data) > 0 and data[0] is Vector2i:
					set_setting("run/window_placement/rect", WindowPlacement.CUSTOM_POS)
					set_setting("run/window_placement/rect_custom_position", data[0])
					return true
			"remember_window_placement:mode_changed" when REMEMBER_WINDOW_MODE:
				if len(data) > 0 and data[0] is int:
					var window_placement: WindowPlacement = -1
					match data[0]:
						Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN:
							window_placement = WindowPlacement.FORCE_FULLSCREEN
						Window.MODE_MAXIMIZED:
							window_placement = WindowPlacement.FORCE_MAXIMIZED
						Window.MODE_WINDOWED:
							if get_setting("run/window_placement/rect_custom_position"):
								window_placement = WindowPlacement.CUSTOM_POS
					if window_placement != -1:
						set_setting("run/window_placement/rect", window_placement)
					return true

		return false


	func set_setting(name: String, value: Variant) -> void:
		EditorInterface.get_editor_settings().set_setting(name, value)


	func get_setting(name: String) -> Variant:
		return EditorInterface.get_editor_settings().get_setting(name)
