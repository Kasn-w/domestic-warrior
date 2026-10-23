extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var ani_sprite: Node2D = $ani_sprite
@onready var sprite: AnimatedSprite2D = $ani_sprite/AnimatedSprite2D


@export var speed = 300.0
var attack_dmg: float = 10
var walk: bool = false
var is_flip: bool = false

func _physics_process(delta: float) -> void:
	var direction1 := Input.get_axis("ui_left", "ui_right")
	var direction2 := Input.get_axis("ui_up", "ui_down")
	if direction1:
		velocity.x = direction1 * speed
		walk = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if direction2:
		velocity.y = direction2 * speed
		walk = true
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	if direction1 and direction2:
		velocity.x /= 2
		velocity.y /= 2
	
	if (abs(velocity.x) + abs(velocity.y) == 0):
		walk = false
	
	move_and_slide()
	if (velocity.x > 0) and sprite.flip_h:
		if !is_flip:
			sprite_flip()
	elif (velocity.x < 0) and !sprite.flip_h:
		if !is_flip:
			sprite_flip()
	
	if (walk) and (!animation.is_playing() or (animation.is_playing() and animation.current_animation == "RESET")):
		animation.play("walk", 0.1)
	elif !walk and animation.is_playing() and animation.current_animation == "walk":
		animation.play("RESET", 0.3)

func sprite_flip():
	is_flip = true
	var tween = create_tween()
	tween.tween_property(ani_sprite, "scale:x", 0, 0.2)
	await tween.finished
	if (sprite.flip_h):
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	var tween2 = create_tween()
	tween2.tween_property(ani_sprite, "scale:x", 1, 0.2)
	await tween2.finished
	is_flip = false
