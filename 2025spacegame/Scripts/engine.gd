class_name Engineer extends ShipModule

func set_retro():
	$Body/Retro.visible = true
	$Body/Body.visible = false
	$Body/Body2.visible = false
	$Body/Body3.visible = false

func set_tech():
	$Body/Tech.visible = true
	$Body/Body.visible = false
	$Body/Body2.visible = false
	$Body/Body3.visible = false
