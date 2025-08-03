extends Control

@onready var text_edit = $TextEdit
@onready var button = $Button

func _ready():
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Store the text globally
	Global.stored_text = text_edit.text
	# Change to the Main scene
	get_tree().change_scene_to_file("res://Main.tscn")
