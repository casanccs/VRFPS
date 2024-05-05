extends XROrigin3D

var cWall


func _on_right_hand_button_pressed(name):
	if cWall and name == "trigger_click":
		cWall.queue_free()


func _on_area_3d_2_area_entered(area):
	cWall = area


func _on_area_3d_2_area_exited(area):
	cWall = null
