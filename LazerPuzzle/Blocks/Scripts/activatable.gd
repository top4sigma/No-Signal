extends Node2D
class_name LaserActivatable


var active = false
@export var sensors:Array[Sensor]
@export var flipActivation:bool
func _ready() -> void:
	updateState()
	for i in sensors:
		i.lasersInChanged.connect(updateState)

func _process(delta: float) -> void:
	pass
func updateState():
	var deActivate = true
	for i in sensors:
		if i.getStatus():
			deActivate = false
			if not active:
				if not flipActivation:
					activate()
				else:
					deactivate()
				active = true
			break
	if deActivate:
		if active:
			if flipActivation:
				activate()
			else:
				deactivate()
			active = false
func activate():
	pass
func deactivate():
	pass
