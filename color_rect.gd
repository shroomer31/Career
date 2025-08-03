extends ColorRect

var time = 0.0

func _ready():
	# Set initial color
	color = Color(0.4, 0.6, 1.0)

func _process(delta):
	time += delta
	
	# Simple color cycling
	var r = 0.2 + 0.3 * sin(time * 0.5)
	var g = 0.3 + 0.2 * sin(time * 0.7)
	var b = 0.5 + 0.2 * sin(time * 0.3)
	
	color = Color(r, g, b)
