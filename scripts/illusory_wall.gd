extends Node3D

var secret_sound = preload("res://scenes/secret_sound.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_area_entered(area):
	if area.is_in_group("sword"):
		get_parent().get_parent().add_child(secret_sound)
		call_deferred("queue_free")
