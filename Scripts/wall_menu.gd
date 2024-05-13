extends Control



func _on_spin_box_value_changed(value):
	Messenger.WALL_HEIGHT.emit(value)


func _on_spin_box_2_value_changed(value):
	Messenger.WORLD_HEIGHT.emit(value)
