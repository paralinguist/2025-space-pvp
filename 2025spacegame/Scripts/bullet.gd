class_name Bullet extends Node2D
@export var speed = 600
@export var dmg := 10.0
var delay_time = 0.35
var glob_x := 0

func _ready():
	glob_x = global_position.x

func _process(delta: float) -> void:
	delay_time -= delta
	position.y -= speed*delta
	global_position.x = glob_x
	if delay_time <= 0:
		if $RayCast2D.is_colliding():
			if $RayCast2D.get_collider() is ShipModule or $RayCast2D.get_collider() is Shield:
				$RayCast2D.get_collider().get_hit(dmg)
				queue_free()


func _on_timer_timeout() -> void:
	queue_free()
