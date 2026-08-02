extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		var horse = body as Hornse
		 
		horse.jumps += 1
		horse.dashType = 3
		horse.dashes += 1
		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property(%MushroomSprite,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
		self.queue_free()
