@tool
## Shared enums and constants for Magic Sparkles host and cursor effects.
class_name MagicSparkleTypes
extends RefCounted

## How particles behave when they reach the host edge.
enum BoundaryMode {
	## Hard clip at host edge; particles wrap to the opposite side.
	CLIP_WRAP,
	## Particles fade outside the host, then respawn inside.
	FADE_EXIT,
}

## When host sparkles are visible and running.
enum ActivationMode {
	## Start on pointer enter, fade on leave.
	ON_HOVER,
	## Run continuously without hover.
	ALWAYS,
}

## Particle movement presets for host sparkles.
enum MotionMode {
	## Twinkling jitter in place. Best for buttons and icons.
	CLASSIC,
	## Smooth float with soft wobble. Ambient UI dust.
	DRIFT,
	## Upward embers with sway. Menus and night scenes.
	RISE,
	## Spiral arms with differential spin. Portraits and focal icons.
	SWIRL,
	## Steady concentric rings. Badges and highlights.
	ORBIT,
	## Breathe in/out from center. CTAs and hover emphasis.
	PULSE,
	## Fall along Direction Bias; respawn at top. Star showers.
	RAIN,
}

const SPRITE_SIZE := 7
const SPRITE_FRAME_X := [0, 6, 13, 20]
const SPRITE_PATH := "res://addons/magic_sparkles/assets/sparkle_sprite.png"
const SHADER_PATH := "res://addons/magic_sparkles/assets/sparkle_multimesh.gdshader"

const OPACITY_DECAY := 0.005
const FADE_DECAY := 0.02
const FADE_FRAME_COUNT := 100
const TINT_ALPHA := 0.75
