extends Node2D

class_name LaserEmiter 
var targets:Array[Node2D]
var targetRays:Array[Laser]
var rays:Array[Laser]
@export var laserChanel = 0
const LASER = preload("uid://xyp2bj356dlg")

@export var rayParent:Node2D
@export var rayOffset:Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func addTarget(target):
	var newRay = LASER.instantiate()
	newRay.laserChanel = laserChanel
	newRay.position = rayOffset
	if target is Node2D:
		newRay.target = target
		targets.append(target)
		targetRays.append(newRay)
	elif target is float or target is int:
		newRay.rotation = target
		rays.append(newRay)
	elif target is Vector2:
		newRay.rotation = Vector2.ZERO.angle_to_point(target)
		rays.append(newRay)
	else:
		return
	if rayParent:
		rayParent.add_child(newRay)
	else:
		add_child(newRay)
	LaserInfo.allLasers.append(newRay)
	
