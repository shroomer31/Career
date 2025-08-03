extends Label

# Color settings
var colors = [
	Color(1.0, 0.2, 0.2),  # Red
	Color(0.2, 1.0, 0.2),  # Green
	Color(0.2, 0.2, 1.0),  # Blue
	Color(1.0, 1.0, 0.2),  # Yellow
	Color(1.0, 0.2, 1.0),  # Magenta
	Color(0.2, 1.0, 1.0)   # Cyan
]

# Animation settings
var bob_speed = 3.0
var color_speed = 2.0
var bob_amount = 20.0
var time = 0.0

# Store original position
var original_position: Vector2

func _ready():
	original_position = position
	# Set initial color
	modulate = colors[0]

func _process(delta):
	time += delta
	
	# Bob side to side
	var bob_offset = sin(time * bob_speed) * bob_amount
	position.x = original_position.x + bob_offset
	
	# Change colors
	var color_index = int(time * color_speed) % colors.size()
	var next_color_index = (color_index + 1) % colors.size()
	var color_progress = (time * color_speed) - int(time * color_speed)
	
	# Smooth color transition
	modulate = colors[color_index].lerp(colors[next_color_index], color_progress)
