class_name Ship extends Node2D
@export var UI: CanvasLayer
@export var win_message := "Tech Ship Survived"
const shield  = preload("res://Scenes/shield.tscn")
const GRID_DISTANCE = 32
var left_size := 113*0.615
var right_size := 113*0.615
var hp = 100.0
var alive = true

var total_power = 4
var available_power = 1
var pilot_power = 1
var science_power = 1
var weapon_power = 1

var pilot_special = false
var science_special = false
var weapon_special = false
var engineering_special = false

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
func _process(delta: float) -> void:
	if alive:
		$HPBar.value = hp
		$HPBar.modulate = Color.from_hsv(hp/280.0, 0.8, 0.9, 1.0)

#dir should be -1 for left and 1 for right
func move(dir:int):
	if not $Engine.deactivated:
		position.x += dir*GRID_DISTANCE
		if position.x < left_size or position.x > 1152-right_size:
			position.x -= dir*GRID_DISTANCE

func shoot(idx:int):
	var laser_count := 0
	for c in get_children():
		if c is Shooter:
			if idx == laser_count:
				if not c.deactivated:
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

func reposition_shields():
	for s in range($ShieldSpot.get_child_count()):
		$ShieldSpot.get_child(s).position.y = s*-20

func add_shield():
	for c in get_children():
		if c is Science:
			if not c.deactivated:
				var new_shield := shield.instantiate()
				$ShieldSpot.add_child(new_shield)
				reposition_shields()
			break

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
