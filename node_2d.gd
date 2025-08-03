extends Node2D

# Balatro-style background script
# Creates a dark, animated background similar to the card game Balatro

@onready var background_sprite = $BackgroundSprite
@onready var particle_container = $ParticleContainer
@onready var animation_player = $AnimationPlayer

# Background colors (Balatro uses dark purples and blues)
var background_colors = [
	Color(0.05, 0.02, 0.1, 1.0),  # Very dark purple
	Color(0.08, 0.04, 0.15, 1.0),  # Dark purple
	Color(0.12, 0.06, 0.2, 1.0),   # Medium dark purple
	Color(0.15, 0.08, 0.25, 1.0)   # Slightly lighter purple
]

# Particle settings
var particle_count = 50
var particles = []
var particle_speeds = []
var particle_sizes = []

# Animation settings
var animation_speed = 0.5
var color_shift_speed = 0.3

func _ready():
	setup_background()
	create_particles()
	start_animations()

func setup_background():
	# Create a gradient background
	var gradient = Gradient.new()
	gradient.colors = background_colors
	
	# Create gradient texture
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = 1920
	gradient_texture.height = 1080
	
	# Set up background sprite
	if not background_sprite:
		background_sprite = Sprite2D.new()
		background_sprite.name = "BackgroundSprite"
		add_child(background_sprite)
	
	background_sprite.texture = gradient_texture
	background_sprite.position = Vector2(960, 540)  # Center of 1920x1080
	background_sprite.z_index = -100  # Behind everything

func create_particles():
	# Create floating particles similar to Balatro's subtle background effects
	for i in range(particle_count):
		var particle = ColorRect.new()
		particle.size = Vector2(randf_range(2, 8), randf_range(2, 8))
		particle.position = Vector2(
			randf_range(0, 1920),
			randf_range(0, 1080)
		)
		
		# Random particle color (subtle whites and light purples)
		var particle_color = Color(
			randf_range(0.3, 0.8),
			randf_range(0.2, 0.6),
			randf_range(0.4, 0.9),
			randf_range(0.1, 0.3)
		)
		particle.color = particle_color
		
		# Store particle data for animation
		particles.append(particle)
		particle_speeds.append(randf_range(10, 30))
		particle_sizes.append(particle.size)
		
		particle.z_index = -50
		particle_container.add_child(particle)

func start_animations():
	# Create animation player if it doesn't exist
	if not animation_player:
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		add_child(animation_player)
	
	# Create breathing animation for background
	create_breathing_animation()

func create_breathing_animation():
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "BackgroundSprite:modulate")
	
	# Create a subtle breathing effect
	var key_times = [0.0, 1.0, 2.0]
	var key_values = [
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.05, 1.02, 1.05, 1.0),
		Color(1.0, 1.0, 1.0, 1.0)
	]
	
	for i in range(key_times.size()):
		animation.track_insert_key(track_index, key_times[i], key_values[i])
	
	# Set animation to loop
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add animation to player (Godot 4 way)
	if not animation_player.has_animation_library(""):
		animation_player.add_animation_library("", AnimationLibrary.new())
	animation_player.get_animation_library("").add_animation("breathing", animation)
	animation_player.play("breathing")

func _process(delta):
	animate_particles(delta)
	animate_background_colors(delta)

func animate_particles(delta):
	# Animate floating particles
	for i in range(particles.size()):
		var particle = particles[i]
		var speed = particle_speeds[i]
		
		# Move particle upward slowly
		particle.position.y -= speed * delta
		
		# Reset particle when it goes off screen
		if particle.position.y < -50:
			particle.position.y = 1130  # Below screen
			particle.position.x = randf_range(0, 1920)
		
		# Subtle size pulsing
		var pulse = sin(Time.get_ticks_msec() * 0.002 + i) * 0.2 + 1.0
		particle.size = particle_sizes[i] * pulse
		
		# Subtle opacity pulsing
		var alpha_pulse = sin(Time.get_ticks_msec() * 0.0015 + i * 0.5) * 0.1 + 0.2
		particle.modulate.a = alpha_pulse

func animate_background_colors(delta):
	# Subtle color shifting over time
	var time = Time.get_ticks_msec() * color_shift_speed
	var color_shift = sin(time) * 0.02
	
	if background_sprite:
		background_sprite.modulate = Color(
			1.0 + color_shift,
			1.0 + color_shift * 0.5,
			1.0 + color_shift * 0.8,
			1.0
		)

# Function to add card-like elements (optional)
func add_card_elements():
	# Create subtle card-like rectangles in the background
	for i in range(5):
		var card_element = ColorRect.new()
		card_element.size = Vector2(randf_range(100, 200), randf_range(140, 280))
		card_element.position = Vector2(
			randf_range(-100, 2020),
			randf_range(-100, 1180)
		)
		
		# Very dark, almost invisible card elements
		card_element.color = Color(0.02, 0.01, 0.05, 0.3)
		card_element.z_index = -75
		
		particle_container.add_child(card_element)

# Function to change background intensity
func set_background_intensity(intensity: float):
	# intensity should be between 0.0 and 1.0
	if background_sprite:
		background_sprite.modulate = Color(
			intensity,
			intensity * 0.8,
			intensity * 1.2,
			1.0
		) 
