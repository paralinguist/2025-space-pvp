class_name ShipModule extends Area2D

var deactivated := false
var respawn_timer : Timer = null

func _process(delta: float):
	if deactivated:
		modulate = Color("#777777FF")
	else:
		modulate = Color("#FFFFFFFF")

func get_hit():
	deactivated = true
	if respawn_timer:
		respawn_timer.queue_free()
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = 5.0
	respawn_timer.start()
	respawn_timer.connect("timeout", respawn)

func respawn():
	if respawn_timer:
		respawn_timer.queue_free()
	deactivated = false
