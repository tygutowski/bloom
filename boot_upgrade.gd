extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.get_jump_boots()
	queue_free()
