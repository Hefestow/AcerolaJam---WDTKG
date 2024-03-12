extends StaticBody3D

var toggle = false
var interactable = true
@export var animation_player: AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("close")
		if toggle == true:
			animation_player.play("open")
		await get_tree().create_timer(0.6, false).timeout
		interactable = true


