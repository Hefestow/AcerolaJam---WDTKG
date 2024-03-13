extends Node3D

signal player_entered_chest_area
signal player_left_chest_area
var player_can_interact = false
var chest_open = false
var anim_finished = true
@onready var chatbox = $Chatbox
@export_file("*.json") var d_file
@export var chest_content : bool
var has_interacted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	chatbox.d_file = d_file
	$AnimationPlayer.play("T-pose")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact") and player_can_interact:
				
		has_interacted = true
		chest_open = true
		anim_finished = false
		chatbox.start()
		player_can_interact = false
	else:
		
		anim_finished = false
		chest_open = false


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_entered_chest_area")
		player_can_interact = true
		$Label.visible = true


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("player_left_chest_area")
		player_can_interact = false
		chatbox.close_dialogue()
		
		chest_open = false
		anim_finished = false
		if has_interacted and chest_content:
			body.draw_sword()
			body.sword_drawn = true
		
		
func _on_animation_player_animation_finished(anim_name):
	anim_finished = true

func player_can_interact_func():
	
	anim_finished = false
	player_can_interact = false
	chest_open = false
