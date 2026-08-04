class_name MagicSparkleCursorPresets
extends RefCounted

## Subtle magical trail for menus and general UI.
const SUBTLE: Dictionary = {
	"rainbow": false,
	"magical_hues": true,
	"spawn_density": 0.04,
	"max_particles": 180,
	"particle_life": 1.2,
	"lift": 14.0,
	"spread": 0.38,
	"turbulence": 0.18,
	"gravity": 30.0,
	"sparks_per_emit": 1,
	"max_spawns_per_frame": 4,
	"min_move_speed": 20.0,
	"burst_particle_count": 14,
	"burst_intensity": 1.0,
}

## Default ambient dust — matches demo shell defaults.
const AMBIENT: Dictionary = {
	"rainbow": false,
	"magical_hues": true,
	"spawn_density": 0.055,
	"max_particles": 220,
	"particle_life": 1.45,
	"lift": 16.0,
	"spread": 0.45,
	"turbulence": 0.22,
	"gravity": 28.0,
	"sparks_per_emit": 1,
	"max_spawns_per_frame": 5,
	"min_move_speed": 18.0,
	"burst_particle_count": 14,
	"burst_intensity": 1.0,
}

## Dense rainbow trail with strong click bursts — great for demos and GIFs.
const RAINBOW_BURST: Dictionary = {
	"rainbow": true,
	"magical_hues": true,
	"spawn_density": 0.08,
	"max_particles": 260,
	"particle_life": 1.7,
	"lift": 20.0,
	"spread": 0.55,
	"turbulence": 0.28,
	"gravity": 26.0,
	"sparks_per_emit": 1,
	"max_spawns_per_frame": 6,
	"min_move_speed": 12.0,
	"burst_particle_count": 20,
	"burst_intensity": 1.2,
}
