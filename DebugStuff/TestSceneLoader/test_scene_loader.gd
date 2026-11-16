#HOW TO USE - after clicking on the node, add you scenes to the Scenes array at the top of the inspector on the right
extends Node2D

@export var scenes:Array[PackedScene]
@onready var button_container: VBoxContainer = $Control/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in scenes:
		var newButton = Button.new()
		newButton.add_theme_font_size_override("font_size",48)
		#AI 1
		newButton.text = i.resource_path.get_file().get_basename()
		button_container.add_child(newButton)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click"):
		for i in button_container.get_child_count():
			var button = button_container.get_child(i)
			if button.is_hovered():
				get_parent().add_child(scenes[i].instantiate())
				queue_free()
		
