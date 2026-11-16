extends LaserEmiter



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addTarget(0)
	rays[0].position.x += 26


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
