@tool
extends EditorPlugin

# Preload dependency chain before node scripts (parse order).
const _TYPES := preload("res://addons/magic_sparkles/scripts/magic_sparkle_types.gd")
const _BOUNDS := preload("res://addons/magic_sparkles/scripts/magic_sparkle_bounds.gd")
const _ENGINE := preload("res://addons/magic_sparkles/scripts/magic_sparkle_engine.gd")
const _CURSOR_ENGINE := preload("res://addons/magic_sparkles/scripts/magic_sparkle_cursor_engine.gd")
const _BASE := preload("res://addons/magic_sparkles/scripts/magic_sparkle_base.gd")
const LIGHT_SCRIPT: Script = preload("res://addons/magic_sparkles/scripts/magic_sparkle_light.gd")
const BATCH_SCRIPT: Script = preload("res://addons/magic_sparkles/scripts/magic_sparkle_batch.gd")
const CURSOR_SCRIPT: Script = preload("res://addons/magic_sparkles/scripts/magic_sparkle_cursor.gd")
const LIGHT_ICON: Texture2D = preload("res://addons/magic_sparkles/icons/magic_sparkle_light.svg")
const BATCH_ICON: Texture2D = preload("res://addons/magic_sparkles/icons/magic_sparkle_batch.svg")
const CURSOR_ICON: Texture2D = preload("res://addons/magic_sparkles/icons/magic_sparkle_cursor.svg")


func _enter_tree() -> void:
	add_custom_type("MagicSparkleLight", "Control", LIGHT_SCRIPT, LIGHT_ICON)
	add_custom_type("MagicSparkleBatch", "Control", BATCH_SCRIPT, BATCH_ICON)
	add_custom_type("MagicSparkleCursor", "Control", CURSOR_SCRIPT, CURSOR_ICON)


func _exit_tree() -> void:
	remove_custom_type("MagicSparkleLight")
	remove_custom_type("MagicSparkleBatch")
	remove_custom_type("MagicSparkleCursor")
