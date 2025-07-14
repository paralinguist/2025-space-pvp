extends Node2D

const GRID_DISTANCE = 32
var left_size := 113*0.615
var right_size := 113*0.615


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		move(-1)
	if Input.is_action_just_pressed("ui_right"):
		move(1)
#dir should be -1 for left and 1 for right
func move(dir:int):
	position.x += dir*GRID_DISTANCE
	if position.x < left_size or position.x > 1152-right_size:
		position.x -= dir*GRID_DISTANCE
