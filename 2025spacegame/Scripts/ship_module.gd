class_name ShipModule extends Area2D

var deactivated := false
var respawn_timer : Timer = null

func _process(delta: float):
	if deactivated:
		modulate = Color("#777777FF")
	else:
		modulate = Color("#FFFFFFFF")

func get_hit(dmg:float):
	deactivated = true
	if respawn_timer:
		respawn_timer.queue_free()
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = 5.0
	respawn_timer.start()
	respawn_timer.connect("timeout", respawn)
	get_parent().take_damage(dmg)

func respawn():
	if respawn_timer:
		respawn_timer.queue_free()
	deactivated = false


func die():
	var death_tween := get_tree().create_tween()
	death_tween.set_parallel(true)
	death_tween.tween_property(self, "rotation", (randi_range(0, 1)*2-1)*randf_range(40, 100), 4)
	death_tween.tween_property(self, "position", Vector2.from_angle(randf()*TAU)*randf_range(600, 3000), 4)
	death_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 4)
	death_tween.chain().tween_callback(queue_free)
	death_tween.play()
