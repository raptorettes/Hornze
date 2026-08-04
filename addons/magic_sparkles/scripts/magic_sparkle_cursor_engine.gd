class_name MagicSparkleCursorEngine
extends RefCounted

const _Types := preload("res://addons/magic_sparkles/scripts/magic_sparkle_types.gd")

enum ParticleMode { TRAIL, BURST }

var max_particles: int = 220
var colors: Array[Color] = [Color.WHITE]
var rainbow: bool = false
var magical_hues: bool = true
var spread: float = 0.45
var speed_scale: float = 0.55
var lift: float = 16.0
var gravity: float = 28.0
var particle_life: float = 1.45
var turbulence: float = 0.22
var drag: float = 0.35
var sparks_per_emit: int = 1

var burst_count: int = 14
var burst_spread: float = 2.2
var burst_speed: float = 1.15
var burst_lift: float = 52.0
var burst_life: float = 0.72
var burst_drag: float = 1.35

var _particles: Array[Dictionary] = []
var _write_index: int = 0
var _time: float = 0.0
var _rng := RandomNumberGenerator.new()


func configure(
	p_max: int,
	p_colors: Array[Color],
	p_rainbow: bool,
	p_magical_hues: bool,
	p_spread: float,
	p_speed_scale: float,
	p_lift: float,
	p_gravity: float,
	p_particle_life: float,
	p_turbulence: float,
	p_drag: float,
	p_sparks_per_emit: int,
	p_burst_count: int,
	p_burst_spread: float,
	p_burst_speed: float,
	p_burst_lift: float,
	p_burst_life: float
) -> void:
	max_particles = maxi(1, p_max)
	colors = p_colors if not p_colors.is_empty() else [Color.WHITE]
	rainbow = p_rainbow
	magical_hues = p_magical_hues
	spread = p_spread
	speed_scale = p_speed_scale
	lift = p_lift
	gravity = p_gravity
	particle_life = maxf(p_particle_life, 0.05)
	turbulence = p_turbulence
	drag = p_drag
	sparks_per_emit = clampi(p_sparks_per_emit, 1, 2)
	burst_count = clampi(p_burst_count, 1, 40)
	burst_spread = p_burst_spread
	burst_speed = p_burst_speed
	burst_lift = p_burst_lift
	burst_life = maxf(p_burst_life, 0.05)
	_resize_pool(max_particles)


func _resize_pool(new_size: int) -> void:
	var old_size := _particles.size()
	if new_size == old_size:
		return
	var old := _particles
	_particles = []
	_particles.resize(new_size)
	for i in range(new_size):
		if i < old_size:
			_particles[i] = old[i]
		else:
			_particles[i] = _dead_particle()
	_write_index = _write_index % maxi(new_size, 1)


func emit_at(pos: Vector2, move_dir: Vector2, move_speed: float) -> void:
	var dir := move_dir
	if dir.length_squared() < 0.0001:
		dir = Vector2.DOWN
	else:
		dir = dir.normalized()

	var behind := pos - dir * _rng.randf_range(1.0, 5.0)
	var origin := behind + Vector2(_rng.randf_range(-2.5, 2.5), _rng.randf_range(-2.5, 2.5))
	for i in range(sparks_per_emit):
		var glimmer := _rng.randf() < 0.14
		_write_trail_particle(origin, dir, move_speed, glimmer)


func burst_at(pos: Vector2, intensity: float = 1.0) -> void:
	var strength := clampf(intensity, 0.15, 3.0)
	var count := clampi(int(round(float(burst_count) * strength)), 1, 36)
	var origin := pos + Vector2(_rng.randf_range(-2.0, 2.0), _rng.randf_range(-2.0, 2.0))
	for i in range(count):
		_write_burst_particle(origin, strength)


func update(delta: float) -> void:
	_time += delta
	for i in range(_particles.size()):
		var particle: Dictionary = _particles[i]
		var life: float = particle["life"]
		if life <= 0.0:
			continue

		life -= delta
		var pos: Vector2 = particle["position"]
		var vel: Vector2 = particle["velocity"]
		var phase: float = particle["phase"]
		var mode: int = particle["mode"]

		if mode == ParticleMode.BURST:
			vel *= maxf(1.0 - burst_drag * delta, 0.0)
		else:
			vel *= maxf(1.0 - drag * delta, 0.0)
		vel.y += gravity * delta

		if mode == ParticleMode.TRAIL:
			var sway := sin(_time * 1.6 + phase) * turbulence * 14.0
			vel.x = lerpf(vel.x, sway, delta * 1.4)
		else:
			vel.x += sin(_time * 10.0 + phase) * turbulence * 22.0 * delta

		pos += vel * delta

		var max_life: float = particle["max_life"]
		var life_t := clampf(life / max_life, 0.0, 1.0)
		var age_t := 1.0 - life_t
		var fade_in := _smoothstep(0.0, 0.1 if mode == ParticleMode.BURST else 0.12, age_t)
		var fade_out := _smoothstep(0.0, 0.35 if mode == ParticleMode.BURST else 0.5, life_t)
		var twinkle := 0.9 + 0.1 * sin(_time * (8.0 if mode == ParticleMode.BURST else 3.5) + phase)
		if particle.get("glimmer", false):
			twinkle = 0.82 + 0.18 * sin(_time * 5.5 + phase * 1.7)

		particle["position"] = pos
		particle["velocity"] = vel
		particle["life"] = life
		particle["opacity"] = fade_in * fade_out * twinkle

		if int(_time * 6.0 + phase) % 5 == 0:
			particle["frame"] = _Types.SPRITE_FRAME_X[_rng.randi_range(0, 3)]

		_particles[i] = particle


func get_particles() -> Array[Dictionary]:
	return _particles


func has_live_particles() -> bool:
	for particle in _particles:
		if particle["life"] > 0.0:
			return true
	return false


func _write_trail_particle(origin: Vector2, move_dir: Vector2, move_speed: float, glimmer: bool) -> void:
	var slot := _alloc_slot()
	var life := particle_life * _rng.randf_range(0.9, 1.2)
	var scale := _rng.randf_range(1.12, 1.38) if glimmer else _rng.randf_range(0.7, 1.1)
	_particles[slot] = {
		"position": origin,
		"velocity": _velocity_fairy_dust(move_dir, move_speed),
		"life": life,
		"max_life": life,
		"opacity": 0.0,
		"frame": _Types.SPRITE_FRAME_X[_rng.randi_range(0, 3)],
		"color": _pick_color(),
		"phase": _rng.randf() * TAU,
		"scale": scale,
		"mode": ParticleMode.TRAIL,
		"glimmer": glimmer,
	}


func _write_burst_particle(origin: Vector2, intensity: float) -> void:
	var slot := _alloc_slot()
	var life := burst_life * _rng.randf_range(0.75, 1.15) * clampf(intensity, 0.5, 1.5)
	_particles[slot] = {
		"position": origin + Vector2(_rng.randf_range(-3.0, 3.0), _rng.randf_range(-3.0, 3.0)),
		"velocity": _velocity_burst(intensity),
		"life": life,
		"max_life": life,
		"opacity": 0.0,
		"frame": _Types.SPRITE_FRAME_X[_rng.randi_range(0, 3)],
		"color": _pick_color(),
		"phase": _rng.randf() * TAU,
		"scale": _rng.randf_range(0.9, 1.55) * clampf(intensity, 0.85, 1.35),
		"mode": ParticleMode.BURST,
		"glimmer": true,
	}


func _alloc_slot() -> int:
	for i in range(max_particles):
		var idx := (_write_index + i) % max_particles
		if float(_particles[idx]["life"]) <= 0.0:
			_write_index = (idx + 1) % max_particles
			return idx

	var best_idx := 0
	var best_life: float = float(_particles[0]["life"])
	for i in range(1, max_particles):
		var remaining: float = float(_particles[i]["life"])
		if remaining < best_life:
			best_life = remaining
			best_idx = i
	_write_index = (best_idx + 1) % max_particles
	return best_idx


func _velocity_fairy_dust(move_dir: Vector2, move_speed: float) -> Vector2:
	var motion_damp := clampf(move_speed / 900.0, 0.0, 0.35)
	var drift := move_dir * _rng.randf_range(3.0, 14.0) * speed_scale * (1.0 - motion_damp)
	var angle := move_dir.angle() + _rng.randf_range(-spread, spread)
	var flutter := Vector2.from_angle(angle) * _rng.randf_range(4.0, 16.0) * speed_scale
	var vel := drift + flutter
	vel.x += _rng.randf_range(-10.0, 10.0) * spread
	vel.y += _rng.randf_range(6.0, 22.0)
	if _rng.randf() < 0.22:
		vel.y -= lift * _rng.randf_range(0.35, 0.85)
	return vel


func _velocity_burst(intensity: float) -> Vector2:
	var angle := _rng.randf() * TAU
	var speed := _rng.randf_range(75.0, 195.0) * burst_speed * clampf(intensity, 0.6, 1.8)
	var vel := Vector2.from_angle(angle) * speed
	vel.y -= burst_lift * _rng.randf_range(0.55, 1.25) * clampf(intensity, 0.7, 1.4)
	vel += Vector2(_rng.randf_range(-24.0, 24.0), _rng.randf_range(-12.0, 18.0))
	return vel


func _smoothstep(edge0: float, edge1: float, x: float) -> float:
	if is_equal_approx(edge0, edge1):
		return 1.0 if x >= edge1 else 0.0
	var t := clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _dead_particle() -> Dictionary:
	return {
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"life": 0.0,
		"max_life": 1.0,
		"opacity": 0.0,
		"frame": 0,
		"color": Color.WHITE,
		"phase": 0.0,
		"scale": 1.0,
		"mode": ParticleMode.TRAIL,
		"glimmer": false,
	}


func _pick_color() -> Color:
	if rainbow:
		if magical_hues:
			return Color.from_hsv(
				_rng.randf_range(0.74, 0.9),
				_rng.randf_range(0.35, 0.75),
				_rng.randf_range(0.92, 1.0)
			)
		return Color.from_hsv(_rng.randf(), _rng.randf_range(0.4, 0.85), _rng.randf_range(0.85, 1.0))
	if magical_hues and colors.size() <= 1:
		return Color.from_hsv(
			_rng.randf_range(0.76, 0.88),
			_rng.randf_range(0.3, 0.7),
			_rng.randf_range(0.93, 1.0)
		)
	return colors[_rng.randi_range(0, colors.size() - 1)]
