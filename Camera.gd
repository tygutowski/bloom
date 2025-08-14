# Godot 4.4
extends Camera2D

@export var player: Node2D
@export var tween_duration := 0.6
@export var tween_ease_strength := 1.0 # (0..1) stronger = snappier

var _areas: Array[Area2D] = []
var _overlaps: Array[Area2D] = []
var _current_area: Area2D = null
var _moving := false
var _eval_pending := false
var _tw: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# collect and wire areas
	_areas.clear()
	for a in get_tree().get_nodes_in_group("level_area"):
		if a is Area2D:
			_areas.append(a)
			a.body_entered.connect(_on_enter.bind(a))
			a.body_exited.connect(_on_exit.bind(a))
	# seed overlaps/current at start
	if player:
		for a in _areas:
			if a.overlaps_body(player):
				if not _overlaps.has(a):
					_overlaps.append(a)
		_current_area = _pick_best_area()
		if _current_area:
			global_position = _area_center(_current_area)

func _on_enter(body: Node, area: Area2D) -> void:
	if body != player: return
	if not _overlaps.has(area):
		_overlaps.append(area)
	_schedule_evaluate()

func _on_exit(body: Node, area: Area2D) -> void:
	if body != player: return
	_overlaps.erase(area)
	_schedule_evaluate()

func _schedule_evaluate() -> void:
	if _eval_pending: return
	_eval_pending = true
	await get_tree().process_frame
	_eval_pending = false
	_evaluate_change()

func _evaluate_change() -> void:
	if _moving: return
	var best := _pick_best_area()
	if best and best != _current_area:
		_current_area = best
		_tween_to(_area_center(best))

func _pick_best_area() -> Area2D:
	# if multiple overlaps, choose closest "Center" (or collision center) to player
	if _overlaps.is_empty(): return null
	var p := player.global_position
	var best := _overlaps[0]
	var best_d := p.distance_to(_area_center(best))
	for i in range(1, _overlaps.size()):
		var a := _overlaps[i]
		var d := p.distance_to(_area_center(a))
		if d < best_d:
			best = a
			best_d = d
	return best

func _area_center(a: Area2D) -> Vector2:
	var c := a.get_node_or_null("Center")
	if c and c is Node2D:
		return (c as Node2D).global_position
	# try first CollisionShape2D as fallback
	for child in a.get_children():
		if child is CollisionShape2D and child is Node2D:
			return (child as Node2D).global_position
	# final fallback
	return a.global_position

func _tween_to(target: Vector2) -> void:
	_moving = true
	if player.has_method("set_can_move"):
		player.set_can_move(false)

	if _tw and _tw.is_running():
		_tw.kill()
	_tw = create_tween()
	_tw.set_trans(Tween.TRANS_SINE)
	_tw.set_ease(Tween.EASE_IN_OUT)
	_tw.tween_property(self, "global_position", target, tween_duration)
	await _tw.finished

	if player.has_method("set_can_move"):
		player.set_can_move(true)
	_moving = false
