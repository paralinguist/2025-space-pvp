class_name Laser extends ShipModule

var laserspeed := 600
var shot_from := Vector2.ZERO
func _ready() -> void:
	$LaserTimer.wait_time *= 600/laserspeed


func _on_laser_timer_timeout() -> void:
	$LaserRayCast.global_position = shot_from
	$LaserRayCast.force_raycast_update()
	if $LaserRayCast.is_colliding():
		if $LaserRayCast.get_collider() is ShipModule:
			$LaserRayCast.get_collider().get_hit()

func shoot_laser():
	if $Cooldown.is_stopped():
		$LaserParticles.emitting = true
		$LaserTimer.start()
		$Cooldown.is_stopped()
		shot_from = $LaserParticles.global_position
