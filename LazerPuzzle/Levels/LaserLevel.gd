extends Level

class_name LaserLevel

@export var repeaterPlacer:RepeaterPlacer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not repeaterPlacer:
		for i in get_children():
			if i is RepeaterPlacer:
				repeaterPlacer = i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
