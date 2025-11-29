class_name Ship extends Node2D
@export var UI: CanvasLayer
@export var win_message := "Tech Ship Survived"
@export var team := "tech"
const shield  = preload("res://Scenes/shield.tscn")
const GRID_DISTANCE = 32
var left_size := 113*0.615
var right_size := 113*0.615
var hp = 100.0
var alive = true

var dodge_rate := 0.0
var dodge_shoot = false
var dodge_shield = false
var dodge_power = false
var safety_limits_off = false
var advanced_weapons = false

var total_power = 4
var available_power = 1
var pilot_power = 1
var science_power = 1
var weapon_power = 1
var shield_level = 0
var overcharged = false
var precognition = false

var pilot_special = false
var science_special = false
var weapon_special = false
var engineering_special = false

var pilot_cooldown = false
var science_cooldown = false
var weapons_cooldown = false

var missiles = 2
var max_missiles = 12

const engine = preload("res://Scenes/Modules/engine.tscn")
const science = preload("res://Scenes/Modules/science.tscn")
const laser = preload("res://Scenes/Modules/laser.tscn")
const missile = preload("res://Scenes/Modules/missile.tscn")

func _ready():
	spawn()
# Called when the node enters the scene tree for the first time.
func spawn() -> void:
	var new_components : Array[ShipModule] = [engine.instantiate(), science.instantiate(), laser.instantiate(), laser.instantiate(), missile.instantiate()]
	new_components.shuffle()
	for i in range(5):
		add_child(new_components[i])
		new_components[i].position = Vector2(52*i-104, 0)
		new_components[i].visible = false
		if new_components[i] is Engineer:
			if team == "retro":
				new_components[i].set_retro()
		elif new_components[i] is Shooter and new_components[i].weapon_type == "laser":
			if team == "retro":
				new_components[i].set_retro()

func start():
	randomize()
	$LeftWing.visible = true
	$RightWing.visible = true
	$HPBar.visible = true
	for c in get_children():
		if c is ShipModule:
			c.visible = true
	if team == "retro":
		$Retro.visible = true
		$LeftWing.visible = false
		$RightWing.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if alive:
		$HPBar.value = hp
		$HPBar.modulate = Color.from_hsv(hp/280.0, 0.8, 0.9, 1.0)

#dir should be -1 for left and 1 for right
func move(dir:int):
	if not $Engine.deactivated and not pilot_cooldown:
		pilot_cooldown = true
		set_pilot_cooldown()
		$PilotTimer.start()
		position.x += dir*GRID_DISTANCE
		if position.x < left_size or position.x > 1152-right_size:
			position.x -= dir*GRID_DISTANCE
		if dodge_shoot:
			shoot("laser", true)
		if dodge_shield:
			add_shield(true)
		if dodge_power:
			overcharge(1)

func shoot(weapon:String, external=false):
	if external:
		for c in get_children():
			if c is Shooter and not c.deactivated and c.weapon_type in weapon:
				if advanced_weapons:
					c.shoot(3)
				else:
					c.shoot()
					break
	else:
		if not weapons_cooldown and weapon_power > 0:
			if weapon_power >= 4:
				weapon = "lasermissile"
			for c in get_children():
				if c is Shooter and not c.deactivated and c.weapon_type in weapon:
					if c.weapon_type == "missile":
						if missiles > 0:
							missiles = missiles - 1
							c.shoot()
					else:
						c.shoot()
					if c.weapon_type == "laser" and weapon_power >= 6:
						c.shoot(2)
					if weapon_power <= 1:
						break
			weapons_cooldown = true
			$WeaponsTimer.start()

func get_weapons():
	var weapons = {}
	var module_number = 0
	for c in get_children():
		if c is Shooter:
			weapons[module_number] = c.weapon_type
		module_number += 1
	return weapons

func get_status():
	var status = {}
	status["total_power"] = total_power
	status["available_power"] = available_power
	status["pilot_power"] = pilot_power
	status["science_power"] = science_power
	status["weapon_power"] = weapon_power
	status["shield"] = shield_level
	status["hp"] = hp
	return status

func reposition_shields():
	for s in range($ShieldSpot.get_child_count()):
		if s + 1 > shield_level:
			$ShieldSpot.get_child(s).queue_free()
		else:
			$ShieldSpot.get_child(s).position.y = s*-20

func add_shield(external = false):
	if external:
		for c in get_children():
			if c is Science:
				if not c.deactivated:
					$ShieldUpSound.play()
					var new_shield := shield.instantiate()
					$ShieldSpot.add_child(new_shield)
					shield_level += 1
					reposition_shields()
				break
	else:
		if shield_level < 8 and not science_cooldown:
			for c in get_children():
				if c is Science:
					if not c.deactivated:
						$ShieldUpSound.play()
						science_cooldown = true
						set_science_cooldown()
						var new_shield := shield.instantiate()
						$ShieldSpot.add_child(new_shield)
						shield_level += 1
						reposition_shields()
					break

func consume_shield():
	if shield_level >= 1 and not science_cooldown:
		shield_level -= 1
		reposition_shields()
		special("science")
		science_cooldown = true
		set_science_cooldown()
		$ShieldDownSound.play()

func set_pilot_cooldown():
	if pilot_power == 0:
		$PilotTimer.stop()
		$PilotTimer.wait_time = 120
	else:
		if pilot_power == 1:
			$PilotTimer.wait_time = 4
			dodge_rate = 0.0
		elif pilot_power == 2:
			$PilotTimer.wait_time = 3
			dodge_rate = 0.0
		elif pilot_power == 3:
			$PilotTimer.wait_time = 2
			dodge_rate = 0.0
		elif pilot_power == 4:
			$PilotTimer.wait_time = 1
			dodge_rate = 0.0
		elif pilot_power == 5:
			$PilotTimer.wait_time = 0.1
			dodge_rate = 0.0
		elif pilot_power == 6:
			$PilotTimer.wait_time = 0.1
			dodge_rate = 0.5
		$PilotTimer.start()

func set_science_cooldown():
	if science_power <= 0:
		science_cooldown = true
		$ScienceTimer.stop()
		$ScienceTimer.wait_time = 120
	else:
		if science_power == 1:
			$ScienceTimer.wait_time = 8
		elif science_power == 2:
			$ScienceTimer.wait_time = 7
		elif science_power == 3:
			$ScienceTimer.wait_time = 6
		elif science_power == 4:
			$ScienceTimer.wait_time = 5
		elif science_power == 5:
			$ScienceTimer.wait_time = 4
		elif science_power == 6:
			$ScienceTimer.wait_time = 3
		$ScienceTimer.start()

func special(module):
	if not dodge_shoot and not dodge_shield and not dodge_power:
		if module == "pilot" and not pilot_special:
			pilot_special = true
		elif module == "weapons" and not weapon_special:
			weapon_special = true
		elif module == "engineer" and not engineering_special:
			engineering_special = true
		elif module == "science" and not science_special:
			science_special = true
		if pilot_special and weapon_special:
			dodge_shoot = true
			$SpecialTimer.start()
		elif pilot_special and science_special:
			dodge_shield = true
			$SpecialTimer.start()
		elif pilot_special and engineering_special:
			dodge_power = true
			$SpecialTimer.start()
		elif weapon_special and science_special:
			advanced_weapons = true
			shoot("lasers", true)
			advanced_weapons = false
			weapon_special = false
			science_special = false
		elif weapon_special and engineering_special:
			missiles = 12
			advanced_weapons = true
			shoot("missile", true)
			advanced_weapons = false
			weapon_special = false
			science_special = false
		elif science_special and engineering_special:
			safety_limits_off = true
			overcharge(6, true)
			$SpecialTimer.start()
		self.get_parent().refresh_specials()

func set_weapons_cooldown():
	if weapon_power == 0:
		weapons_cooldown = true
		$MissileRegenTimer.stop()
		$WeaponsTimer.stop()
	else:
		if weapon_power == 3:
			$MissileRegenTimer.wait_time = 6
			$MissileRegenTimer.start()
		elif weapon_power == 5:
			$MissileRegenTimer.wait_time = 3
			$MissileRegenTimer.start()
		$WeaponsTimer.start()

#This would be more efficient with int consts or enums, but for this project, strings will do
func power_down(module):
	if module == "pilot" and pilot_power >= 1:
		available_power += 1
		pilot_power -= 1
		set_pilot_cooldown()
	elif module == "science" and science_power >= 1:
		available_power += 1
		science_power -=1
		set_science_cooldown()
	elif module == "weapons" and weapon_power >= 1:
		available_power += 1
		weapon_power -= 1
		set_weapons_cooldown()

#Squinting at this - looks like increasing power to a module will reset the cooldown. Cool, I guess?
func power_up(module):
	if module == "pilot" and available_power >= 1:
		available_power -= 1
		pilot_power += 1
		pilot_cooldown = false
		set_pilot_cooldown()
	elif module == "science" and available_power >= 1:
		available_power -= 1
		science_power +=1
		science_cooldown = false
		set_science_cooldown()
	elif module == "weapons" and available_power >= 1:
		available_power -= 1
		weapon_power += 1
		set_weapons_cooldown()

func take_damage(dmg:float, external=true):
	if external and precognition:
		if randi_range(0,1) and false:
			position.x = left_size
		else:
			position.x = 1152-right_size-GRID_DISTANCE
		precognition = false
	else:
		hp -= dmg*1
		if hp <= 0.0:
			get_parent().play_explosion()
			UI.visible = true
			UI.get_node("Control/End").visible = true
			UI.get_node("Control/End/Label").text = win_message
			UI.get_node("Control/IPLabel").visible = false
			get_parent().game_started = false
			alive = false
			for c in get_children():
				if c is ShipModule:
					c.die()
				else:
					c.queue_free()
			set_process(false)

func overcharge(amount, external = false):
	$PowerUpSound.play()
	available_power += amount
	if amount > 2:
		take_damage(1, false)
	overcharged = true
	if not external:
		$OverchargeTimer.start()
	self.get_parent().update_labels()

func add_missiles(num):
	missiles += num
	if missiles > max_missiles:
		missiles = max_missiles

func emp_hit():
	shield_level = 0
	reposition_shields()

func _on_pilot_timer_timeout() -> void:
	pilot_cooldown = false

func _on_science_timer_timeout() -> void:
	science_cooldown = false

func _on_weapons_timer_timeout() -> void:
	weapons_cooldown = false

func _on_missile_regen_timer_timeout() -> void:
	add_missiles(1)
	if weapon_power < 3:
		$MissileRegenTimer.stop()

#Currently returns all modules to 1 power with 1 available
func _on_overcharge_timer_timeout() -> void:
	overcharged = false
	available_power = 1
	science_power = 1
	weapon_power = 1
	pilot_power = 1
	self.get_parent().update_labels()

func _on_special_timer_timeout() -> void:
	dodge_shoot = false
	dodge_shield = false
	if dodge_power or safety_limits_off:
		dodge_power = false
		safety_limits_off = false
		_on_overcharge_timer_timeout()
	pilot_special = false
	weapon_special = false
	engineering_special = false
	science_special = false
	self.get_parent().refresh_specials()
