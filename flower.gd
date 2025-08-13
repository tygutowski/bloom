extends Node2D

var playing: String = ""

func set_winter() -> void:
	pass

func set_spring() -> void:
	if playing != "grow":
		get_node("AnimationPlayer").play("grow")
		playing = "grow"

func set_summer() -> void:
	if playing != "bloom":
		get_node("AnimationPlayer").play("bloom")
		playing = "bloom"

func set_autumn() -> void:
	if playing != "die":
		get_node("AnimationPlayer").play("die")
		playing = "die"
