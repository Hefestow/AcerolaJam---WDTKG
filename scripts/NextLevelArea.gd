extends Area3D

@export var next_location : PackedScene
@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		animation_player.play("level_transition")
		await animation_player.animation_finished
		get_tree().change_scene_to_file("res://scenes/boss_environment.tscn")
		
