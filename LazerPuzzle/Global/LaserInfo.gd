extends Node

var LASERCHANELS = 4
var CHANELCOLORS = [Color.YELLOW,Color.BLUE,Color.RED,Color.GREEN]

var allLasers:Array[Laser]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateAllLasers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateAllLasers()

func updateAllLasers() -> void:
	var stack: Array[Laser] = []     # seed worklist with every currently active laser
	for laser in allLasers:
		if laser and laser.enabled:
			stack.append(laser)

	var processed: Array[Laser] = []
	var index = 0
	while index < stack.size():
		var laser = stack[index]
		index += 1
		if not laser or laser in processed:
			continue
		processed.append(laser)

		laser.updateLaser()

		var hit: Node2D = laser.objColliding
		if hit is Repeater:
			var repeater: Repeater = hit
			repeater.updateLasers()
			for next_laser in repeater.targetRays + repeater.rays:
				if next_laser and next_laser not in processed and next_laser not in stack:
					stack.append(next_laser)

func removeLaser(laser:Laser):
	if allLasers.find(laser):
		allLasers.remove_at(allLasers.find(laser))
