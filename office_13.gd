extends Node3D

var dragging := false
var drag_offset := Vector3.ZERO
var drag_plane := Plane()
var camera : Camera3D
var beam_mesh: ImmediateMesh
var beam_instance: MeshInstance3D

func _ready():
	# Find the camera (assumes only one in the scene)
	camera = get_viewport().get_camera_3d()
	
	# Create the beam mesh and instance
	beam_mesh = ImmediateMesh.new()
	beam_instance = MeshInstance3D.new()
	beam_instance.mesh = beam_mesh
	beam_instance.visible = false
	add_child(beam_instance)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Cast a ray from the camera to the mouse position
			var mouse_pos = event.position
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			query.exclude = [self]
			query.collision_mask = 1
			var result = space_state.intersect_ray(query)
			if result and result.has("collider") and result.collider == self:
				dragging = true
				beam_instance.visible = true
				# Create a plane at the object's position, facing the camera
				drag_plane = Plane(camera.global_transform.basis.z, global_transform.origin)
				# Calculate offset between object and intersection point
				drag_offset = global_transform.origin - result.position
		else:
			dragging = false
			beam_instance.visible = false

func _process(delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
		var intersection = drag_plane.intersects_ray(from, to)
		if intersection != null:
			global_transform.origin = intersection + drag_offset
		_draw_beam()
	elif beam_instance.visible:
		beam_instance.visible = false

func _draw_beam():
	beam_mesh.clear()
	beam_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	beam_mesh.surface_set_color(Color(1, 1, 0, 1)) # Yellow beam
	beam_mesh.surface_add_vertex(to_local(camera.global_transform.origin))
	beam_mesh.surface_add_vertex(Vector3.ZERO) # The object's origin
	beam_mesh.surface_end()
