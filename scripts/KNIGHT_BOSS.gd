extends CharacterBody3D

var current_state = "idle"
var next_state = "idle"
var previous_state
var canMove = true
var has_not_dropped_xp = true



@export var health = 100
@onready var nav = $NavigationAgent3D
@onready var speed = 105.0
@onready var player 
@onready var turn_speed = 2
@onready var marker_3d = $"../Marker3D"

@onready var blood_spray = preload("res://scenes/bloodsplatter_boss.tscn")
@onready var xp_drop = preload("res://scenes/xp_drop.tscn")
@onready var animation_player = $AnimationPlayer
var gravity = 970

func _ready():
	player = get_tree().get_first_node_in_group("player")
	next_state = "chase"

	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if previous_state != current_state:
		$StateLabel.text = current_state
		$StateLabel2.text = current_state
	previous_state = current_state
	current_state = next_state
	
	match current_state:
		"idle":
			idle()
		"bite":
			bite(delta)
		"chase":
			chase(delta)
		"flinch":
			flinch(delta)
			


func chase(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if previous_state != current_state:
		animation_player.play("Walk")
		
	velocity = (nav.get_next_path_position() - position).normalized() * speed * delta
	$FaceDirection.look_at(player.position, Vector3.UP)
	rotate_y(deg_to_rad($FaceDirection.rotation.y * turn_speed))
	
	if player.position.distance_to(position) < 7:
		next_state = "bite"
		
	if player.position.distance_to(position) > 1:
		nav.target_position = player.position
		move_and_collide(velocity)
		
func idle():
	if previous_state != current_state:
		animation_player.play("Swing")
	
func bite(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if previous_state != current_state:
		$FaceDirection.look_at(player.position, Vector3.UP)
		rotate_y(deg_to_rad($FaceDirection.rotation.y * (turn_speed *20)))
		animation_player.play("Swing")
	
func flinch(delta):
	#velocity = -(nav.get_next_path_position() - position). normalized() * (speed/14) * delta
	#move_and_collide(velocity)
	animation_player.play("Hurt")


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		next_state = "idle"

func take_damage(num):
	print("ouchies")
	next_state = "flinch"
	var blood = blood_spray.instantiate()
	blood.emitting = true
	blood.position = position
	get_parent().add_child(blood)
	var offset = Vector3(0,0,0)
	blood.position += offset
	
	
	
	health -= num
	if health <= 0:
		get_tree().get_first_node_in_group("main").end_screen()
		call_deferred("queue_free")
	print(health)
	#print("we took ", num, "dmg")
	
func spawn_ddddddrop_around_enemy():

	# Define a radius for the drop spawn area
	var spawn_radius = 1.0  # Adjust this value based on your game's needs

	# Generate random offset values
	var offset_x = randf() * 2.0 - 1.0  # Random value between -1 and 1
	var offset_y = randf() * 2.0 - 1.0  # Random value between -1 and 1
	var offset_z = randf() * 2.0 - 1.0  # Random value between -1 and 1

	# Normalize the offset vector and scale it by the spawn radius
	var offset = Vector3(offset_x, offset_y, offset_z).normalized() * spawn_radius

	# Calculate the drop's position relative to the enemy
	var drop_position = global_transform.origin + offset

	# Instantiate the drop at the calculated position
	var drop_instance = xp_drop.instantiate()
	drop_instance.global_transform.origin = drop_position
	get_parent().add_child(drop_instance)

	
	


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Swing":
			next_state = "chase"
		"Hurt":
			next_state = "chase"



#func _on_area_3d_body_entered(body):
	#if body.is_in_group("player"):
		#body.take_damage(20)



func _on_take_damage_area_area_entered(area):
	print($TakeDMGTimer.time_left )
	if area.is_in_group("sword"):
		if $TakeDMGTimer.time_left == 0:
			#play_hurt_sfx()
			
			take_damage(20)
			$TakeDMGTimer.start(.5)

func play_hurt_sfx():
	$AudioStreamPlayer.pitch_scale = randf_range(.7,.8)
	$AudioStreamPlayer.play()
	
func deflect():
	take_damage(100)
	print("PARRIED, CASUAL!")


func _on_cut_scene_animation_finished(anim_name):
	match anim_name:
		"new_animation":
			$"../../CanvasLayer/ColorRect3".visible = false
			next_state = "chase"
			position = marker_3d.position
			$Pivot.rotation.y = deg_to_rad(90)








func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(5)

