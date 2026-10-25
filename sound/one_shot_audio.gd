extends AudioStreamPlayer2D

func set_up(_file:String) -> void:
	stream = load(_file)
	play()

func _on_finished() -> void:
	queue_free()
