extends Sprite2D
var mesh = $MeshInstance3D
var material = mesh.get_active_material()

# Replace the texture with something else
material.albedo_texture = preload("res://new_texture.png")  # or another SubViewportTexturew
