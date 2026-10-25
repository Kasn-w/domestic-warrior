extends Area2D

@onready var level: Node2D = $"../.."

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.is_boost = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.is_boost = false
		level._shrine_stop()
