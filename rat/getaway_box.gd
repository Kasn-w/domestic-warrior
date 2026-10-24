extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var radius: float = (collision_shape_2d.shape as CircleShape2D).radius
