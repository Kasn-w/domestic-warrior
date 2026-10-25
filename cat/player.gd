extends CharacterBody2D

signal upgrade(do:String)

const ONE_SHOT_AUDIO = preload("uid://cmoy3lq6ugxnk")

@onready var rat_king_room: Node2D = $"../rat_king_room"
@onready var player_ui: Control = $player_ui

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
@export var base_speed:float = 150
var speed: float
@export var base_attack_dmg: float = 10
var attack_dmg: float

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

var attack_mul:int = 0
var speed_mul:int = 0

@onready var dash_a: Area2D = $dash

#upgrade
var dash_up: bool = false
var sleep_up: bool = false
var bite_up: bool = false
var hit_box_up: bool = false
@onready var swipe_coli: Area2D = $swipe
@onready var bite_coli: Area2D = $bite
@onready var dash_coli: Area2D = $dash
var attack_hitbox: Array

func _ready() -> void:
	attack_hitbox.append(swipe_coli)
	attack_hitbox.append(bite_coli)
	#attack_hitbox.append(dash_coli)
	cam_disable()
	hp = max_hp
	attack_dmg = base_attack_dmg
	speed = base_speed

func _unhandled_input(event: InputEvent) -> void:
	if animation.is_playing() and (animation.current_animation == "dead" or animation.current_animation == "sleep"):
		return
	
	if !knockback:
		if event.is_action_pressed("dodge") and !is_dodge and dodge_t.is_stopped() and !is_attack:
			attack_intent = false
			attack_hold_t = 0
			animation.play("RESET")
			dodge_t.start(dodge_cooldown)
			is_dodge = true
			if !jump:
				animation.speed_scale = 1.3
				animation.play("dash", 0.3)
				dodge_x = velocity.x
				dodge_y = velocity.y
				play_audio("res://sound/dodge.mp3")
			else:
				animation.play("jump", 0.3)
		elif event.is_action_pressed("attack") and !is_attack and !is_dodge and !attack_intent:
			attack_intent = true
		elif event.is_action_released("attack"):
			attack_intent = false
		elif event.is_action_pressed("sleep") and sleep_up and !is_attack and !is_dodge:
			animation.play("RESET")
			animation.play("sleep")

func _physics_process(delta: float) -> void:
	if animation.is_playing() and (animation.current_animation == "dead" or animation.current_animation == "sleep"):
		return
	
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
			if bite_up:
				attack_hold_t += delta
			elif attack_hold_t == 0:
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
	if knockback:
		velocity = knock_dir
		knock_dir = knock_dir.move_toward(Vector2.ZERO, 850 * delta)
		if knock_dir.is_zero_approx():
			knockback = false
			if hp <= 0:
				animation.play("dead")
				play_audio("res://sound/cat_dead.mp3")
		move_and_slide()
	elif !is_attack or is_bite:
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
	var audio_check = false
	is_attack = true
	animation.play("swipe")
	
	for i in swipe_a.get_overlapping_areas():
		if i.is_in_group("rat"):
			if !audio_check:
				play_audio("res://sound/swipe.mp3")
				audio_check = true
			i.get_hit(attack_dmg)
	if !audio_check:
		play_audio("res://sound/whiff.mp3")
	
func bite():
	is_attack = true
	is_bite = true
	bite_x = velocity.x
	bite_y = velocity.y
	animation.play("bite")
	play_audio("res://sound/cat_bite.mp3")

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
	if animation.is_playing() and animation.current_animation == "dead":
		return

	if !is_vul and !is_dodge:
		if is_attack:
			attack_fin()
			attack_intent = false
			attack_hold_t = 0
			
		if animation.is_playing() and animation.current_animation == "sleep":
			animation.stop()
			animation.play("RESET")
		play_audio("res://sound/cat_gethit.mp3")
		frame_freeze(0.13)
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
	var audio_check = false
	for i in bite_a.get_overlapping_areas():
		if i.is_in_group("rat"):
			if !audio_check:
				play_audio("res://sound/bite.mp3")
				audio_check = true
			frame_freeze(0.1)
			i.get_hit(attack_dmg, 150)
	
func check_dash():
	var audio_check = false
	if dash_up:
		for i in dash_a.get_overlapping_areas():			
			if i.is_in_group("rat"):
				if !audio_check:
					play_audio("res://sound/bite.mp3")
					audio_check = true
				frame_freeze(0.08)
				i.get_hit(attack_dmg, 100)

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

func dead():
	global_position = Vector2(145, -106)
	hp = max_hp
	Global.rat_soul = 0
	Global.cam_lock = true
	Global.save_zone = true
	if is_attack:
		attack_fin()
	cam_disable()
	rat_king_room.exit_room()
	play_audio("res://sound/tp.mp3")

func tp():
	global_position = Vector2(145, -106)
	hp = max_hp
	Global.cam_lock = true
	Global.save_zone = true
	if is_attack:
		attack_fin()
	cam_disable()
	play_audio("res://sound/tp.mp3")

func boost():
	play_audio("res://sound/upgrade.mp3")
	attack_mul += 50
	if speed_mul < 70:
		speed_mul += 10
	attack_dmg = base_attack_dmg * ((float(attack_mul) / 100) + 1)
	speed = base_speed * ((float(speed_mul) / 100) + 1)
	
func cam_toggle():
	if cam.enabled:
		cam_disable()
	else:
		cam_enable()
	
func cam_disable():
	cam.enabled = false

func cam_enable():
	cam.enabled = true

func collect(do:String):
	play_audio("res://sound/collect.mp3")
	if do == "sleep":
		sleep_up = true
	elif do == "bite":
		bite_up = true
	elif do == "hit_box":
		hit_box_up = true
		var sc = 2
		for i in attack_hitbox:
			i.scale = Vector2(sc,sc)
		attack_sprite.scale = Vector2(sc,sc)
	elif do == "dash_up":
		dash_up = true
		dodge_cooldown = 0.6
	else:
		print(do)
	emit_signal("upgrade", do)
	player_ui.contol_update(do)
	
func max_hp_up():
	play_audio("res://sound/collect.mp3")
	max_hp += 2
	hp = max_hp

func play_audio(file:String):
	var create = ONE_SHOT_AUDIO.instantiate()
	
	add_child(create)
	create.set_up(file)
