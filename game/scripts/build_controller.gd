extends Node

@export var grid: TileGrid
@export var fences: Fences

enum Tool {TILE, FENCE}
var current_tool := Tool.TILE

func set_tool(tool: Tool) -> void:
	current_tool = tool

	if current_tool != Tool.FENCE:
		fences.hide_ghost()

func _process(_delta):
	if current_tool != Tool.FENCE:
		return
	# Calculate potential build ghost position
	var hit = _mouse_to_ground(get_viewport().get_mouse_position())
	if hit == null:
		return

	fences.show_ghost(_pick_edge(hit))

func _unhandled_input(event):
	# Only react to mouse buttons being pressed (not released)
	if not (event is InputEventMouseButton and event.pressed):
		return

	var hit = _mouse_to_ground(event.position)
	if hit == null:
		fences.hide_ghost()
		return

	match current_tool:
		Tool.TILE:
			_handle_tile(event, hit)
		Tool.FENCE:
			_handle_fence(event, hit)

func _mouse_to_ground(screen_pos: Vector2) -> Variant:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return null

	# Build a ray from the camera through the given screen position
	var origin := cam.project_ray_origin(screen_pos)
	var direction := cam.project_ray_normal(screen_pos)

	# Intersect the ray with the flat ground plane at y = 0
	return Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
	
func _handle_tile(event, hit: Vector3):
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

	# Convert the world position to a grid cell
	var cell := grid.local_to_map(grid.to_local(hit))
	grid.set_tile(cell, tile_name)

func _handle_fence(event, hit: Vector3):
	var edge := _pick_edge(hit)
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			fences.place(edge)
		MOUSE_BUTTON_RIGHT:
			fences.remove(edge)


# Find the tile edge closest to a point on the ground.
# Returns Vector3i(x, z, axis), see fences.gd for the format.
func _pick_edge(hit: Vector3) -> Vector3i:
	# Convert to grid units: cell (0, 0) covers 0..1 on both axes
	var local := grid.to_local(hit)
	var fx := local.x / grid.cell_size.x
	var fz := local.z / grid.cell_size.z

	# Distance to the nearest vertical (x) and horizontal (z) grid line
	var dx := absf(fx - roundf(fx))
	var dz := absf(fz - roundf(fz))

	if dx < dz:
		# Closer to a line x = const: the edge runs along Z
		return Vector3i(roundi(fx), floori(fz), Fences.AXIS_Z)
	# Closer to a line z = const: the edge runs along X
	return Vector3i(floori(fx), roundi(fz), Fences.AXIS_X)
