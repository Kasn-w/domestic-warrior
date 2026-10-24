extends Sprite2D


func _process(delta: float) -> void:
	modulate = Color(1.0, 1.0, 1.0, (float(Global.boost_temp) / 50))
