extends Node2D
class_name Laser

@onready var ray: RayCast2D = $Area/Ray
@onready var line: Line2D = $Line
@onready var area: Area2D = $Area
@onready var area_shape: CollisionShape2D = $Area/AreaShape
@onready var laser_end: Node2D = $LaserEnd
@onready var end_particles: CPUParticles2D = $LaserEnd/EndParticles
@export var laserChanel = 0

var target: Node2D
var enabled = true
var objColliding: Node2D      # node the array is currently touching

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
		updateTargetPowerdness()


func updateLaserRotation():
	if target:
		rotation = global_position.angle_to_point(target.global_position)

func updateTargetPowerdness():
	if ray:
		if ray.is_colliding():
			if ray.get_collider().get_parent() != objColliding:
				if objColliding:
					if objColliding.is_in_group("LaserTarget"):
						objColliding.rayStoppedColliding(self)

				objColliding = ray.get_collider().get_parent()

				if target:
					if objColliding == target:
						objColliding.rayStartedColliding(self)
				else:
					if objColliding.is_in_group("LaserTarget"):
						objColliding.rayStartedColliding(self)
			elif !objColliding:
				objColliding = ray.get_collider().get_parent()
		else:
			if objColliding:
				if objColliding.is_in_group("LaserTarget"):
					objColliding.rayStoppedColliding(self)

func updateLaserLength():
	if ray:
		ray.force_raycast_update()
		var rayLength = ray.target_position.x
		laser_end.visible = false

		if ray.is_colliding():
			rayLength = global_position.distance_to(ray.get_collision_point())
			laser_end.global_position = ray.get_collision_point()
			laser_end.visible = true

		var newPoints: PackedVector2Array = [Vector2(0, 0), Vector2(rayLength, 0)]
		line.points = newPoints

		var newShape = SegmentShape2D.new()
		newShape.b.x = max(rayLength - area.position.x - 10, 0)
		newShape.b.y = 0
		area_shape.shape = newShape

func setupLaser():
	line.default_color = LaserInfo.CHANELCOLORS[laserChanel]
	end_particles.color = LaserInfo.CHANELCOLORS[laserChanel]
	updateLaser()

	if target:
		if target is Repeater:
			target.destroy.connect(remove)

func disable():
	if enabled:
		enabled = false
		visible = false
		ray.enabled = false
		area_shape.disabled = true
		updateLaser()

		if objColliding:
			if objColliding.is_in_group("LaserTarget"):
				objColliding.rayStoppedColliding(self)

func enable():
	if !enabled:
		enabled = true
		visible = true
		ray.enabled = true
		updateLaser()

		if objColliding:
			if target:
				if objColliding == target:
					objColliding.rayStartedColliding(self)
			else:
				if objColliding.is_in_group("LaserTarget"):
					objColliding.rayStartedColliding(self)

		area_shape.disabled = false

func remove():
	LaserInfo.removeLaser(self)

	if objColliding:
		if objColliding.is_in_group("LaserTarget"):
			objColliding.rayStoppedColliding(self)

	if get_parent() is Repeater:
		if get_parent().targetRays.find(self):
			get_parent().targetRays.remove_at(get_parent().targetRays.find(self))
		if get_parent().rays.find(self):
			get_parent().rays.remove_at(get_parent().rays.find(self))
		if target:
			if get_parent().targets.find(target):
				get_parent().targets.remove_at(get_parent().targets.find(target))

	queue_free()
