class_name Fences extends Node3D

# Fences live on the edges between tiles, not on the tiles themselves.
# An edge is stored as Vector3i(x, z, axis):
#   axis 0: runs along X on grid line z, separates cells (x, z-1) and (x, z)
#   axis 1: runs along Z on grid line x, separates cells (x-1, z) and (x, z)
# Every physical edge has exactly one key.

const AXIS_X := 0
const AXIS_Z := 1

@export var fence_scene: PackedScene
@export var grid: TileGrid

# Edge key (Vector3i) -> fence node (Node3D)
var _fences := {}
var _ghost: Node3D

func _ready():
	_ghost = fence_scene.instantiate()
	var transparent := StandardMaterial3D.new()
	transparent.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	transparent.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	transparent.albedo_color = Color(0.3, 1.0, 0.3, 0.5)

	for mesh_instance in _ghost.find_children("*", "MeshInstance3D", true, false):
		mesh_instance.material_override = transparent

	add_child(_ghost)
	_ghost.visible = false

func place(edge: Vector3i) -> bool:
	if not is_valid_edge(edge) or has_fence(edge):
		return false

	var fence: Node3D = fence_scene.instantiate()
	# The model runs along X. A Z-edge needs a quarter turn around Y.
	if edge.z == AXIS_Z:
		fence.rotation.y = PI / 2
	# edge_to_world returns grid-local coordinates. Convert them to this node's space.
	fence.position = to_local(grid.to_global(edge_to_world(edge)))
	add_child(fence)

	_fences[edge] = fence
	return true

func show_ghost(edge: Vector3i) -> bool:
	if not is_valid_edge(edge):
		hide_ghost()
		return false

	# The model runs along X. A Z-edge needs a quarter turn around Y.
	if edge.z == AXIS_Z:
		_ghost.rotation.y = PI / 2
	# edge_to_world returns grid-local coordinates. Convert them to this node's space.
	_ghost.position = to_local(grid.to_global(edge_to_world(edge)))
	_ghost.rotation.y = PI / 2 if edge.z == AXIS_Z else 0.0
	_ghost.visible = true
	return true

func hide_ghost():
	_ghost.visible = false


func remove(edge: Vector3i) -> bool:
	if not has_fence(edge):
		return false

	_fences[edge].queue_free()
	_fences.erase(edge)
	return true


func has_fence(edge: Vector3i) -> bool:
	return _fences.has(edge)


# True if the edge lies inside the map, including the outer border.
func is_valid_edge(edge: Vector3i) -> bool:
	var x := edge.x
	var z := edge.y
	match edge.z:
		AXIS_X:
			return x >= 0 and x < grid.size.x and z >= 0 and z <= grid.size.y
		AXIS_Z:
			return x >= 0 and x <= grid.size.x and z >= 0 and z < grid.size.y
	return false


# Centre of the edge in the grid's local space, on the ground (y = 0).
func edge_to_world(edge: Vector3i) -> Vector3:
	var cs := grid.cell_size
	if edge.z == AXIS_X:
		return Vector3((edge.x + 0.5) * cs.x, 0.0, edge.y * cs.z)
	return Vector3(edge.x * cs.x, 0.0, (edge.y + 0.5) * cs.z)


# The two cells this edge separates. On the map border, one of them is outside the map.
func edge_to_cells(edge: Vector3i) -> Array[Vector2i]:
	if edge.z == AXIS_X:
		return [Vector2i(edge.x, edge.y - 1), Vector2i(edge.x, edge.y)]
	return [Vector2i(edge.x - 1, edge.y), Vector2i(edge.x, edge.y)]
