extends Node3D


@onready var cut_scene = $CutScene
@onready var animation_player = $boss_room/AnimationPlayer

@onready var cutscene = true
# Called when the node enters the scene tree for the first time.


func _ready():
	get_tree().get_first_node_in_group("player").draw_sword()
	get_tree().get_first_node_in_group("player").sword_drawn = true
func _process(delta):
	if Input.is_action_pressed("jump") and cutscene:
		cut_scene.seek(19.0)
		cutscene = false

func end_screen():
	animation_player.play("Ending")

func start_again():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
