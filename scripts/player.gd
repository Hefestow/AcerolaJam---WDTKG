class_name Player extends CharacterBody3D



@onready var head = $Neck/Head
@onready var neck = $Neck
@export var health = 10
@onready var crouched_collision = $crouched_collision
@onready var standing_collision = $standing_collision
@onready var ray_cast_3d = $RayCast3D
@onready var camera = $Neck/Head/eyes/Camera3D
@onready var eyes = $Neck/Head/eyes
@onready var label = $"../CanvasLayer/Label"
@onready var label_2 = $"../CanvasLayer/Label2"

@onready var sword_player = $Neck/Head/eyes/SwordPlayer
@onready var footsteps = $Footsteps
@onready var footstep_timer = $FootstepTimer
@onready var footsteps_sound = $Footsteps2
@onready var animation_player = $Neck/Head/eyes/AnimationPlayer



var sword_drawn = false
var slide_timer = 0.0
var slider_timer_max = 1.2


var current_speed = 5.0
@export var parry_area : Area3D
@export var reset_position : Marker3D


@export var walking_speed = 5.0
@export var sprint_speed = 10.0
@export var crouch_speed = 3.0

var direction = Vector3.ZERO
var jump_velocity = 4.5
var crouch_depth = -0.5
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

var air_lerp_speed = 3.0
var lerp_camera_fov = 2.5
var lerp_speed = 4.0
var lerp_slide_speed = 50

const mouse_sens = 0.25
const starting_fov : float = 75
var free_look_tilt = 7

#States

var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#HeadBob

const head_bob_sprint = 22.0
const head_bob_walk = 14.0
const head_bob_crouch = 5.0

const head_bob_crouch_int = 0.05
const head_bob_sprint_int = 0.02
const head_bob_walk_int = 0.1

var head_bob_vector = Vector2.ZERO
var head_bob_index = 0.0
var head_bob_current_int = 0.0


var slide_duration = 0.5  # Time required to cancel the slide (in seconds)
var slide_cancel_time = 0.0  # Timer to track how long the slide button has been held

@export var jump_buffer_timer: float = .1
var jump_buffer = false
var jump_avaliable = true


var slideCooldown = 2.0  # Adjust the cooldown time as needed
var canSlide = true

var input_enabled = true
var can_attack = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Neck/Head/eyes/sword.visible = false
	enable()
	
	

	# Connect signals from the cutscene
	
func _input(event):
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-120),deg_to_rad (120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-59),deg_to_rad (59))
		
		
		
func _physics_process(delta):
	if not input_enabled:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		return
	#  velocity label
	#label.text = "Velocity.x :" + str(velocity.x)
	#label_2.text =  "Velocity.z :" + str(velocity.z)
	if sword_drawn:
		use_sword()
	
	# Input
	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	
	

	
	
	
	if Input.is_action_pressed("crouch") || sliding:
		current_speed = move_toward(current_speed,crouch_speed , delta)
		head.position.y = lerp(head.position.y, crouch_depth, delta * lerp_speed)
		
		standing_collision.disabled = true
		crouched_collision.disabled = false
		
		if sprinting && input_dir != Vector2.ZERO && canSlide:
			#current_speed = lerp(current_speed,sprint_speed *5, delta* lerp_speed)
			current_speed = 235.0
			current_speed = move_toward(current_speed,crouch_speed , delta)
			#current_speed = lerp(current_speed ,100.0, delta * lerp_slide_speed)
			sliding = true
			slide_timer = slider_timer_max
			slide_vector = input_dir
			free_looking = true
			canSlide = false
			$Timer.start(slideCooldown)
			print("Slide begin")
		
		
		walking = false
		sprinting = false
		crouching = true
		
		
	elif !ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		standing_collision.disabled = true
		crouched_collision.disabled = false
	else:
		sliding = false
		
	if Input.is_action_pressed("sprint") and input_dir :
		
		walking = false
		sprinting = true
		crouching = false
		#if Input.is_action_pressed("crouch"):
			#current_speed = lerp(current_speed,crouch_speed, delta * lerp_speed)
			#return
		current_speed = lerp(current_speed,sprint_speed, delta * lerp_speed)
		camera.fov = lerp(camera.fov, 95.0, delta * lerp_camera_fov)
		
		
	else:
		current_speed = lerp(current_speed,walking_speed, delta * lerp_speed)
		camera.fov = lerp(camera.fov, starting_fov, delta * lerp_camera_fov)
		walking = true
		sprinting = false
		crouching = false
		

# Handle fFREEEE LOOOKING
	if Input.is_action_pressed("free_look") or sliding:
		
		free_looking = true
		if sliding && is_on_floor():
			eyes.rotation.z = lerp(eyes.rotation.z,-deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = lerp(eyes.rotation.z,-deg_to_rad(neck.rotation.y * free_look_tilt), delta* lerp_speed)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerp_speed)
		
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
			canSlide = true
			print("Slide end")

	# HEADBOB HERE
	if sprinting:
		head_bob_current_int = head_bob_sprint_int
		head_bob_index += head_bob_sprint * delta
	elif walking:
		head_bob_current_int = head_bob_walk_int
		head_bob_index += head_bob_walk * delta
	elif crouching:
		head_bob_current_int = head_bob_crouch_int
		head_bob_index += head_bob_crouch * delta
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bob_vector.y = sin(head_bob_index)
		head_bob_vector.x = sin(head_bob_index/2) +0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bob_vector.y * (head_bob_current_int / 2 ), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bob_vector.x * head_bob_current_int, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)
	
	
	
		
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if jump_avaliable:
			jump()
			
			
			
			
			
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_timer).timeout.connect(on_jump_buffer_timeout)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
		
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0 ,slide_vector.y)).normalized() 
		current_speed = (slide_timer + 0.1) * slide_speed
		
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		

	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if jump_buffer:
			jump()
			jump_buffer = false
		
	if input_dir != Vector2.ZERO:
		if is_on_floor() and sliding == false:
			animation_player.play("walk")
		
		


#func check_slide_cancel():
	## Update the slide timer
	#slide_cancel_time += get_process_delta_time()
	## Check if the slide button has been held for the required duration
	#if slide_cancel_time >= slide_duration:
		#sliding = false
		## Cancel the slide here
		#slide_cancel_time = 0.0  # Reset the timer after canceling the slide
	## If the slide button is released, reset the timer
	#if not Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		#slide_cancel_time = 0.0
	#
#func check_slide_input():
	#var input_vector = Vector2()
	#if Input.is_action_pressed("right"):
		#input_vector.x += 1
		#check_slide_cancel()
	#elif Input.is_action_pressed("left"):
		#input_vector.x -= 1
		#check_slide_cancel()
	
	# Apply movement based on input_vector...
	# (You may have your own movement logic here)
	#if velocity.length() > 0.2 or velocity.length() > -0.2 and is_on_floor():
		#footsteps_sound.play()
		#print(velocity)
		#if not footsteps_sound.playing:
			#footsteps_sound.play()
	#else:
		## Player is not moving, stop footsteps_sound sound
		#footsteps_sound.stop()
		
	move_and_slide()
	
func draw_sword():
	$Neck/Head/eyes/sword.visible = true
	sword_player.play("draw_sword")
	
func jump()-> void:
	jump_avaliable = false
	if sliding:
		velocity.y = jump_velocity * 1.5
			
	else:
		velocity.y = jump_velocity
		sword_player.play("jump")
		sliding = false
		
func on_jump_buffer_timeout() -> void:
	jump_buffer = false


func enable_process():
	set_process_input(true)
	
	
	
func foot_steps_audio():
	footsteps.pitch_scale = randf_range(.8,1.2)
	footsteps.play()

func disable():
	input_enabled = false
func enable():
	input_enabled = true

func take_damage(num):
	$InvulnTimer.start
	if $InvulnTimer.time_left == 0:
		
		health -= num
		print(health)
		if health <= 0:
			$PlayerHit.play()
			set_physics_process(false)
			set_process(false)
			
			var tween = create_tween()
			tween.tween_property(camera, "position", Vector3(0,-0.5,0), 1.5).set_delay(.2)
			
			tween.tween_property(camera, "rotation", Vector3(0,0,1), 1.5)
			
			await tween.finished
			$CanvasLayer/TextureButton2.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
		else:
			$PlayerHit.play()
		update_health()
	
func use_sword():
	if Input.is_action_just_pressed("swing") && can_attack:
		can_attack = false
		sword_player.play("sword_swing")
	#if Input.is_action_just_pressed("parry") && can_attack:
		#can_attack = false
		#sword_player.play("parry_attack")
	
	

func parry():
	
	var parry_targets = parry_area.get_overlapping_areas()
	if parry_targets.size() > 0:
		for area in parry_targets:
			if area.is_in_group("parriable"):
				area.get_parent().deflect()

func update_health():
	pass
	#health_label.text = str(health)

func _on_sword_player_animation_finished(anim_name):
	
	if anim_name == "sword_swing":
		can_attack = true
		
	if anim_name == "parry_attack":
		can_attack = true
		
func fall_off():
	animation_player.play("fade_to_blk")
	await animation_player.animation_finished
	draw_sword()
	
func restart_area():
	position = reset_position.position




func _on_texture_button_2_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	
