extends LaserActivatable

@onready var inside_sprite: TextureRect = $InsideSprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

func activate():
	inside_sprite.visible = true
	collision_shape_2d.disabled = false
func deactivate():
	inside_sprite.visible = false
	collision_shape_2d.disabled = true
