extends Area3D

func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://node_2d.tscn")
