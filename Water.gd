extends TileMapLayer

var timer: float = 0
var frame: int = 0
var ice: bool = false

func _process(delta: float) -> void:
	timer += delta
	if timer >= .3:
		timer = 0
		frame += 1
		if frame > 2:
			frame = 0
		if ice:
			turn_to_ice()
		else:
			animate_water()

func animate_water() -> void:
	for cell in get_used_cells():
		set_cell(cell, 0, Vector2(frame, 0))

func turn_to_ice() -> void:
	for cell in get_used_cells():
		set_cell(cell, 0, Vector2(3, 0))
