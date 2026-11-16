extends Node

var LASERCHANELS = 4
var CHANELCOLORS = [Color.YELLOW,Color.BLUE,Color.RED,Color.GREEN]

var allLasers:Array[Laser]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateAllLasers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func updateAllLasers():
	for i in allLasers:
		i.updateLaser()
		await get_tree().process_frame
	if allLasers.size() == 0:
		await get_tree().process_frame
	updateAllLasers()
