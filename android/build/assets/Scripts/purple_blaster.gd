extends XRToolsPickable

@export var bullet_scene: PackedScene

@export var bullet_speed = 10.0

var can_fire = true

func action():
	super.action()
	if can_fire:
		_spawn_bullet()
		can_fire = false
		$Cooldown.start()
		
func _spawn_bullet():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		if bullet:
			bullet.set_as_top_level(true)
			add_child(bullet)
			bullet.transform = $SpawnPoint.global_transform
			bullet.linear_velocity = bullet.transform.basis.z * bullet_speed


func _on_cooldown_timeout():
	can_fire = true
