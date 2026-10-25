extends Area2D

@onready var rat_king_room: Node2D = $"../rat_king_room"

@export var entrance: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if entrance:
			rat_king_room.enter_room()
		else:
			rat_king_room.exit_room()
