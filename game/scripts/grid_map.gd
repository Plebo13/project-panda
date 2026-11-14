extends GridMap

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

func _unhandled_input(event):
	# Only react to mouse buttons being pressed (not released)
	if not (event is InputEventMouseButton and event.pressed):
		return

	# Pick the tile to place: left click lays gravel, right click restores grass.
	# Any other button (e.g. the mouse wheel) is ignored.
	var tile_name: String
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			tile_name = "Gravel"
		MOUSE_BUTTON_RIGHT:
			tile_name = "Grass"
		_:
			return

	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return

	# Build a ray from the camera through the clicked pixel
	var origin := cam.project_ray_origin(event.position)
	var direction := cam.project_ray_normal(event.position)

	# Intersect the ray with the flat ground plane at y = 0
	var hit = Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
	if hit == null:
		return

	# Convert the world position to a grid cell
	var cell := local_to_map(to_local(hit))
	if get_cell_item(cell) == INVALID_CELL_ITEM:
		return

	# Replace the clicked tile with the chosen one
	set_cell_item(cell, mesh_library.find_item_by_name(tile_name))
