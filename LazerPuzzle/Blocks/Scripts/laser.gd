extends Node2D

class_name Laser
@onready var ray: RayCast2D = $Area/Ray
@onready var line: Line2D = $Line
@onready var area: Area2D = $Area
@onready var area_shape: CollisionShape2D = $Area/AreaShape
@onready var laser_end: Node2D = $LaserEnd
@onready var end_particles: CPUParticles2D = $LaserEnd/EndParticles

@export var laserChanel = 0

var target:Node2D
var enabled = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupLaser()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func updateLaser():
	if enabled:
		updateLaserRotation()
		updateLaserLength()
func updateLaserRotation():
	if target:
		rotation = global_position.angle_to_point(target.global_position)		
func updateLaserLength():
	ray.force_raycast_update()
	var rayLength = ray.target_position.x
	laser_end.visible = false
	if ray.is_colliding():
		rayLength = global_position.distance_to(ray.get_collision_point())
		laser_end.global_position = ray.get_collision_point()
		laser_end.visible = true
	var newPoints:PackedVector2Array = [Vector2(0,0),Vector2(rayLength,0)]
	line.points = newPoints
	var newShape = SegmentShape2D.new()
	newShape.b.x = max(rayLength - 10,0)
	newShape.b.y = 0
	area_shape.shape = newShape
func setupLaser():
	line.default_color = LaserInfo.CHANELCOLORS[laserChanel]
	end_particles.color = LaserInfo.CHANELCOLORS[laserChanel]
	updateLaser()
func disable():
	enabled = false
	visible = false
	ray.enabled = false
	area_shape.disabled = true
func enable():
	enabled = true
	visible = true
	ray.enabled = true
	area_shape.disabled = false
	
	
