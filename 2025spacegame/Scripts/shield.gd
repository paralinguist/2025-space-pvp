class_name Shield extends Area2D

func get_hit(_dmg):
	get_parent().get_parent().call_deferred("reposition_shields")
	get_parent().get_parent().shield_level -= 1
	queue_free()
