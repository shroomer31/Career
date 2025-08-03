extends Node2D

@onready var sprite = $Sprite2D
var scroll_speed = 100.0
var image_height = 0.0
var sprite2: Sprite2D

func _ready():
	if sprite:
		image_height = sprite.texture.get_height()
		
		# Create second sprite programmatically
		sprite2 = Sprite2D.new()
		sprite2.texture = sprite.texture
		sprite2.position = sprite.position
		sprite2.position.y -= image_height
		add_child(sprite2)

func _process(delta):
	if sprite and sprite2:
		sprite.position.y += scroll_speed * delta
		sprite2.position.y += scroll_speed * delta
		
		if sprite.position.y > get_viewport().get_visible_rect().size.y:
			sprite.position.y = sprite2.position.y - image_height
		
		if sprite2.position.y > get_viewport().get_visible_rect().size.y:
			sprite2.position.y = sprite.position.y - image_height
