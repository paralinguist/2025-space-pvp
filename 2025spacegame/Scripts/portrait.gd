extends Sprite2D

enum SpeechPos {TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT, BOTTOM_RIGHT}
@export var speech_position : SpeechPos
const vert_look_up := {SpeechPos.TOP_LEFT : "Top", SpeechPos.BOTTOM_LEFT : "Bottom", SpeechPos.TOP_RIGHT : "Top", SpeechPos.BOTTOM_RIGHT : "Bottom"}
const horiz_look_up := {SpeechPos.TOP_LEFT : "Left", SpeechPos.BOTTOM_LEFT : "Left", SpeechPos.TOP_RIGHT : "Right", SpeechPos.BOTTOM_RIGHT : "Right"}
const pos_look_up := {SpeechPos.TOP_LEFT : Vector2(-0.5, -0.5), SpeechPos.BOTTOM_LEFT : Vector2(-0.5, 0.5), SpeechPos.TOP_RIGHT : Vector2(0.5, -0.5), SpeechPos.BOTTOM_RIGHT : Vector2(0.5, 0.5)}
const pos_look_up_offset := {SpeechPos.TOP_LEFT : Vector2(8, -36), SpeechPos.BOTTOM_LEFT : Vector2(8, 8), SpeechPos.TOP_RIGHT : Vector2(-8, -36), SpeechPos.BOTTOM_RIGHT : Vector2(-8, 8)}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpeechBubble.visible = false
	$SpeechBubble.set_type(horiz_look_up[speech_position], vert_look_up[speech_position])
	var siz = texture.get_size()*scale
	$SpeechBubble.position = siz * pos_look_up[speech_position] + pos_look_up_offset[speech_position]
	

func speak(words):
	self.visible = true
	$SpeechTimer.start()
	$SpeechBubble.show_text(words)
	$TalkingSound.play()
	$SpeechBubble.visible = true


func _on_timer_timeout() -> void:
	$SpeechBubble.show_text("")
	$SpeechBubble.visible = false
	$FadeTimer.start()


func _on_fade_timer_timeout() -> void:
	self.visible = false
