extends CharacterBody3D

@onready var animation_player = $characterMedium/AnimationPlayer

# Movement variables
var speed = 8.0
var jump_velocity = 4.5

# Camera settings
var camera_distance = 15.0
var camera_height = 10.0

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Set up the camera to follow the character
	setup_camera()

func setup_camera():
	# Get the main camera from the scene
	var main_camera = get_viewport().get_camera_3d()
	if main_camera:
		# Position camera at isometric angle
		main_camera.global_position = global_position + Vector3(0, camera_height, camera_distance)
		main_camera.look_at(global_position, Vector3.UP)

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction using default input actions
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.z = Input.get_axis("ui_up", "ui_down")
	input_dir = input_dir.normalized()

	# Apply world space movement directly
	if input_dir != Vector3.ZERO:
		# Apply movement in world space
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.z * speed
		
		# Rotate character to face movement direction
		if input_dir.length() > 0.1:
			var target_rotation = atan2(input_dir.x, input_dir.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 8.0 * delta)
		
		# Play run animation
		if animation_player and is_on_floor():
			if animation_player.current_animation != "run":
				animation_player.play("run")
	else:
		# Stop movement when no input
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		# Play idle animation when not moving
		if animation_player and is_on_floor():
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

	move_and_slide()
	
	# Make the main camera follow the character on X-axis only
	var main_camera = get_viewport().get_camera_3d()
	if main_camera:
		var target_camera_pos = Vector3(global_position.x, main_camera.global_position.y, main_camera.global_position.z)
		main_camera.global_position = main_camera.global_position.lerp(target_camera_pos, 5.0 * delta)
		main_camera.look_at(global_position, Vector3.UP) 
