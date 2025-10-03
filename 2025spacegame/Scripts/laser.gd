class_name Laser extends ShipModule

const LaserBullet = preload("res://Scenes/laser_bullet.tscn")

var shot_from := Vector2.ZERO
func _ready() -> void:
	shoot_laser()


func _on_laser_timer_timeout() -> void:
	$LaserRayCast.global_position = shot_from
	$LaserRayCast.force_raycast_update()
	if $LaserRayCast.is_colliding():
		if $LaserRayCast.get_collider() is ShipModule:
			$LaserRayCast.get_collider().get_hit()

func shoot_laser():
	if $Cooldown.is_stopped():
		var new_bullet := LaserBullet.instantiate()
		add_child(new_bullet)
		new_bullet.position = Vector2(0, -110)
		$Cooldown.is_stopped()
