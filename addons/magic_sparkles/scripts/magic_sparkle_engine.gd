class_name MagicSparkleEngine
extends RefCounted

const _Types := preload("res://addons/magic_sparkles/scripts/magic_sparkle_types.gd")

var particle_count: int = 30
var colors: Array[Color] = [Color.WHITE]
var rainbow: bool = false
var speed: float = 1.0
var boundary_mode: MagicSparkleTypes.BoundaryMode = MagicSparkleTypes.BoundaryMode.CLIP_WRAP
var exit_fade_rate: float = 0.05
var motion_mode: MagicSparkleTypes.MotionMode = MagicSparkleTypes.MotionMode.CLASSIC
var direction_bias: Vector2 = Vector2(0.0, -1.0)
var turbulence: float = 0.35
var gravity: float = 0.0
var swirl_strength: float = 1.0
var motion_randomness: float = 0.5

var simulation_rect: Rect2 = Rect2()
var clip_rect: Rect2 = Rect2()

var _particles: Array[Dictionary] = []
var _active: bool = false
var _fading: bool = false
var _fade_frames_left: int = 0
var _time: float = 0.0
var _rng := RandomNumberGenerator.new()
var _motion_center: Vector2 = Vector2.ZERO


func configure(
	p_count: int,
	p_colors: Array[Color],
	p_rainbow: bool,
	p_speed: float,
	p_boundary: MagicSparkleTypes.BoundaryMode,
	p_exit_fade: float,
	p_simulation: Rect2,
	p_clip: Rect2,
	p_motion_mode: MagicSparkleTypes.MotionMode = MagicSparkleTypes.MotionMode.CLASSIC,
	p_direction_bias: Vector2 = Vector2(0.0, -1.0),
	p_turbulence: float = 0.35,
	p_gravity: float = 0.0,
	p_swirl_strength: float = 1.0,
	p_motion_randomness: float = 0.5
) -> void:
	particle_count = maxi(1, p_count)
	colors = p_colors if not p_colors.is_empty() else [Color.WHITE]
	rainbow = p_rainbow
	speed = p_speed
	boundary_mode = p_boundary
	exit_fade_rate = p_exit_fade
	simulation_rect = p_simulation
	clip_rect = p_clip
	motion_mode = p_motion_mode
	direction_bias = p_direction_bias
	turbulence = p_turbulence
	gravity = p_gravity
	swirl_strength = p_swirl_strength
	motion_randomness = clampf(p_motion_randomness, 0.0, 1.0)
	_motion_center = clip_rect.position + clip_rect.size * 0.5
	_rebuild_particles()


func resize_regions(p_simulation: Rect2, p_clip: Rect2) -> void:
	simulation_rect = p_simulation
	clip_rect = p_clip
	_motion_center = clip_rect.position + clip_rect.size * 0.5
	_motion_center = clip_rect.position + clip_rect.size * 0.5


func is_active() -> bool:
	return _active


func is_fading() -> bool:
	return _fading


func activate() -> void:
	_active = true
	_fading = false
	_fade_frames_left = 0
	for particle in _particles:
		particle["opacity"] = _rng.randf()
		particle["frame"] = _Types.SPRITE_FRAME_X[_rng.randi_range(0, 3)]


func deactivate() -> void:
	if not _active:
		return
	_fading = true
	_fade_frames_left = _Types.FADE_FRAME_COUNT


func update(delta: float) -> bool:
	if not _active:
		return false

	_time += delta
	var w := simulation_rect.size.x
	var h := simulation_rect.size.y

	for particle in _particles:
		_update_particle_motion(particle, w, h, delta)
		_update_particle_opacity(particle)
		_update_particle_frame(particle)

	if _fading:
		_fade_frames_left -= 1
		if _fade_frames_left < 0:
			_active = false
			_fading = false
			return false

	return true


func get_particles() -> Array[Dictionary]:
	return _particles


func _rebuild_particles() -> void:
	_particles.clear()
	var w := maxf(simulation_rect.size.x, 1.0)
	var h := maxf(simulation_rect.size.y, 1.0)
	for i in range(particle_count):
		_particles.append(_create_particle(w, h, i))


func _create_particle(w: float, h: float, index: int = 0) -> Dictionary:
	var variance := lerpf(0.65, 1.35, _rng.randf() * motion_randomness + (1.0 - motion_randomness) * 0.5)
	var particle := {
		"position": Vector2(_rng.randf_range(clip_rect.position.x, clip_rect.position.x + clip_rect.size.x),
			_rng.randf_range(clip_rect.position.y, clip_rect.position.y + clip_rect.size.y)),
		"delta": Vector2(_rng.randi_range(-500, 499), _rng.randi_range(-500, 499)),
		"opacity": 1.0,
		"frame": _Types.SPRITE_FRAME_X[_rng.randi_range(0, 3)],
		"color": _pick_color(),
		"velocity": Vector2.ZERO,
		"phase": _rng.randf() * TAU,
		"orbit_angle": _rng.randf() * TAU,
		"orbit_radius": 0.0,
		"orbit_speed": 0.0,
		"pulse_phase": _rng.randf() * TAU,
		"speed_scale": variance,
	}
	_seed_motion(particle, w, h, index, particle_count)
	return particle


func _seed_motion(particle: Dictionary, w: float, h: float, index: int = 0, total: int = 1) -> void:
	var bias := direction_bias
	var max_r := minf(w, h) * 0.45

	match motion_mode:
		MagicSparkleTypes.MotionMode.CLASSIC:
			pass
		MagicSparkleTypes.MotionMode.DRIFT:
			var angle := bias.angle() + _rng.randf_range(-1.2, 1.2)
			var spd: float = _rng.randf_range(18.0, 42.0) * float(particle["speed_scale"])
			particle["velocity"] = Vector2.from_angle(angle) * spd
		MagicSparkleTypes.MotionMode.RISE:
			var angle := bias.angle() + _rng.randf_range(-0.55, 0.55)
			var spd: float = _rng.randf_range(22.0, 48.0) * float(particle["speed_scale"])
			particle["velocity"] = Vector2.from_angle(angle) * spd
		MagicSparkleTypes.MotionMode.SWIRL:
			_seed_swirl_particle(particle, index, total, max_r)
		MagicSparkleTypes.MotionMode.ORBIT:
			_seed_orbit_particle(particle, index, total, max_r)
		MagicSparkleTypes.MotionMode.PULSE:
			particle["orbit_radius"] = _rng.randf_range(8.0, max_r * 0.85)
			particle["orbit_angle"] = _rng.randf() * TAU
			particle["pulse_phase"] = _rng.randf() * TAU
		MagicSparkleTypes.MotionMode.RAIN:
			var angle := bias.angle() + _rng.randf_range(-0.25, 0.25)
			var spd: float = _rng.randf_range(35.0, 70.0) * float(particle["speed_scale"])
			particle["velocity"] = Vector2.from_angle(angle) * spd


func _seed_orbit_particle(particle: Dictionary, index: int, total: int, max_r: float) -> void:
	var ring_count := mini(3, maxi(1, total / 8))
	var ring := index % ring_count
	var ring_radius := max_r * (0.32 + float(ring) * 0.28)
	var slots := maxi(1, int(ceil(float(total) / float(ring_count))))
	var slot := index / ring_count
	var angle := (float(slot % slots) / float(slots)) * TAU + float(ring) * 0.18
	particle["orbit_radius"] = ring_radius
	particle["orbit_angle"] = angle
	particle["orbit_speed"] = 1.35 * swirl_strength * float(particle["speed_scale"])
	particle["position"] = _motion_center + Vector2.from_angle(angle) * ring_radius


func _seed_swirl_particle(particle: Dictionary, index: int, total: int, max_r: float) -> void:
	var arm_count := 3 if total >= 18 else 2
	var arm := index % arm_count
	var per_arm := maxi(1, int(ceil(float(total) / float(arm_count))))
	var slot := index / arm_count
	var along := float(slot) / float(maxi(per_arm - 1, 1))
	var radius := lerpf(max_r * 0.07, max_r * 0.88, along)
	var arm_angle := float(arm) * TAU / float(arm_count)
	var spiral_turns := 1.2 + swirl_strength * 0.3
	var angle := arm_angle + along * spiral_turns * TAU
	var jitter_r := turbulence * max_r * 0.03
	var jitter_a := turbulence * 0.1
	radius = clampf(radius + _rng.randf_range(-jitter_r, jitter_r), max_r * 0.04, max_r)
	angle += _rng.randf_range(-jitter_a, jitter_a)
	particle["orbit_radius"] = radius
	particle["orbit_angle"] = angle
	particle["orbit_speed"] = _rng.randf_range(0.4, 0.55) * swirl_strength * float(particle["speed_scale"])
	particle["position"] = _motion_center + Vector2.from_angle(angle) * radius


func _pick_color() -> Color:
	if rainbow:
		return Color.from_hsv(_rng.randf(), _rng.randf_range(0.5, 1.0), _rng.randf_range(0.7, 1.0))
	return colors[_rng.randi_range(0, colors.size() - 1)]


func _update_particle_motion(particle: Dictionary, w: float, h: float, delta: float) -> void:
	match motion_mode:
		MagicSparkleTypes.MotionMode.CLASSIC:
			_motion_classic(particle, delta)
		MagicSparkleTypes.MotionMode.DRIFT:
			_motion_drift(particle, delta)
		MagicSparkleTypes.MotionMode.RISE:
			_motion_rise(particle, delta)
		MagicSparkleTypes.MotionMode.SWIRL:
			_motion_swirl(particle, delta)
		MagicSparkleTypes.MotionMode.ORBIT:
			_motion_orbit(particle, delta)
		MagicSparkleTypes.MotionMode.PULSE:
			_motion_pulse(particle, delta)
		MagicSparkleTypes.MotionMode.RAIN:
			_motion_rain(particle, delta)
	_apply_boundaries(particle, w, h)


func _motion_classic(particle: Dictionary, delta: float) -> void:
	var pos: Vector2 = particle["position"]
	var delta_vec: Vector2 = particle["delta"]
	var move_chance_x := 0.45 + turbulence * 0.2
	var move_chance_y := 0.45 + turbulence * 0.15

	if _rng.randf() < move_chance_x:
		pos.x += (delta_vec.x * speed * float(particle["speed_scale"])) / 1200.0
	if _rng.randf() < move_chance_y:
		pos.y += (delta_vec.y * speed * float(particle["speed_scale"])) / 1200.0

	var wobble := sin(_time * 2.5 + particle["phase"]) * turbulence * 0.35
	pos.x += wobble * speed * delta * 12.0
	pos.y += cos(_time * 2.0 + particle["phase"]) * turbulence * 0.25 * speed * delta * 10.0
	particle["position"] = pos


func _motion_drift(particle: Dictionary, delta: float) -> void:
	var pos: Vector2 = particle["position"]
	var vel: Vector2 = particle["velocity"]
	var wobble := Vector2(
		sin(_time * 1.8 + particle["phase"]),
		cos(_time * 1.5 + particle["phase"] * 1.3)
	) * turbulence * 28.0
	pos += (vel + wobble) * speed * delta
	particle["position"] = pos
	particle["velocity"] = vel.lerp(vel + wobble * 0.02, turbulence * 0.08)


func _motion_rise(particle: Dictionary, delta: float) -> void:
	var pos: Vector2 = particle["position"]
	var vel: Vector2 = particle["velocity"]
	vel.y -= gravity * 18.0 * delta
	vel.x += sin(_time * 2.2 + particle["phase"]) * turbulence * 12.0 * delta
	pos += vel * speed * delta
	particle["position"] = pos
	particle["velocity"] = vel


func _motion_swirl(particle: Dictionary, delta: float) -> void:
	var angle: float = particle["orbit_angle"]
	var radius: float = particle["orbit_radius"]
	var max_r := minf(simulation_rect.size.x, simulation_rect.size.y) * 0.45
	var normalized_r := clampf(radius / max_r, 0.06, 1.0)
	var spin: float = particle["orbit_speed"] * (1.0 + swirl_strength * (1.0 - normalized_r) * 0.35)
	angle += spin * speed * delta
	particle["orbit_angle"] = angle
	particle["position"] = _motion_center + Vector2.from_angle(angle) * radius


func _motion_orbit(particle: Dictionary, delta: float) -> void:
	var angle: float = particle["orbit_angle"]
	angle += particle["orbit_speed"] * speed * delta
	particle["orbit_angle"] = angle
	particle["position"] = _motion_center + Vector2.from_angle(angle) * particle["orbit_radius"]


func _motion_pulse(particle: Dictionary, delta: float) -> void:
	var base_r: float = particle["orbit_radius"]
	var pulse := sin(_time * (1.5 + swirl_strength * 0.5) + particle["pulse_phase"])
	var radius := base_r * (0.45 + 0.55 * (0.5 + pulse * 0.5))
	var angle: float = particle["orbit_angle"] + pulse * turbulence * 0.4 * delta * speed
	particle["orbit_angle"] = angle
	particle["position"] = _motion_center + Vector2.from_angle(angle) * radius


func _motion_rain(particle: Dictionary, delta: float) -> void:
	var pos: Vector2 = particle["position"]
	var vel: Vector2 = particle["velocity"]
	vel.y += gravity * 32.0 * delta
	if gravity <= 0.0:
		vel.y += 28.0 * delta
	vel.x += sin(_time * 1.6 + particle["phase"]) * turbulence * 8.0 * delta
	pos += vel * speed * delta
	particle["position"] = pos
	particle["velocity"] = vel


func _apply_boundaries(particle: Dictionary, w: float, h: float) -> void:
	var pos: Vector2 = particle["position"]

	if boundary_mode == MagicSparkleTypes.BoundaryMode.FADE_EXIT:
		if not clip_rect.has_point(pos):
			particle["position"] = pos
			particle["opacity"] = maxf(float(particle["opacity"]) - exit_fade_rate, 0.0)
			if particle["opacity"] <= 0.0:
				_respawn_in_clip(particle)
			return

	if motion_mode == MagicSparkleTypes.MotionMode.RAIN:
		if pos.y > clip_rect.position.y + clip_rect.size.y + _Types.SPRITE_SIZE \
				or pos.x < clip_rect.position.x - _Types.SPRITE_SIZE \
				or pos.x > clip_rect.position.x + clip_rect.size.x + _Types.SPRITE_SIZE:
			_respawn_rain(particle, w)
			return

	if pos.x > w:
		pos.x = -_Types.SPRITE_SIZE
	elif pos.x < -_Types.SPRITE_SIZE:
		pos.x = w
	if pos.y > h:
		pos.y = -_Types.SPRITE_SIZE
		pos.x = _rng.randi_range(0, maxi(int(w) - 1, 0))
	elif pos.y < -_Types.SPRITE_SIZE:
		pos.y = h
		pos.x = _rng.randi_range(0, maxi(int(w) - 1, 0))

	particle["position"] = pos


func _respawn_in_clip(particle: Dictionary) -> void:
	var inner := clip_rect
	if inner.size.x <= 1.0 or inner.size.y <= 1.0:
		inner = simulation_rect
	particle["position"] = Vector2(
		_rng.randf_range(inner.position.x, inner.position.x + inner.size.x),
		_rng.randf_range(inner.position.y, inner.position.y + inner.size.y)
	)
	particle["opacity"] = 1.0
	particle["color"] = _pick_color()
	_seed_motion(particle, simulation_rect.size.x, simulation_rect.size.y, _rng.randi(), particle_count)


func _respawn_rain(particle: Dictionary, w: float) -> void:
	particle["position"] = Vector2(
		_rng.randf_range(clip_rect.position.x, clip_rect.position.x + clip_rect.size.x),
		clip_rect.position.y - _rng.randf_range(0.0, 12.0)
	)
	particle["opacity"] = 1.0
	particle["color"] = _pick_color()
	_seed_motion(particle, w, simulation_rect.size.y, _rng.randi(), particle_count)


func _update_particle_opacity(particle: Dictionary) -> void:
	var opacity: float = particle["opacity"]
	if _fading:
		opacity -= _Types.FADE_DECAY
	elif motion_mode == MagicSparkleTypes.MotionMode.CLASSIC:
		opacity -= _Types.OPACITY_DECAY
	elif motion_mode in [
		MagicSparkleTypes.MotionMode.RAIN,
		MagicSparkleTypes.MotionMode.RISE,
		MagicSparkleTypes.MotionMode.DRIFT,
		MagicSparkleTypes.MotionMode.PULSE,
		MagicSparkleTypes.MotionMode.ORBIT,
		MagicSparkleTypes.MotionMode.SWIRL,
	]:
		opacity = 0.78 + sin(_time * 2.8 + particle["phase"]) * 0.22
	else:
		opacity -= _Types.OPACITY_DECAY

	if opacity <= 0.0:
		opacity = 0.0 if _fading else 1.0
	particle["opacity"] = opacity


func _update_particle_frame(particle: Dictionary) -> void:
	var modulus := maxi(_rng.randi_range(1, 7), 1)
	if int(_time) % modulus == 0:
		particle["frame"] = _Types.SPRITE_FRAME_X[_rng.randi_range(0, 3)]
