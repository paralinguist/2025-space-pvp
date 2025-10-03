class_name Shooter extends ShipModule

@export var bullet_scene : String = "laser_bullet"# = preload("res://Scenes/laser_bullet.tscn")
@export var weapon_type : String = "laser"
@onready var LaserBullet = load("res://Scenes/"+bullet_scene+".tscn")
var shot_from := Vector2.ZERO

func _on_laser_timer_timeout() -> void:
	$LaserRayCast.global_position = shot_from
	$LaserRayCast.force_raycast_update()
	if $LaserRayCast.is_colliding():
		if $LaserRayCast.get_collider() is ShipModule:
			$LaserRayCast.get_collider().get_hit()

func shoot():
	if $Cooldown.is_stopped():
		var new_bullet : Bullet = LaserBullet.instantiate()
		add_child(new_bullet)
		new_bullet.position = Vector2(0, -110)
		$Cooldown.is_stopped()
