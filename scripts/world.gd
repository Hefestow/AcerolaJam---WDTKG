extends Node3D


@onready var level_transition_anim = $CanvasLayer/LevelTransitionAnim

@onready var label = $CanvasLayer/Label
@onready var player_cam = $Player/Neck/Head/eyes/Camera3D
@onready var cutscene_cam = $Cutscene/CutsceneCam
@onready var undead = preload("res://undead_enemy_final.tscn")
@onready var spawn_points = [$Spawner,$Spawner2,$Spawner3]
@onready var spawn_timer = $SpawnTimer

var enemy_count : int



func _ready():
	$CanvasLayer/ColorRect.visible = false
	$CanvasLayer/LevelTransitionAnim.play("start_game_fade")
	var label = get_node("chest")
	if label == null:
		return
	label.player_entered_chest_area.connect(interact_label)
	label.player_left_chest_area.connect(interact_label_hide)
	var undead_inst = undead.instantiate()
	


func change_level():
	get_tree().change_scene_to_file("res://scenes/world_2.tscn")
	
	
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



func start_boss():
	pass


func areAllEnemiesDead():
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		if enemy.is_alive():  # Assuming you have a method like is_alive() to check if the enemy is still alive
			return false
			
	return true






func _on_start_boss_fight_area_body_entered(body):
	if body.is_in_group("player"):
		body.fall_off()


func _on_start_boss_area_body_entered(body):
	$NavigationRegion3D/Door.close()
	spawn_timer.start()
	enemy_count = 4
	start_boss()


func _on_spawn_timer_timeout():
	enemy_count -= 1
	if enemy_count >= 0:
		for enemy in spawn_points:
			var undead_inst = undead.instantiate()
			undead_inst.global_position = enemy.global_position
			add_child(undead_inst)
