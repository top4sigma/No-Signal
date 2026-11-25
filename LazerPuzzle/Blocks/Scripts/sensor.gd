extends Repeater

class_name Sensor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func rayStartedColliding(ray:Laser):
	super.rayStartedColliding(ray)
	
func _on_mouse_area_mouse_entered() -> void:
	super._on_mouse_area_mouse_entered()


func _on_mouse_area_mouse_exited() -> void:
	super._on_mouse_area_mouse_exited()
func getStatus():
	return lasersIn.size() > 0

#disable unnecicary inherited funcitons
func updateLasers():
	pass
func createRepeater(targetNodes:Array[Node2D]):
	pass
func delete():
	queue_free()
