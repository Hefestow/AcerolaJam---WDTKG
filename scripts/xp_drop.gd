extends Node3D

var can_interact = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact") and can_interact:
		grab()


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		
func grab():
	pass
