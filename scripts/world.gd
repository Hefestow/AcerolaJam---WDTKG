extends Node3D


@onready var level_transition_anim = $CanvasLayer/LevelTransitionAnim

@onready var label = $CanvasLayer/Label
@onready var player_cam = $Player/Neck/Head/eyes/Camera3D
@onready var cutscene_cam = $Cutscene/CutsceneCam


func _ready():
	$CanvasLayer/ColorRect.visible = false
	
	var label = get_node("chest")
	if label == null:
		return
	label.player_entered_chest_area.connect(interact_label)
	label.player_left_chest_area.connect(interact_label_hide)
	
func change_level():
	get_tree().change_scene_to_file("res://scenes/world_2.tscn")
	print("ellooo")
	
func level_transition():
	level_transition_anim.play("fade_in_out")

func switch_camera_from_cutscene():
	cutscene_cam.current = false
	player_cam.current = true
	$Player.enable_process()


func interact_label():
	$InteractLabel.visible = true

func interact_label_hide():
	$InteractLabel.visible = false


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.fall_off()
