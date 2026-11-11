extends CharacterBody2D
@export_group("Movement")
@export var maxSpeed:float
#Speed increase per frame you are moving on the ground
@export var groundAccel:float
#Speed increase per frame you are moving in air
@export var airAccel:float
#Speed decrease per frame you arent moving on the ground
@export var groundDeccel:float
#Speed decrease per frame you arent moving in air
@export var airDeccel:float
#Speed change per frame you input the opposite direction you are moving on the ground
@export var activeGroundDeccel:float
#Speed change per frame you input the opposite direction you are moving int air
@export var activeAirDeccel:float
#Speed decrease when you are over maxSpeed on the ground
@export var overspeedGroundDeccel:float
#Speed decrease when you are over maxSpeed in the air
@export var overspeedAirDeccel:float


@export_group("Gravity")
@export var useGravityOveride:bool = false
#Gravity that effects the player, if null, it uses the global gravity
@export var gravityOveride:Vector2
#gravity multiplyer when your y vel is over 0
@export var risingMult:float = 1
#gravity multiplyer when your y vel is under 0
@export var fallingMult:float = 1


@export_group("Jump")
#Heighest Jump
@export var maxJump:float = 20
#Shortest Jump
@export var minJump:float = 10
#Frames to hold for to get your heighest jump
@export var maxHeightHold:int = 30
#Frames your jump is buffered for
@export var jumpBuffer:int = 10
@export_subgroup("Squash And Stretch")
@export var maxStretch :float= 2
#Y velocity needed to reach maxStretch
@export var maxStretchSpeed:int = 100
@export_group("Interaction")
#The time it takes for an interactable popup text to fade in
@export var interactableTextPopupTime :int= 10

@export_group("Nodes")
@export var generalArea:Area2D
@export var interactText:Label


#	Interaction System
#an Array of all the interactables in range
var interactablesInRange:Array[Node2D]

var lastClosestInteractable = null
#	MISC
var respawnPoint:Vector2

#	Movement
#true right after you jumps if you can still hold more to go higher
var holdingJump:bool = false
#frames you have been holding a jump for
var currentJumpHold:int = 0
#frames scince your last jump, goes to -1 when it reaches jumpBuffer
var lastJumpInput = -1
#if the player is walking side to side
var walking:bool = false
func _ready() -> void:
	respawnPoint = position
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("DIE"):
		respawn()
	
	applyGravity()
	handleJumpJogic()	
	var direction := Input.get_axis("Left", "Right")
	var accel = chooseAccel(direction)
	handleMovement(direction,accel)

	checkForInteractions()
	move_and_slide()
func jump():
	velocity.y = -minJump	
func applyGravity():
	if not is_on_floor():
		if useGravityOveride:
			if velocity.y <= 0:
				velocity += gravityOveride * risingMult
			else:
				velocity += gravityOveride * fallingMult
		else:
			if velocity.y <= 0:
				velocity += get_gravity() * risingMult
			else:
				velocity += get_gravity() * fallingMult
func handleJumpJogic():
	if Input.is_action_pressed("Jump"):
		if is_on_floor():
			jump()
			holdingJump = true
			currentJumpHold = 0
		elif holdingJump:
			currentJumpHold += 1
			if currentJumpHold <= maxHeightHold:
				velocity.y -= (maxJump - minJump) / maxHeightHold
			else:
				holdingJump = false
				currentJumpHold = 0
		else:
			lastJumpInput = 0
	else:
		holdingJump = false
		if lastJumpInput != -1 and lastJumpInput < jumpBuffer:
			lastJumpInput += 1
			if is_on_floor():
				jump()
				lastJumpInput = -1
#Chooses how much to modify the x velocity by
func chooseAccel(direction:float) -> float:
	var accel:float = 0
	if is_on_floor():
		if direction:
			if abs(velocity.x) > maxSpeed:
				accel = overspeedGroundDeccel
			else:
				if (direction < 0 and velocity.x < 0) or (direction > 0 and velocity.x > 0):
					accel = groundAccel
				else:
					accel = activeGroundDeccel
		else:
			accel = groundDeccel
	else:
		if direction:
			if abs(velocity.x) > maxSpeed:
				accel = overspeedAirDeccel
			else:
				if (direction < 0 and velocity.x < 0) or (direction > 0 and velocity.x > 0):
					accel = airAccel
				else:
					accel = activeAirDeccel
		else:
			accel = airDeccel
	return accel
func handleMovement(direction:float,accel:float):
	if direction:
		moving(direction)
		walking = true
		velocity.x = move_toward(velocity.x,maxSpeed * direction,accel)
	else:
		walking = false
		velocity.x = move_toward(velocity.x, 0, accel)
func respawn():
	position = respawnPoint

#InteractSystem
func getClosestInteractable():
	if interactablesInRange.size() > 0:
		var closest:Node2D = interactablesInRange[0]
		for i in interactablesInRange:
			if i.position.distance_to(position) < closest.position.distance_to(position):
				closest = i
		return closest
func checkForInteractions():
	if Input.is_action_just_pressed("Interact"):
		var closest :Interactable= getClosestInteractable()
		if closest:
			if closest.canInteract():
				interact(closest)
func interact(object:Interactable):
	object.interact()
func updateInteractText():
	updateHighlightedInteractable()
	var closest :Interactable= getClosestInteractable()
	if closest && closest.getPopupText() != "":
		var text :String = closest.getPopupText()
		interactText.text = text
		for i in interactableTextPopupTime:
			interactText.modulate.a = move_toward(interactText.modulate.a,1.0,1.0 / interactableTextPopupTime)
			await get_tree().process_frame
	else:
		for i in interactableTextPopupTime:
			interactText.modulate.a = move_toward(interactText.modulate.a,0.0,1.0 / interactableTextPopupTime)
			await get_tree().process_frame
		interactText.text = ""
#Signals
func genAreaEntered_Area(area: Area2D) -> void:
	if area.get_parent().is_in_group("Interactable"):
		interactablesInRange.append(area.get_parent())
		updateInteractText()
func genAreaExited_Area(area: Area2D) -> void:
	if area.get_parent().is_in_group("Interactable"):
		area.get_parent().unhighlight()
		var interactableIndex:int= interactablesInRange.find(area.get_parent())
		if interactableIndex != -1:
			interactablesInRange.remove_at(interactableIndex)
			updateInteractText()
func updateHighlightedInteractable():
	var closest :Interactable= getClosestInteractable()
	if closest:
		for i in interactablesInRange:
			if i != closest:
				i.unhighlight()
		closest.highlight()
#Runs every frame that the player is inputing either left or right
func moving(direction):
	if lastClosestInteractable != getClosestInteractable():
		closestInteractableChanged()
func closestInteractableChanged():
	lastClosestInteractable = getClosestInteractable()
	updateInteractText()
func handleSquashStretch():
	if velocity.y == 0:
		scale.x = 1
	else:
		scale.x = (1/maxStretch) / (velocity.y/maxStretchSpeed)
