class_name Science extends ShipModule
func set_retro():
	$Retro.visible = true
	$Body.visible = false
	$Exhaust.visible = false
	$Top.visible = false

func set_tech():
	$Tech.visible = true
	$Body.visible = false
	$Exhaust.visible = false
	$Top.visible = false
