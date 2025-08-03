extends Camera3D

@export var mouse_sensitivity := 0.1
@export var max_pitch_degrees := 80.0

var yaw := 0.0
var pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -max_pitch_degrees, max_pitch_degrees)
		rotation_degrees = Vector3(pitch, yaw, 0)
