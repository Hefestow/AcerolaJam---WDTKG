extends Node2D

@onready var choice_button_tsn =  preload("res://scenes/Choice_button.tscn")

var choice_buttons: Array[Button] = []


func _ready():
	add_choice("This is choice numer zero")
	add_choice("This is choice numer oneO")
	add_choice("This is choice numer tree")
func clear_dialogue_box():
	$VBoxContainer/Text.text  = ""
	for choice in choice_buttons:
		$VBoxContainer.remove_child(choice)
	choice_buttons = []
	
	
func add_text(text: String):
	$VBoxContainer/Text.text = text
	
	
	
	
func add_choice(choice_text: String):
	var button_obj: choicebutton = choice_button_tsn.instantiate()
	button_obj.choice_index = choice_buttons.size()
	choice_buttons.push_back(button_obj)
	button_obj.text = choice_text
	button_obj.choice_selected.connect(_on_choice_selected)
	$VBoxContainer.add_child(button_obj)


func _on_choice_selected(choice_index: int):
	print(choice_index)
