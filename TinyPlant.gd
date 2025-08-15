extends Sprite2D

@export var plants: Array[Texture]
var player: Player
var grow: float = 5

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	texture = plants.pick_random()
	material = material.duplicate()
	material.set_shader_parameter("instance_pos", global_position)

func _process(_delta) -> void:
	material.set_shader_parameter("player_pos", player.global_position)

	var dir := 0.0
	if player.can_move and is_equal_approx(Engine.time_scale, 1.0) == true:
		dir = sign(player.velocity.x)
	material.set_shader_parameter("player_dir", dir)
