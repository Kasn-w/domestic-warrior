extends Control

const ONE_SHOT_AUDIO = preload("uid://cmoy3lq6ugxnk")

func _on_play_pressed() -> void:
	play_audio("res://sound/collect.mp3")
	await get_tree().create_timer(0.1).timeout
	Global.reset()
	get_tree().change_scene_to_file("res://level/level.tscn")
	
func play_audio(file:String):
	var create = ONE_SHOT_AUDIO.instantiate()
	
	add_child(create)
	create.set_up(file)
