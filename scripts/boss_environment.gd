extends Node3D


@onready var cut_scene = $CutScene

@onready var cutscene = true
# Called when the node enters the scene tree for the first time.




func _process(delta):
	if Input.is_action_pressed("jump") and cutscene:
		cut_scene.seek(19.0)
		cutscene = false
