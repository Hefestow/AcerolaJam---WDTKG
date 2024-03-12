extends RayCast3D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		var hitobj = get_collider()
		if hitobj != null:
			if hitobj.has_method("interact") and Input.is_action_just_pressed("interact"):
				hitobj.interact()
			else:
				return
		

