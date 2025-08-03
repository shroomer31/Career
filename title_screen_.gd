extends Control

@onready var button = $Button

func _ready():
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Change to the Main scene
	get_tree().change_scene_to_file("res://Main.tscn")
