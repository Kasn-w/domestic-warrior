extends Area2D

@onready var camera_2d: Camera2D = $"../Camera2D"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !Global.cam_lock:
			Global.cam_lock = true
			camera_2d.enabled = true
			body.cam_disable()
		else:
			Global.cam_lock = false
			camera_2d.enabled = false
			body.cam_enable()
