class_name MagicSparkleBounds
extends RefCounted


static func resolve_host(node: Node, host_path: NodePath, custom_size: Vector2) -> Node:
	if not host_path.is_empty():
		var resolved := node.get_node_or_null(host_path)
		if resolved:
			return resolved
	var parent := node.get_parent()
	if parent is Control or parent is Node2D:
		return parent
	return node


static func get_clip_rect(host: Node, custom_size: Vector2) -> Rect2:
	if host is Control:
		var control := host as Control
		return Rect2(Vector2.ZERO, control.size)
	if host is Sprite2D:
		var sprite := host as Sprite2D
		if sprite.texture:
			var tex_size := sprite.texture.get_size() * sprite.scale
			var offset := -sprite.offset * sprite.scale + sprite.position
			return Rect2(offset - tex_size * 0.5, tex_size)
	if host is TextureRect:
		var tex_rect := host as TextureRect
		return Rect2(Vector2.ZERO, tex_rect.size)
	if custom_size != Vector2.ZERO:
		return Rect2(Vector2.ZERO, custom_size)
	return Rect2(Vector2.ZERO, Vector2(64, 64))


static func get_host_size(host: Node, custom_size: Vector2) -> Vector2:
	return get_clip_rect(host, custom_size).size


static func clip_rect_in_overlay(overlap: float, host_size: Vector2) -> Rect2:
	return Rect2(Vector2(overlap, overlap), host_size)


static func simulation_rect_in_overlay(overlap: float, host_size: Vector2) -> Rect2:
	var margin := overlap * 2.0
	return Rect2(Vector2.ZERO, host_size + Vector2(margin, margin))
