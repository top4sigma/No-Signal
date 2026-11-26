extends LaserActivatable
@export_group("Moving Settings")
@export var targetPos:Vector2 = Vector2.ZERO
@export var moveFrames: int = 60
var moveVector:Vector2
var moveSpeed = 0
var moveAngle = 0
var topPos = false

@export_group("Platform Settings")
@export var blocksLaser:bool = false
@onready var platform: AnimatableBody2D = $Platform

@export_group("Other")
#set the default texture as the sprite that dosent block the laser
@export var blocksLaserSprite:CompressedTexture2D

@export_group("Nodes")
@export var textureRect:TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	moveSpeed = Vector2.ZERO.distance_to(targetPos) / (moveFrames * 1.0)
	moveAngle = Vector2.ZERO.angle_to_point(targetPos)
	moveVector = abs(targetPos / (moveFrames * 1.0))
	platform.set_collision_layer_value(10,blocksLaser)
	if blocksLaser:
		if blocksLaserSprite:
			textureRect.texture = blocksLaserSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if topPos:
		platform.position.x = move_toward(platform.position.x,targetPos.x,moveVector.x)
		platform.position.y = move_toward(platform.position.y,targetPos.y,moveVector.y)
	else:
		platform.position.x = move_toward(platform.position.x,0,moveVector.x)
		platform.position.y = move_toward(platform.position.y,0,moveVector.y)
func activate():
	topPos = true
func deactivate():
	topPos = false
