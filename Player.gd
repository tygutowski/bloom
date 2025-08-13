extends CharacterBody2D

const SPEED := 100.0
const JUMP_VELOCITY := -180.0

var direction: float = 0.0
var last_time_scale: float = 1.0

func _physics_process(delta: float) -> void:
	var ts := Engine.time_scale
	var skipping := ts != 1.0

	# gravity always, so velocity settles even while skipping
	if not is_on_floor():
		velocity += get_gravity() * delta

	# input gating
	if skipping:
		direction = 0.0
	else:
		direction = Input.get_axis("left", "right")
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# movement / friction
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# edge fix: fast → normal this frame
	if last_time_scale > 1.0 and ts == 1.0:
		velocity.x = clamp(velocity.x, -SPEED, SPEED)

	last_time_scale = ts
	move_and_slide()
