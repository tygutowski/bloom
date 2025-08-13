extends Node2D

const YEAR_SECONDS: float = 240.0
const SPIN_SPEED: float = 12.0 # rad/s (tweak)

var timeskip_acceleration: float = 1.01
var timeskip_max_speed: float = 1000.0
var year_time: float = 0.0
var _dial_tween: Tween = null
@export var shader: ShaderMaterial
@onready var dial: CanvasItem = $"CanvasLayer/Month"
var _season_idx: int = 0
var spinning: bool = false
var gametime: float = 0.0
var realgametime: float = 0.0
func _process(delta: float) -> void:
	if spinning:
		dial.rotation += SPIN_SPEED * delta
	elif not (_dial_tween and _dial_tween.is_running()):
		dial.rotation = _target_angle_for_index(_season_idx)

func _physics_process(delta: float) -> void:
	gametime += delta
	
	var hours = int(gametime / 3600)
	var minutes = int(fmod(gametime, 3600) / 60)
	var seconds = int(fmod(gametime, 60))
	var milliseconds = int(fmod(gametime, 1) * 100)

	var time_string = "%02d:%02d:%02d:%02d" % [hours, minutes, seconds, milliseconds]
	$CanvasLayer/GameTimeLabel.text = str(time_string)
	
	realgametime += delta / Engine.time_scale
	var realhours = int(realgametime / 3600)
	var realminutes = int(fmod(realgametime, 3600) / 60)
	var realseconds = int(fmod(realgametime, 60))
	var realmilliseconds = int(fmod(realgametime, 1) * 100)

	var realtime_string = "%02d:%02d:%02d:%02d" % [realhours, realminutes, realseconds, realmilliseconds]
	$CanvasLayer/RealTimeLabel.text = str(realtime_string)
	
	var player: CharacterBody2D = get_node("CharacterBody2D")
	var skipping_time: bool = false
	if player.direction == 0 and player.is_on_floor():
		skipping_time = Input.is_action_pressed("skip")
	timeskip(skipping_time)

	year_time = fposmod(year_time + delta, YEAR_SECONDS)
	var value: float = year_time / YEAR_SECONDS
	set_season(value)
	if shader:
		shader.set_shader_parameter("value", value)

func timeskip(speeding_up: bool) -> void:
	if speeding_up:
		if not spinning and Engine.time_scale > 300:
			spinning = true
			if _dial_tween and _dial_tween.is_running():
				_dial_tween.kill()
		Engine.time_scale = minf(timeskip_max_speed, (Engine.time_scale + .25) * timeskip_acceleration)
	else:
		if spinning:
			spinning = false
			_settle_dial_to_current_season()
		Engine.time_scale = 1.0

const SEASON_LEN: float = 0.25
func season_progress(time: float) -> float:
	var t: float = fposmod(time, 1.0)
	var frac: float = fposmod(4.0 * t + 0.5, 1.0)
	return 1.0 - abs(2.0 * frac - 1.0)

func _season_index_from_time(time: float) -> int:
	var t: float = fposmod(time, 1.0)
	if t < 0.125 or t >= 0.875:
		return 0
	elif t < 0.375:
		return 1
	elif t < 0.625:
		return 2
	else:
		return 3

func _target_angle_for_index(idx: int) -> float:
	return deg_to_rad(90.0 * float(idx))

func _animate_dial_to(angle: float) -> void:
	if _dial_tween and _dial_tween.is_running():
		_dial_tween.kill()

	var start: float = dial.rotation
	var a: float = angle + round((start - angle) / TAU) * TAU

	_dial_tween = create_tween()
	_dial_tween.set_ignore_time_scale(true) # real-time settle
	_dial_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_dial_tween.tween_property(dial, "rotation", a, 0.35)

func _settle_dial_to_current_season() -> void:
	var time_frac: float = year_time / YEAR_SECONDS
	_season_idx = _season_index_from_time(time_frac)
	_animate_dial_to(_target_angle_for_index(_season_idx))

func set_season(time: float) -> void:
	var progress: float = season_progress(time)
	var idx: int = _season_index_from_time(time)
	if idx != _season_idx:
		_season_idx = idx
		if not spinning:
			_animate_dial_to(_target_angle_for_index(idx))

	if idx == 0:
		set_winter(progress)
		
	elif idx == 1:
		set_spring(progress)
	elif idx == 2:
		set_summer(progress)
	else:
		set_autumn(progress)

func set_winter(progress: float) -> void:
	$SnowParticles.amount_ratio = progress - 0.3
	for tree in get_tree().get_nodes_in_group("tree"):
		tree.set_winter()
	for flower in get_tree().get_nodes_in_group("flower"):
		flower.set_winter()

func set_spring(progress: float) -> void:
	for tree in get_tree().get_nodes_in_group("tree"):
		tree.set_spring()
	for flower in get_tree().get_nodes_in_group("flower"):
		flower.set_spring()

func set_summer(progress: float) -> void:
	for tree in get_tree().get_nodes_in_group("tree"):
		tree.set_summer()
	for flower in get_tree().get_nodes_in_group("flower"):
		flower.set_summer()

func set_autumn(progress: float) -> void:
	for tree in get_tree().get_nodes_in_group("tree"):
		tree.set_autumn()
	for flower in get_tree().get_nodes_in_group("flower"):
		flower.set_autumn()
