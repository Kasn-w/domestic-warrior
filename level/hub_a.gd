extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("rat"):
		area.get_hit(300)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.enter_hub()
