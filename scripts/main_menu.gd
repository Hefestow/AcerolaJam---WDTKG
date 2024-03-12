extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuSound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	$AnimationPlayer.play("fade_to_black")
	$StartSound.play()
	
	
func start_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
