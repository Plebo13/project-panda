extends Node3D

# Movement speed of the rig (units per second), scaled by zoom distance
@export var move_speed := 30.0
# Mouse sensitivity for rotating the view
@export var rotate_speed := 0.005
# How far one mouse wheel step zooms in or out
@export var zoom_step := 3.0
@export var min_distance := 5.0
@export var max_distance := 200.0

@export var grid: GridMap

var yaw := 0.0 # Horizontal rotation around the Y axis (radians)
var pitch := -0.6 # Vertical tilt, negative = looking down (radians)
var distance := 15.0 # Distance between the camera and the pivot

@onready var cam: Camera3D = $Camera3D


func _ready():
	# grid.cell_size
	_update_camera()


func _process(delta):
	# Read WASD input as a direction vector on the ground plane
	var dir := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W): dir.z -= 1
	if Input.is_physical_key_pressed(KEY_S): dir.z += 1
	if Input.is_physical_key_pressed(KEY_A): dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D): dir.x += 1

	if dir != Vector3.ZERO:
		# Move relative to the view direction (yaw only, ignore the pitch)
		var flat_basis := Basis(Vector3.UP, yaw)
		# Move faster when zoomed out so panning feels consistent
		var speed := move_speed * (distance / 40.0)
		global_position += flat_basis * dir.normalized() * speed * delta

	# Rotating the camera using Q or E
	if Input.is_physical_key_pressed(KEY_Q):
		yaw -= 0.05
		_update_camera()
	elif Input.is_physical_key_pressed(KEY_E):
		yaw += 0.05
		_update_camera()

	
func _unhandled_input(event):
	# Rotate the view while the middle mouse button is held down
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		yaw -= event.relative.x * rotate_speed
		# Clamp the pitch so the camera cannot flip or go below the field
		pitch = clamp(pitch - event.relative.y * rotate_speed, -1.5, -0.1)
		_update_camera()

	# Zoom with the mouse wheel
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = max(min_distance, distance - zoom_step)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(max_distance, distance + zoom_step)
			_update_camera()


func _update_camera():
	# Rotate the pivot and push the camera back along its local Z axis
	rotation = Vector3(pitch, yaw, 0.0)
	cam.position = Vector3(0, 0, distance)
