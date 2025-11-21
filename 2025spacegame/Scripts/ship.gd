class_name Ship extends Node2D
@export var UI: CanvasLayer
@export var win_message := "Tech Ship Survived"
const shield  = preload("res://Scenes/shield.tscn")
const GRID_DISTANCE = 32
var left_size := 113*0.615
var right_size := 113*0.615
var hp = 100.0
var alive = true
var dodge_rate := 0.0

var total_power = 4
var available_power = 1
var pilot_power = 1
var science_power = 1
var weapon_power = 1
var shield_level = 0

var pilot_special = false
var science_special = false
var weapon_special = false
var engineering_special = false

var pilot_cooldown = false
var science_cooldown = false
var weapons_cooldown = false

var missiles = 2

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
func start():
	randomize()
	for c in get_children():
		if c is ShipModule:
			c.visible = true

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

func set_pilot_cooldown():
	if pilot_power == 0:
		$PilotTimer.stop()
		$PilotTimer.wait_time = 120
	elif pilot_power == 1:
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

func shoot(idx:int):
	if not weapons_cooldown and weapon_power > 0:
		var laser_count := 0
		for c in get_children():
			if c is Shooter:
				if idx == laser_count or weapon_power >= 2:
					if not c.deactivated:
						weapons_cooldown = true
						$WeaponsTimer.start()
						c.shoot()
					break
			laser_count += 1

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
		$ShieldSpot.get_child(s).position.y = s*-20

func add_shield():
	if shield_level < 8 and not science_cooldown:
		for c in get_children():
			if c is Science:
				if not c.deactivated:
					science_cooldown = true
					set_science_cooldown()
					var new_shield := shield.instantiate()
					$ShieldSpot.add_child(new_shield)
					reposition_shields()
					shield_level += 1
				break

func consume_shield():
	if shield_level >= 1 and not science_cooldown:
		science_special = true
		science_cooldown = true
		set_science_cooldown()

func set_science_cooldown():
	if science_power == 0:
		science_cooldown = true
		$ScienceTimer.stop()
		$ScienceTimer.wait_time = 120
	elif science_power == 1:
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

func take_damage(dmg:float):
	hp -= dmg*1
	if hp <= 0.0:
		UI.visible = true
		UI.get_node("Control/End").visible = true
		UI.get_node("Control/End/Label").text = win_message
		alive = false
		for c in get_children():
			if c is ShipModule:
				c.die()
			else:
				c.queue_free()
		set_process(false)


func _on_pilot_timer_timeout() -> void:
	pilot_cooldown = false


func _on_science_timer_timeout() -> void:
	science_cooldown = false


func _on_weapons_timer_timeout() -> void:
	weapons_cooldown = false
