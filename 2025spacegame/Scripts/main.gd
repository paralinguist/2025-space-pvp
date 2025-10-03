extends Node2D

var game_started = false

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_start_pressed() -> void:
	$UI/Control/Start.visible = false
	$UI.visible = false
	game_started = true
	$RetroShip.start()
	$TechShip.start()
