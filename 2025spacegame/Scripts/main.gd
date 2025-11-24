extends Node2D

var game_started = false

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_start_pressed() -> void:
	$UI/Control/Start.visible = false
	$UI.visible = false
	game_started = true
	$RetroShip.start()
	$TechShip.start()
	$TechPortraits/TechPilot.visible = true
	$TechPortraits/TechPilot.speak("Let's gooooo!")

func _process(_delta: float) -> void:
	$Icons/LabelTechMissiles.text = ": " + str($TechShip.missiles)
	$Icons/LabelRetroMissiles.text = ": " + str($RetroShip.missiles)
	if $TechShip.pilot_cooldown:
		$Icons/TechPilotProgress.max_value = $TechShip/PilotTimer.wait_time
		$Icons/TechPilotProgress.value = $TechShip/PilotTimer.time_left
	if $TechShip.science_cooldown:
		$Icons/TechScienceProgress.max_value = $TechShip/ScienceTimer.wait_time
		$Icons/TechScienceProgress.value = $TechShip/ScienceTimer.time_left

func update_labels():
	$Icons/LabelTechEngPwr.text = str($TechShip.available_power)
	$Icons/LabelTechPilotPwr.text = str($TechShip.pilot_power)
	$Icons/LabelTechSciencePwr.text = str($TechShip.science_power)
	$Icons/LabelTechWeapPwr.text = str($TechShip.weapon_power)
	$Icons/LabelRetroEngPwr.text = str($RetroShip.available_power)
	$Icons/LabelRetroPilotPwr.text = str($RetroShip.pilot_power)
	$Icons/LabelRetroSciPwr.text = str($RetroShip.science_power)
	$Icons/LabelRetroWeapPwr.text = str($RetroShip.weapon_power)

func refresh_specials():
	print("Refreshing specials")
	if $TechShip.science_special:
		print("Modulating science")
		$Icons/TechScienceProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/TechScienceProgress.tint_under = Color(1, 1, 1, 1)
	if $RetroShip.science_special:
		print("Modulating science")
		$Icons/RetroSciIcon.self_modulate = Color(0, 0.5, 1, 1)
	else:
		$Icons/RetroSciIcon.self_modulate = Color(1, 1, 1, 1)
