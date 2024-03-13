extends CharacterBody3D

var current_state = "idle"
var next_state = "idle"
var previous_state

var has_not_dropped_xp = true
var alive : bool = true
@export var health = 50
@onready var nav = $NavigationAgent3D
@onready var speed = 10.0
@onready var player 
@onready var turn_speed = 2


@onready var navigation_agent = $NavigationAgent3D

@onready var blood_spray = preload("res://scenes/bloodsplatter.tscn")
@onready var xp_drop = preload("res://scenes/xp_drop.tscn")
@onready var animation_player = $AnimationPlayer
#var gravity = 9.8

func _ready():
	player = get_tree().get_first_node_in_group("player")
	animation_player.set_speed_scale(1) 

	
func _physics_process(delta):
	velocity = Vector3.ZERO
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	#else:
		#velocity.y -= 2
	
	if previous_state != current_state:
		$StateLabel.text = current_state
	previous_state = current_state
	current_state = next_state
	
	match current_state:
		"idle":
			idle()
		"bite":
			bite()
		"chase":
			chase(delta)
		"flinch":
			flinch(delta)
			


func chase(delta):
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	#else:
		#velocity.y -= 2
	if previous_state != current_state:
		animation_player.play("Running state")
		
	#velocity = (nav.get_next_path_position() - position).normalized() * speed * delta
	var current_location = global_transform.origin
	var new_location = navigation_agent.get_next_path_position()
	var new_velocity = (new_location - current_location).normalized() * speed * delta
	
	navigation_agent.set_velocity_forced(new_velocity)
	
	
	$FaceDirection.look_at(player.position, Vector3.UP)
	rotate_y(deg_to_rad($FaceDirection.rotation.y * turn_speed))
	
	if player.position.distance_to(position) < 3:
		next_state = "bite"
		
	if player.position.distance_to(position) > 1:
		nav.target_position = player.position
		
		
func idle():
	next_state = "chase"
	if previous_state != current_state:
		animation_player.play("Rest-loop")
	
func bite():
	if previous_state != current_state:
		$FaceDirection.look_at(player.position, Vector3.UP)
		rotate_y(deg_to_rad($FaceDirection.rotation.y * (turn_speed *20)))
		animation_player.play("Swing")
	
func flinch(delta):
	#velocity = -(nav.get_next_path_position() - position). normalized() * (speed) * delta
	#move_and_collide(velocity)
	animation_player.play("Hurt")


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		next_state = "idle"
		
		
func is_alive() -> bool:
	return alive
	
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
	if health <= 0 and has_not_dropped_xp:
		for i in range(5):
			pass
			#spawn_drop_around_enemy()
		has_not_dropped_xp = false
		call_deferred("queue_free")
	print(health)
	#print("we took ", num, "dmg")
	
func spawn_drop_around_enemy():

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



func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(20)



func _on_take_damage_area_area_entered(area):
	
	if $TakeDMGTimer.time_left == 0:
		play_hurt_sfx()
		take_damage(20)
		$TakeDMGTimer.start(.5)

func play_hurt_sfx():
	$AudioStreamPlayer.pitch_scale = randf_range(.7,.8)
	$AudioStreamPlayer.play()
	
func deflect():
	take_damage(50)
	print("PARRIED, CASUAL!")


func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(5)


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

func update_target_location(target_location):
	navigation_agent.set_target_position(target_location)
