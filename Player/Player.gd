extends CharacterBody2D

class_name Player

@export_group("Movement")
@export var maxSpeed: float
# Fraction of the distance to target speed covered per second while moving on the ground
@export var groundAccel: float
# Fraction of the distance to target speed covered per second while moving in air
@export var airAccel: float


@export_group("Gravity")
@export var baseGravityMult: float = 1.0


@export_group("Jump")
# Shortest Jump
@export var minJump: float = 10
# Maximum seconds the jump can be held for
@export var maxHeightHold: float = 0.2
# Seconds your jump is buffered for
@export var jumpBuffer: float = 0.15
# Gravity multiplier while jump is held
@export var holdGravityMult: float = 0.4
# Remaining upward velocity kept when jump is released early
@export var releaseVelocityCut: float = 0.4
@export_subgroup("Squash And Stretch")
@export var maxStretch: float = 2
# Y velocity needed to reach maxStretch
@export var maxStretchSpeed: int = 100
@export_group("Interaction")
# The time it takes for an interactable popup text to fade in
@export var interactableTextPopupTime: int = 10

@export_group("Nodes")
@export var generalArea: Area2D
@export var interactText: Label


#	------------------------------ Interaction System ------------------------------
# an Array of all the interactables in range
var interactablesInRange: Array[Node2D]
var lastClosestInteractable = null


#	------------------------------ MISC ------------------------------
var respawnPoint: Vector2


#	------------------------------ Movement ------------------------------
# true right after you jump if you can still hold to go higher
var holdingJump: bool = false
# seconds you have been holding a jump for
var currentJumpHold: float = 0.0
# seconds since your last jump input, -1 means there is no active buffer
var lastJumpInput: float = -1.0
# if the player is walking side to side
var walking: bool = false


func _ready() -> void:
	respawnPoint = position


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("DIE"):
		respawn()

	applyGravity(delta)
	handleJumpLogic(delta)

	var direction := Input.get_axis("Left", "Right")
	handleMovement(direction, delta)

	checkForInteractions()
	move_and_slide()


func jump():
	velocity.y = -minJump


func applyGravity(delta: float):
	if not is_on_floor():
		var gravity := get_gravity() * baseGravityMult
		var mult := 1.0

		if holdingJump and velocity.y < 0:
			mult *= holdGravityMult

		velocity += gravity * mult * delta


func handleJumpLogic(delta: float):
	if Input.is_action_pressed("Jump"):
		if is_on_floor():
			jump()
			holdingJump = true
			currentJumpHold = 0.0
		elif holdingJump:
			currentJumpHold += delta
			if currentJumpHold > maxHeightHold:
				holdingJump = false
				currentJumpHold = 0.0
		else:
			lastJumpInput = 0.0
	else:
		if holdingJump and velocity.y < 0:
			velocity.y *= releaseVelocityCut

		holdingJump = false
		if lastJumpInput != -1.0 and lastJumpInput < jumpBuffer:
			lastJumpInput += delta
			if is_on_floor():
				jump()
				lastJumpInput = -1.0


func handleMovement(direction: float, delta: float):
	var rate := groundAccel if is_on_floor() else airAccel
	var target: float

	if direction:
		moving(direction)
		walking = true
		target = maxSpeed * direction
	else:
		walking = false
		target = 0.0

	velocity.x = lerpf(velocity.x, target, 1.0 - exp(-rate * delta))


func respawn():
	position = respawnPoint


# InteractSystem
func getClosestInteractable():
	if interactablesInRange.size() > 0:
		var closest: Node2D = interactablesInRange[0]
		for i in interactablesInRange:
			if i.position.distance_to(position) < closest.position.distance_to(position):
				closest = i
		return closest


func checkForInteractions():
	if Input.is_action_just_pressed("Interact"):
		var closest: Interactable = getClosestInteractable()
		if closest:
			if closest.canInteract():
				interact(closest)


func interact(object: Interactable):
	object.interact()


func updateInteractText():
	updateHighlightedInteractable()
	var closest: Interactable = getClosestInteractable()

	if closest && closest.getPopupText() != "":
		var text: String = closest.getPopupText()
		interactText.text = text
		for i in interactableTextPopupTime:
			interactText.modulate.a = move_toward(interactText.modulate.a, 1.0, 1.0 / interactableTextPopupTime)
			await get_tree().process_frame
	else:
		for i in interactableTextPopupTime:
			interactText.modulate.a = move_toward(interactText.modulate.a, 0.0, 1.0 / interactableTextPopupTime)
			await get_tree().process_frame
		interactText.text = ""


# Signals
func genAreaEntered_Area(area: Area2D) -> void:
	if area.get_parent().is_in_group("Interactable"):
		interactablesInRange.append(area.get_parent())
		updateInteractText()


func genAreaExited_Area(area: Area2D) -> void:
	if area.get_parent().is_in_group("Interactable"):
		area.get_parent().unhighlight()
		var interactableIndex: int = interactablesInRange.find(area.get_parent())
		if interactableIndex != -1:
			interactablesInRange.remove_at(interactableIndex)
			updateInteractText()


func updateHighlightedInteractable():
	var closest: Interactable = getClosestInteractable()
	if closest:
		for i in interactablesInRange:
			if i != closest:
				i.unhighlight()
		closest.highlight()


# Runs every frame that the player is inputing either left or right
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
		scale.x = (1 / maxStretch) / (velocity.y / maxStretchSpeed)
