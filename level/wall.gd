extends Area2D




func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("rat"):
		area.get_hit(300)
