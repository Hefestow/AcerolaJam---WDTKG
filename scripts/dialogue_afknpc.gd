extends Control


@onready var rich_text_label = $Panel/RichTextLabel
@export var label : Label
@export_file("*.json") var d_file

signal dialogue_finished

var dialogue = []
var current_dialogue_id = 0 
var d_active = false
var dialogue_len = dialogue.size()

var draw_text_speed = 0 
var chatterlimit: int = 120

func _ready():
	$Panel.visible = false
	
	
func start():
	if d_active:
		return
	print(d_file)
	d_active = true
	$Panel.visible = true
	
	dialogue = load_dialogue()
	if label != null:
		label.visible = false
	if current_dialogue_id >= 10:
		current_dialogue_id = 10
		next_script()
		return
		
	current_dialogue_id = -1
	next_script()
	
func load_dialogue():
	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if !d_active:
		return
	if event.is_action_pressed("interact"):
		if rich_text_label.visible_characters < dialogue_len:
			rich_text_label.visible_characters = dialogue_len
			
			$Timer.stop()
			return
		else:
			next_script()
			

			
			
func close_dialogue():
	d_active = false
	$Panel.visible = false
	get_parent().player_can_interact_func()
	
func next_script():
	
	draw_text_speed = 0
	rich_text_label.visible_characters = 0
	if current_dialogue_id == 5:
		pass
	if current_dialogue_id >= 10:
		current_dialogue_id = 10
		rich_text_label.text = dialogue[current_dialogue_id]["text"]
		$Timer.start(.08)
		return
		
		
	current_dialogue_id += 1
		
		
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$Panel.visible = false
		emit_signal("dialogue_finished")
		return
	rich_text_label.text = dialogue[current_dialogue_id]["text"]
	$Timer.start(.08)
	
	
#func show_chatter():
	#
	#if draw_text_speed < chatterlimit:
		#draw_text_speed += 1
		#$Panel/RichTextLabel.visible_characters = draw_text_speed

func _process(delta):
	#show_chatter()
	
	pass

func _on_timer_timeout():
	if draw_text_speed < chatterlimit:
		draw_text_speed += 2
		$Panel/RichTextLabel.visible_characters = draw_text_speed
	else:
		return


func _on_button_pressed():
	pass # Replace with function body.


func _on_no_pressed():
	close_dialogue()
