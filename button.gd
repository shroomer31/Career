extends Button

@export var target_scene_path := "res://screen.tscn"

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	get_tree().change_scene_to_file(target_scene_path)
