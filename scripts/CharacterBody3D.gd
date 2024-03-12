extends CharacterBody3D


const SPEED = 3.0
const ATTACK_RANGE = 2.5
var state_machine
@export var health = 5

@onready var player 
@onready var nav_agent = $NavigationAgent3D
@onready var turn_speed = 2
@onready var animation_tree = $AnimationTree


var alive : bool = true


func _ready():
	player = get_tree().get_first_node_in_group("player")
	state_machine = animation_tree.get("parameters/playback")
	
func _physics_process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z +velocity.z), Vector3.UP)
		"kick":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	#Navigation
	
	#$FacingDirection.look_at(player.position, Vector3.UP)
	rotate_y(deg_to_rad($FacingDirection.rotation.y * turn_speed))
	animation_tree.set("parameters/conditions/attack", _target_in_range())
	animation_tree.set("parameters/conditions/run",!_target_in_range())
	
	animation_tree.get("parameters/playback")
	#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.take_damage(20)
		player.hit(dir)
		
func is_alive() -> bool:
	return alive
	


#func _on_area_3d_body_part_hit(dam, headshot):
	#health -= dam
	#if headshot:
		#pass
	#if health <= 0:
		#animation_tree.set("parameters/conditions/die", true)
		#await get_tree().create_timer(5).timeout
		#queue_free()
		
