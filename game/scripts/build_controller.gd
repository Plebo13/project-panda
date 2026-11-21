extends Node

@export var grid: GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
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
	var cell := grid.local_to_map(grid.to_local(hit))
	grid.set_tile(cell, tile_name)
