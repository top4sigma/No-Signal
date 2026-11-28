extends LaserEmiter
class_name Repeater

signal destroy
signal lasersInChanged
var mouseOver = false
var lasersIn:Array[Laser]:
	set(value):
		lasersIn = value
		updateLasers()
var level:LaserLevel
var selected = false

@export var powerSource = false
@export var texture: Control
@export var selectedScale = 1.3
@export var selectedLerpFrames = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if not level:
		if get_parent() is LaserLevel:
			level = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	updateLasers()

func createRepeater(targetNodes:Array[Node2D]):
	if lasersIn.size() > 0:
		laserChanel = lasersIn[0].laserChanel
	for i in targetNodes:
		addTarget(i)
	
	updateLasers()

func updateLasers():
	if lasersIn.size() > 0 or powerSource:
		if !powerSource:
			if lasersIn[0]:
				laserChanel = lasersIn[0].laserChanel
		
		for i in targetRays:
			if i:
				i.laserChanel = laserChanel
				i.enable()
		
		for i in rays:
			i.laserChanel = laserChanel
			i.enable()
	else:
		for i in targetRays:
			i.disable()
		
		for i in rays:
			i.disable()

func rayStoppedColliding(ray:Laser):
	if lasersIn.find(ray) != -1:
		lasersIn.remove_at(lasersIn.find(ray))
		lasersInChanged.emit()

func rayStartedColliding(ray:Laser):
	if lasersIn.find(ray) == -1:
		lasersIn.append(ray)
		lasersInChanged.emit()

func _on_mouse_area_mouse_entered() -> void:
	mouseOver = true


func _on_mouse_area_mouse_exited() -> void:
	mouseOver = false

func delete():
	destroy.emit()
	for i in targetRays:
		if i:
			i.remove()
	
	for i in rays:
		if i:
			i.remove()
	
	queue_free()

func select():
	selected = true
	
	for i in selectedLerpFrames:
		texture.scale = Vector2(lerpf(1,selectedScale,i/(selectedLerpFrames * 1.0)),lerpf(1,selectedScale,i/(selectedLerpFrames * 1.0)))
		await get_tree().process_frame

func deselect():
	if selected:
		selected = false
		
		for i in selectedLerpFrames:
			texture.scale = Vector2(lerpf(selectedScale,1,i/(selectedLerpFrames * 1.0)),lerpf(selectedScale,1,i/(selectedLerpFrames * 1.0)))
			await get_tree().process_frame
