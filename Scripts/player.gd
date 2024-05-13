extends XROrigin3D

var cWall

func _on_right_hand_button_pressed(name):
	if cWall and name == "trigger_click":
		cWall.queue_free()
		Messenger.DELETE_WALL.emit(cWall)
	if name == "by_button":
		Messenger.SAVE_WALLS.emit()
	if name == "ax_button":
		Messenger.LOAD_WALLS.emit()

func _on_left_hand_button_pressed(name):
	if name == "ax_button":
		global_position = Vector3.ZERO
		rotation.y = 0

func _on_area_3d_2_area_entered(area):
	cWall = area


func _on_area_3d_2_area_exited(area):
	cWall = null


