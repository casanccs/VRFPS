extends Node3D


func _on_area_3d_body_entered(body):
	body.queue_free()
	$Area3D.transform.origin = Vector3(randi_range(-1,0), randi_range(-0.5, 0.5), 0)
