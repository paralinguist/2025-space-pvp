class_name SpeechBubble extends Label

var origin := Vector2.ZERO
var count = 0
var text_speed := 6
var pressed := false
signal close_text
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_type(horiz, vert):
	var preset_lookup = {"Left" : {"Top": Control.PRESET_TOP_LEFT, "Bottom": Control.PRESET_BOTTOM_LEFT}, "Right": {"Top": Control.PRESET_TOP_RIGHT, "Bottom": Control.PRESET_BOTTOM_RIGHT}}
	set_anchors_and_offsets_preset(preset_lookup[horiz][vert])
	if horiz == "Left":
		set_h_grow_direction(GROW_DIRECTION_END)
	else:
		set_h_grow_direction(GROW_DIRECTION_BEGIN)
	
	if vert == "Top":
		set_v_grow_direction(GROW_DIRECTION_BEGIN)
	else:
		set_v_grow_direction(GROW_DIRECTION_END)
	for c in $Panel.get_children():
		c.visible = c.name == vert+horiz


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		if visible_ratio < 1.0:
			count += 1
			count = count % text_speed
			if count == 0:
				visible_characters += 1
		#update_minimum_size()
		reset_size()

func show_text(txt: String, speed: int = 6):
	text = txt
	visible_characters = 0
	visible_ratio = 0.0
	count = 0
	visible = true
