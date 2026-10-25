extends Sprite2D
@export var sprite = ""
@export var do = ""

func _ready() -> void:
	texture = load(sprite)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.collect(do)
		queue_free()
