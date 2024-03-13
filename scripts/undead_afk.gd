extends CharacterBody3D

var current_state = "idle"
var next_state = "idle"
var previous_state

var has_not_dropped_xp = true

@export var health = 100
@onready var nav = $NavigationAgent3D
@onready var speed = 5.0
@onready var player 
@onready var turn_speed = 2

@onready var blood_spray = preload("res://scenes/blood.tscn")
@onready var xp_drop = preload("res://scenes/xp_drop.tscn")
@onready var animation_player = $AnimationPlayer


func _ready():
	player = get_tree().get_first_node_in_group("player")
	animation_player.set_speed_scale(1.3) 

	
func _physics_process(delta):
	pass

	
	


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Swing":
			next_state = "chase"
		"TakeDamage":
			next_state = "chase"




