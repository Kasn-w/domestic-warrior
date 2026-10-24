extends CharacterBody2D


@onready var attack_sprite: Node2D = $att_spi
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var ani_sprite: Node2D = $ani_sprite
@onready var sprite: AnimatedSprite2D = $ani_sprite/AnimatedSprite2D
@onready var blink: Timer = $blink
@onready var idel: Timer = $idel
@onready var dodge_t: Timer = $dodge
@onready var cam: Camera2D = $Camera2D

@export var max_hp:int = 9
var hp: int
@export var speed = 300.0
@export var attack_dmg: float = 10

var walk: bool = false
var is_flip: bool = false

var is_dodge: bool = false
var jump: bool = false
var dodge_x: float = 0
var dodge_y: float = 0
var dodge_cooldown: float = 1

@onready var swipe_a: Area2D = $swipe
@onready var bite_a: Area2D = $bite
var is_attack: bool = false
var attack_intent: bool = false
var attack_hold_t: float = 0
var attack_hold: float = 0.3
var is_bite: bool = false
var bite_x: float = 0
var bite_y: float = 0

var is_vul: bool = false
@export var vul_t: float = 1
@onready var vul: Timer = $vul

var knockback: bool = false
var knock_dir: Vector2
var knock_s: float = 300

func _ready() -> void:
	cam_disable()
	hp = max_hp

func _unhandled_input(event: InputEvent) -> void:
	if !knockback:
		if event.is_action_pressed("dodge") and !is_dodge and dodge_t.is_stopped() and !is_attack:
			animation.play("RESET")
			dodge_t.start(dodge_cooldown)
			is_dodge = true
			if !jump:
				animation.speed_scale = 1.3
				animation.play("dash", 0.3)
				dodge_x = velocity.x
				dodge_y = velocity.y
			else:
				animation.play("jump", 0.3)
		elif event.is_action_pressed("attack") and !is_attack and !is_dodge and !attack_intent:
			attack_intent = true
		elif event.is_action_released("attack"):
			attack_intent = false

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
	
	if !is_attack:
		if (attack_intent):
			attack_hold_t += delta
			if attack_hold_t > attack_hold:
				bite()
		elif !attack_intent and attack_hold_t > 0:
			swipe()
	
	if (is_dodge and !jump):
		velocity.x = dodge_x * 1.5
		velocity.y = dodge_y * 1.5
		
	if (is_bite):
		velocity.x = bite_x / 1.2
		velocity.y = bite_y / 1.2
	if (!is_attack) or is_bite:
		if (knockback):
			velocity = knock_dir
			knock_dir = knock_dir.move_toward(Vector2.ZERO, 850 * delta)
			if knock_dir == Vector2.ZERO:
				knockback = false
		move_and_slide()
	
	if !is_dodge and !is_attack:
		if (velocity.x > 0) and sprite.flip_h:
			if !is_flip:
				sprite_flip()
		elif (velocity.x < 0) and !sprite.flip_h:
			if !is_flip:
				sprite_flip()
		
		if (walk) and (!animation.is_playing() or (animation.is_playing() and animation.current_animation == "RESET")):
			animation.play("walk")
		elif !walk and animation.is_playing() and animation.current_animation == "walk":
			animation.play("RESET", 0.3)

func sprite_flip():
	is_flip = true
	var tween = create_tween()
	tween.tween_property(ani_sprite, "scale:x", 0, 0.2)
	if (sprite.flip_h):
		attack_sprite.rotation_degrees = 0
		swipe_a.rotation_degrees = 0
		bite_a.rotation_degrees = 0
	else:
		attack_sprite.rotation_degrees = 180
		swipe_a.rotation_degrees = 180
		bite_a.rotation_degrees = 180
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
	be_no_vul()


func _on_dodge_timeout() -> void:
	dodge_t.stop()

func swipe():
	is_attack = true
	animation.play("swipe")
	for i in swipe_a.get_overlapping_areas():
		if i.is_in_group("rat"):
			i.get_hit(attack_dmg)
	
func bite():
	is_attack = true
	is_bite = true
	bite_x = velocity.x
	bite_y = velocity.y
	animation.play("bite")

func attack_fin():
	is_attack = false
	is_bite = false
	bite_x = 0
	bite_y = 0
	attack_intent = false
	attack_hold_t = 0
	animation.play("RESET")
	animation.stop()

func get_hit(knockback_dir: Vector2, _knock_s = knock_s):
	if !is_vul and !is_dodge:
		frame_freeze(0.08)
		is_vul = true
		vul.start(vul_t)
		hp -= 1
		knockback = true
		knock_dir = knockback_dir * _knock_s

func _on_vul_timeout() -> void:
	is_vul = false

func be_vul():
	is_vul = true
	
func be_no_vul():
	is_vul = false
	
func check_bite():
	for i in bite_a.get_overlapping_areas():
		if i.is_in_group("rat"):
			frame_freeze(0.1)
			i.get_hit(attack_dmg, 150)

func enter_hub():
	full_heal()
	
func full_heal():
	hp = max_hp

func frame_freeze(duration: float) -> void:
	if Engine.time_scale == 0.0:
		return
		
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func cam_toggle():
	if cam.enabled:
		cam_disable()
	else:
		cam_enable()
	
func cam_disable():
	cam.enabled = false

func cam_enable():
	cam.enabled = true
