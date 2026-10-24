extends Area2D
@export var move: float = 3
@onready var camera_2d: Camera2D = $"../Camera2D"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !Global.cam_lock:
			Global.cam_lock = true
			camera_2d.enabled = true
			body.cam_disable()
			body.global_position[1] -= move
		else:
			Global.rat_soul = 0
			Global.cam_lock = false
			camera_2d.enabled = false
			body.cam_enable()
			body.global_position[1] += move
