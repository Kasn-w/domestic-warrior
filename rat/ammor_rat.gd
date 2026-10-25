extends Node2D
var max_hp: float
@export var hp: float = 500
@export var speed: float = 50
@export var aggressive: int = 2
@export var stop_dis: float = 10
@export var getaway_s: float = 1.5

@export var think_t: float = 0.5
@onready var thinking: Timer = $thinking
@onready var act: Timer = $act
@export var act_t: float = 5

@onready var getaway_box: Area2D = $getaway_box

@onready var particle_player: AnimationPlayer = $particlePlayer

@onready var blink: Timer = $blink
@onready var sprite: AnimatedSprite2D = $ani_sprite/AnimatedSprite2D
@onready var ani_sprite: Node2D = $ani_sprite
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var player = get_tree().get_nodes_in_group("player")[0]  
@onready var attack_range: Area2D = $attack_range
@onready var hit_box: Area2D = $hit_box

var is_thinking: bool = true
var is_flip: bool = false
var is_vul: bool = false
var action:String = "walk"
var attack_where: Vector2
var is_attack: bool = false

var knockback: bool = false
var knock_dir: Vector2
var knock_s: float = 100
var is_stun: bool = false

var is_drying: bool = false
var see: bool = false

func _ready() -> void:
	set_process(false)
	
func setup(_hp: float, _speed: float, _aggressive:int = 1):
	hp = _hp
	max_hp = hp
	speed = _speed
	aggressive = _aggressive
	think_t = Global.aggresion[aggressive]["think_t"]
	act_t = Global.aggresion[aggressive]["act_t"]
	
func _process(delta: float) -> void:
	if !see:
		if animation.is_playing():
			animation.stop()
		return
	
	if not is_instance_valid(player):
		player = get_tree().get_nodes_in_group("player")[0]
		return
	
	if knockback == true:
		var velocity = -knock_dir
		knock_dir = knock_dir.move_toward(Vector2.ZERO, 850 * delta)
		if knock_dir == Vector2.ZERO:
			knockback = false
		
		global_position += velocity * delta
		return
	if is_stun:
		return
	
	if is_thinking and !action == "attack":
		animation.play("RESET",0.5)
		return
	elif is_thinking:
		return
	
	if action == "walk":
		var to_player :Vector2 = player.global_position - global_position
		var chase:Vector2 = Vector2.ZERO

		if to_player.length_squared() > stop_dis ** 2:
			chase = to_player.normalized()
			
		var seperate := Vector2.ZERO
		for rat in getaway_box.get_overlapping_areas():
			if rat == self:
				continue
			
			var away: Vector2 = global_position - rat.global_position
			var distance: float = away.length()
			if distance > 0.001 and distance < getaway_box.radius:
				var weight: float = 1.0 - distance / getaway_box.radius
				seperate += away.normalized() * weight
			
		var direction: Vector2 = chase + seperate * getaway_s
		
		global_position += direction.limit_length(1.0) * speed * delta
		
		if !is_flip and !sprite.flip_h and direction.x > 0:
			sprite_flip()
		elif !is_flip and sprite.flip_h and direction.x < 0:
			sprite_flip()
	elif action == "attack":
		var seperate := Vector2.ZERO
		for rat in getaway_box.get_overlapping_areas():
			if rat == self:
				continue
			
			var away: Vector2 = global_position - rat.global_position
			var distance: float = away.length()
			if distance > 0.001 and distance < getaway_box.radius:
				var weight: float = 1.0 - distance / getaway_box.radius
				seperate += away.normalized() * weight
			
		var direction: Vector2 = attack_where + seperate * getaway_s
		global_position += direction.limit_length(1.0) * (speed + 100) * delta
	
	if !animation.is_playing() and !is_thinking and action == "walk" or animation.current_animation == "RESET":
		animation.play("walk")
	
func get_hit(dmg:float, modi:String = "s", _knock_s = knock_s):
	if is_drying:
		return
	
	hp -= dmg
	if (hp < 0):
		_super_dead()
	if modi == "s" or modi == "w":
		knockback = true
		knock_dir = (player.global_position - global_position).normalized() * _knock_s

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

func think_start():
	thinking.start(randf_range(think_t-0.8 ,think_t+1))

func act_start():
	act.start(randf_range(act_t-3 ,act_t))
	
func _on_blink_timeout() -> void:
	sprite.frame = 1
	await get_tree().create_timer(0.2).timeout
	sprite.frame = 0
	var time = randf_range(8,15)
	blink.start(time)


func _on_act_timeout() -> void:
	is_thinking = true
	is_attack = false
	think_start()

func _on_thinking_timeout() -> void:		
	if !is_stun:
		if attack_range.overlaps_body(player):
			attack_where = (player.global_position - global_position).normalized()
			action = "attack"
			animation.speed_scale = 0.5
			animation.play("start")
		else:
			is_thinking = false
			action = "walk"
			act_start()

func start_fin():
	is_thinking = false
	is_attack = true
	animation.speed_scale = 1
	animation.play("attack")
	
func _on_attack_range_body_entered(body: Node2D) -> void:
	if !see:
		return
	
	if !is_stun and !is_attack:
		if body.is_in_group("player"):
			is_thinking = true
			thinking.stop()
			thinking.start(randf_range(think_t / 10, think_t / 5))


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and animation.is_playing() and animation.current_animation == "attack":
		body.get_hit(attack_where, 300)


func _on_hit_box_a_get_hit(dmg: float, modi: String, _knock:float) -> void:
	get_hit(dmg, modi, _knock)

func _hit_end():
	if (hp < 0):
		animation.play("down")
	else:
		is_stun = false
		animation.play("RESET")
		is_thinking = true
		think_start()

func _super_dead():
	if (hp < (-max_hp)):
		is_drying = true
		animation.play("down")

func _on_see_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !see:
		see = true
		animation.play("notice")
		await animation.animation_finished
		set_process(true)
		_on_thinking_timeout()

func _on_unsee_range_body_exited(body: Node2D) -> void:	
	if body.is_in_group("player"):
		set_process(false)
		see = false

func _dead_soul():
	Global.rat_soul += 1

func get_heal():
	var value = mini(floor(hp + 10),floor(max_hp))
	hp = value
	particle_player.play("heal")


func _on_hit_box_a_get_heal() -> void:
	get_heal()
