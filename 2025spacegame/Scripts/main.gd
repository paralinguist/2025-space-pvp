extends Node2D

var game_started = false

func _on_restart_pressed() -> void:
	pass # Replace with function body.
	#


func _on_start_pressed() -> void:
	$UI/Control/Start.visible = false
	$UI.visible = false
	game_started = true
	$RetroShip.start()
	$TechShip.start()
