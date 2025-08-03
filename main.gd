extends Node

# Declare two AudioStreamPlayers for type and click sounds
var type_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

# Pitch variation range (for example, between 0.85 and 1.15)
const PITCH_MIN = 0.6
const PITCH_MAX = 1.3

func _ready():
	# Create AudioStreamPlayers
	type_player = AudioStreamPlayer.new()
	click_player = AudioStreamPlayer.new()
	
	click_player.volume_db = 10
	
	# Load audio streams
	type_player.stream = load("res://sounds/type.mp3")
	click_player.stream = load("res://sounds/click.mp3")
	
	# Add them as children so they can play
	add_child(type_player)
	add_child(click_player)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		# Play the type sound with random pitch
		type_player.pitch_scale = randf_range(PITCH_MIN, PITCH_MAX)
		type_player.play()
		
	elif event is InputEventMouseButton and event.pressed:
		# Play the click sound with random pitch
		click_player.pitch_scale = randf_range(PITCH_MIN, PITCH_MAX)
		click_player.play()
