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
	var grass := mesh_library.find_item_by_name("Grass")
	var gravel := mesh_library.find_item_by_name("Gravel")

	# Only react to the left mouse button being pressed (not released)
	if not (event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)):
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

	# Replace grass with gravel
	if event.button_index == MOUSE_BUTTON_LEFT:
		set_cell_item(cell, gravel)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		set_cell_item(cell, grass)
