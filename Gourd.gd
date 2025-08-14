extends Node2D

var playing: String = ""

func _ready() -> void:
	get_node("StaticBody2D/CollisionShape2D").disabled = true

func set_winter() -> void:
	if playing != "die":
		get_node("AnimationPlayer").play("die")
		playing = "die"

func set_autumn() -> void:
	pass

func set_summer() -> void:
	if playing != "bloom":
		get_node("AnimationPlayer").play("bloom")
		playing = "bloom"

func set_spring() -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.killed_by("pumpkin")
