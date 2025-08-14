extends CharacterBody2D
class_name Player

const SPEED := 70.0
const JUMP_VELOCITY := -190.0
const JUMP_BOOTS_VELOCITY := -245
var direction: float = 0.0
var last_time_scale: float = 1.0
var can_move: bool = true
var facing_right: bool = true
var has_jump_boots: bool = false

func killed_by(death) -> void:
	if death == "pumpkin":
		print("Death by pumpkin")

func get_jump_boots() -> void:
	has_jump_boots = true
	$"../../CanvasLayer/TextureRect/HBoxContainer/JumpBoots".visible = true

func _ready() -> void:
	$"../../CanvasLayer/TextureRect/HBoxContainer/JumpBoots".visible = false

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	var ts := Engine.time_scale
	var skipping := ts != 1.0

	if not is_on_floor():
		velocity += get_gravity() * delta

	if skipping:
		direction = 0.0
	else:
		direction = Input.get_axis("left", "right")
		if Input.is_action_just_pressed("jump") and is_on_floor():
			if has_jump_boots:
				velocity.y = JUMP_BOOTS_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY

	if direction == -1:
		facing_right = true
	elif direction == 1:
		facing_right = false
	$Sprite2D.flip_h = facing_right
	# movement / friction
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
	
	if Input.is_action_pressed("skip"):
		$AnimationPlayer.play("wait")
	else:
		
		if is_zero_approx(velocity.x):
			if is_on_floor():
				$AnimationPlayer.play("idle")
			else:
				if velocity.y <= 0:
					$AnimationPlayer.play("fall")
				else:
					$AnimationPlayer.play("jump")
		else:
			if is_on_floor():
				$AnimationPlayer.play("run")
			else:
				if velocity.y <= 0:
					$AnimationPlayer.play("fall")
				else:
					$AnimationPlayer.play("jump")
		
	if last_time_scale > 1.0 and ts == 1.0:
		velocity.x = clamp(velocity.x, -SPEED, SPEED)

	last_time_scale = ts

	move_and_slide()

func set_can_move(value):
	can_move = value
