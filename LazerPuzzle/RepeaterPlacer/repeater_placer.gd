extends Node2D
class_name RepeaterPlacer

@export_group("Laser Puzzles")
@export var maxRepeaters:int = 0     # How many repeaters the player has

@export_group("Nodes")
@export var player:Player
@export var level:LaserLevel
@export var outlineNode:TextureRect
@export var mouseFollowParent:Control

@export_group("Visuals")
@export var repeaterSprite:CompressedTexture2D
@export var repeaterNoLegs:CompressedTexture2D
var repeaterTargets:Array[Node2D]    # an array of nodes that the next repeater will target

const REPEATER = preload("uid://cwetnd7s2bgnt")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# makes sure that the player is set even if the level creator didn't set it manualy
	if not player:
		for i in get_parent().get_children():
			if i is Player:
				player = i
	
	# Makes sure that level is set even if the level creator didnt set it manualy
	if level:
		if level.repeaterPlacer:
			level.repeaterPlacer = self
	else:
		if get_parent() is LaserLevel:
			level = get_parent()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouseFollowParent.position = get_global_mouse_position()
	var showRepeater = true
	
	for i in level.get_children():
		if (i is Repeater) and i.mouseOver:
			showRepeater = false
			mouseFollowParent.visible = false
	if showRepeater:
		mouseFollowParent.visible = true

	if Input.is_action_just_pressed("DIE"):
		print(repeaterTargets)
		repeaterTargets.clear()

	if Input.is_action_just_pressed("PlaceRepeater"):
		var canPlaceRepeater = true
		for i in level.get_children():
			if (i is Repeater) and i.mouseOver:
				canPlaceRepeater = false
				targetPressed(i)
				break
		if canPlaceRepeater:
			placeRepeater(repeaterTargets)
	if Input.is_action_just_pressed("RemoveRepeater"):
		for i in level.get_children():
			if (i is Repeater and not i is Sensor) and i.mouseOver:
				i.delete()

# adds a target to the selected list
func targetPressed(target:Node2D):
	if repeaterTargets.find(target) != -1:
		repeaterTargets.remove_at(repeaterTargets.find(target))
		target.deselect()
	else:
		repeaterTargets.append(target)
		target.select()


# places a repeater at the mouses position and resets the selected targets
# ps- if the repeater emits its own laser without being powered
func placeRepeater(targets,ps:bool = false):
	var newRepeater:= REPEATER.instantiate()
	newRepeater.position = get_global_mouse_position()
	newRepeater.powerSource = ps
	
	get_parent().add_child(newRepeater)
	newRepeater.createRepeater(repeaterTargets)
	repeaterTargets.clear()
	
	for i in level.get_children():
		if i.is_in_group("LaserTarget"):
			i.deselect()
