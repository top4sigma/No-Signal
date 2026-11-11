extends Node2D

class_name Interactable

@export var popupText:String = "E"

@export_group("Nodes")
@export var popupTextLabel:Label
@export var sprite:Sprite2D
@export_group("Effects")
@export var showText:bool = false
@export var highlightText:String = ""
@export var textFadeTime:int = 10
@export var grow:bool = false
@export var growFactor:float = 1.1
@export var growFrames:int = 10

var grown = false
var highlightTextShown = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact():
	queue_free()
func getPopupText() -> String:
	return popupText
func highlight():
	if showText:
		if popupTextLabel:
			if not highlightTextShown:
				highlightTextShown = true
				popupTextLabel.modulate.a = 0
				popupTextLabel.text = highlightText
				for i in textFadeTime:
					if highlightTextShown:
						popupTextLabel.modulate.a = move_toward(popupTextLabel.modulate.a,1.0,1.0 / textFadeTime)
						await get_tree().process_frame
				if highlightTextShown:
					popupTextLabel.modulate.a = 1
	if grow:
		if not grown:
			grown = true
			for i in growFrames:
				if grown:
					sprite.scale.x = move_toward(sprite.scale.x,growFactor,growFactor / growFrames)
					sprite.scale.y = sprite.scale.x
					await get_tree().process_frame
func unhighlight():
	if showText:
		if popupTextLabel:
			if highlightTextShown:
				highlightTextShown = false
				popupTextLabel.text = highlightText
				for i in textFadeTime:
					if not highlightTextShown:
						popupTextLabel.modulate.a -=  move_toward(popupTextLabel.modulate.a,0,1.0 / textFadeTime)
						await get_tree().process_frame
				if not highlightTextShown:
					popupTextLabel.modulate.a = 0
	if grow:
		if grown:
			grown = false
			for i in growFrames:
				if not grown:
					sprite.scale.x = move_toward(sprite.scale.x,1,growFactor / growFrames)
					sprite.scale.y = sprite.scale.x
					await get_tree().process_frame
func canInteract() -> bool:
	return true
