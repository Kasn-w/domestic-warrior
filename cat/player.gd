extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var ani_sprite: Node2D = $ani_sprite
@onready var sprite: AnimatedSprite2D = $ani_sprite/AnimatedSprite2D
@onready var blink: Timer = $blink
@onready var idel: Timer = $idel
@onready var dodge_t: Timer = $dodge

@export var speed = 300.0
@export var attack_dmg: float = 10

var walk: bool = false
var is_flip: bool = false

var is_dodge = false
var jump: bool = false
var dodge_x: float = 0
var dodge_y: float = 0
var dodge_cooldown: float = 1

var is_attack = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge") and !is_dodge and dodge_t.is_stopped():
		animation.play("RESET", 0.05)
		await get_tree().create_timer(0.05).timeout
		dodge_t.start(dodge_cooldown)
		is_dodge = true
		if !jump:
			animation.speed_scale = 1.3
			animation.play("dash", 0.3)
			dodge_x = velocity.x
			dodge_y = velocity.y
		else:
			animation.play("jump", 0.3)
	elif event.is_action_pressed("attack"):
		pass
	
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
		
	if (is_dodge):
		velocity.x = dodge_x * 1.5
		velocity.y = dodge_y * 1.5
	move_and_slide()
	if (!is_dodge):
		if (velocity.x > 0) and sprite.flip_h:
			if !is_flip:
				sprite_flip()
		elif (velocity.x < 0) and !sprite.flip_h:
			if !is_flip:
				sprite_flip()
		
		if (walk) and (!animation.is_playing() or (animation.is_playing() and animation.current_animation == "RESET")):
			animation.play("walk", 0.3)
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


func _on_blink_timeout() -> void:
	if (sprite.animation == "idel"):
		sprite.frame = 1
	await get_tree().create_timer(0.2).timeout
	if (sprite.animation == "idel"):
		sprite.frame = 0
	var time = randf_range(10,20)
	blink.start(time)


func _on_idel_timeout() -> void:
	var time = randf_range(5,6)
	if !animation.is_playing():
		animation.play("idel")
		time = randf_range(10,20)
	idel.start(time)

func dodge_fin():
	is_dodge = false
	animation.speed_scale = 1
	dodge_x = 0
	dodge_y = 0
	animation.play("RESET", 0.3)


func _on_dodge_timeout() -> void:
	dodge_t.stop()
