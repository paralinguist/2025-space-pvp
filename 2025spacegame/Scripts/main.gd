extends Node2D

var game_started = false

func _ready() -> void:
		for address in IP.get_local_addresses():
			if (address.split('.').size() == 4) and address != "127.0.0.1":
				$UI/Control/IPLabel.text += " " + address

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	game_started = true

func _on_start_pressed() -> void:
	$UI/Control/Start.visible = false
	$UI.visible = false
	game_started = true
	$RetroShip.start()
	$TechShip.start()
	$TechPortraits/TechPilot.visible = true
	$TechPortraits/TechPilot.speak("Let's gooooo!")
	for c in $Icons.get_children():
		c.visible = true

func show_module(module, team):
	if team == "tech":
		if module == "pilot":
			$Icons/TechPilotProgress.visible = true
		elif module == "science":
			$Icons/TechScienceProgress.visible = true
		elif module == "weapons":
			$Icons/TechWeaponsProgress.visible = true
		elif module == "engineer":
			$Icons/TechEngineerProgress.visible = true
	else:
		if module == "pilot":
			$Icons/RetroPilotProgress.visible = true
		elif module == "science":
			$Icons/RetroScienceProgress.visible = true
		elif module == "weapons":
			$Icons/RetroWeaponsProgress.visible = true
		elif module == "engineer":
			$Icons/RetroEngineerProgress.visible = true

func _process(_delta: float) -> void:
	$Icons/LabelTechMissiles.text = ": " + str($TechShip.missiles)
	$Icons/LabelRetroMissiles.text = ": " + str($RetroShip.missiles)
	if $TechShip.pilot_cooldown:
		$Icons/TechPilotProgress.max_value = $TechShip/PilotTimer.wait_time
		$Icons/TechPilotProgress.value = $TechShip/PilotTimer.time_left
	if $TechShip.science_cooldown:
		$Icons/TechScienceProgress.max_value = $TechShip/ScienceTimer.wait_time
		$Icons/TechScienceProgress.value = $TechShip/ScienceTimer.time_left
	if $TechShip.weapons_cooldown:
		$Icons/TechWeaponsProgress.max_value = $TechShip/WeaponsTimer.wait_time
		$Icons/TechWeaponsProgress.value = $TechShip/WeaponsTimer.time_left
	if $TechShip.overcharged:
		$Icons/TechEngineerProgress.max_value = $TechShip/OverchargeTimer.wait_time
		$Icons/TechEngineerProgress.value = $TechShip/OverchargeTimer.time_left
	if $RetroShip.pilot_cooldown:
		$Icons/RetroPilotProgress.max_value = $RetroShip/PilotTimer.wait_time
		$Icons/RetroPilotProgress.value = $RetroShip/PilotTimer.time_left
	if $RetroShip.science_cooldown:
		$Icons/RetroScienceProgress.max_value = $RetroShip/ScienceTimer.wait_time
		$Icons/RetroScienceProgress.value = $RetroShip/ScienceTimer.time_left
	if $RetroShip.weapons_cooldown:
		$Icons/RetroWeaponsProgress.max_value = $RetroShip/WeaponsTimer.wait_time
		$Icons/RetroWeaponsProgress.value = $RetroShip/WeaponsTimer.time_left
	if $RetroShip.overcharged:
		$Icons/RetroEngineerProgress.max_value = $RetroShip/OverchargeTimer.wait_time
		$Icons/RetroEngineerProgress.value = $RetroShip/OverchargeTimer.time_left

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
	if $TechShip.science_special:
		$Icons/TechScienceProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/TechScienceProgress.tint_under = Color(1, 1, 1, 1)
	if $RetroShip.science_special:
		$Icons/RetroScienceProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/RetroScienceProgress.tint_under = Color(1, 1, 1, 1)
	if $TechShip.pilot_special:
		$Icons/TechPilotProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/TechPilotProgress.tint_under = Color(1, 1, 1, 1)
	if $RetroShip.pilot_special:
		$Icons/RetroPilotProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/RetroPilotProgress.tint_under = Color(1, 1, 1, 1)
	if $TechShip.weapon_special:
		$Icons/TechWeaponsProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/TechWeaponsProgress.tint_under = Color(1, 1, 1, 1)
	if $RetroShip.weapon_special:
		$Icons/RetroWeaponsProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/RetroWeaponsProgress.tint_under = Color(1, 1, 1, 1)
	if $TechShip.engineering_special:
		$Icons/TechEngineerProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/TechEngineerProgress.tint_under = Color(1, 1, 1, 1)
	if $RetroShip.engineering_special:
		$Icons/RetroEngineerProgress.tint_under = Color(0, 0.5, 1, 1)
	else:
		$Icons/RetroEngineerProgress.tint_under = Color(1, 1, 1, 1)

func play_explosion():
	$ShipExplosion.play()
