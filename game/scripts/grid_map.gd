class_name TileGrid extends GridMap

@export var size := Vector2i(100, 100)
@export var item_name := "Grass"

func _ready():
	var item := mesh_library.find_item_by_name(item_name)
	if item == -1:
		push_error("Item not found: " + item_name)
		return

	for x in size.x:
		for z in size.y:
			set_cell_item(Vector3i(x, 0, z), item)

func set_tile(cell: Vector3i, tile_name: String):
	if get_cell_item(cell) == INVALID_CELL_ITEM:
		return

	# Replace the clicked tile with the chosen one
	set_cell_item(cell, mesh_library.find_item_by_name(tile_name))
