extends StaticBody3D

var toggle = false
var interactable = true
@export var animation_player: AnimationPlayer
var has_not_opened = true 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#func interact():
	#if interactable == true:
		#interactable = false
		#toggle = !toggle
		#if toggle == false:
			#animation_player.play("close")
		#if toggle == true:
			#animation_player.play("open")
		#await get_tree().create_timer(0.6, false).timeout
		#interactable = true






func _on_area_3d_body_entered(body):
	if body.is_in_group("player") and has_not_opened:
		print("BIG GAY OKERSON")
		animation_player.play("open")
		$"../../AudioStreamPlayer".playing = true
		body.cum()
		has_not_opened = false
		await get_tree().create_timer(1).timeout
		get_tree().get_first_node_in_group("world").level_transition()
