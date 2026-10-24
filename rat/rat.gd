extends Node2D
@export var hp: float = 5
@export var speed: float = 20
@export var aggressive: float = 1
@export var stop_dis: float = 10
@export var getaway_s: float = 1.5

@onready var getaway_box: Area2D = $getaway_box

@onready var blink: Timer = $blink
@onready var sprite: AnimatedSprite2D = $ani_sprite/AnimatedSprite2D
@onready var ani_sprite: Node2D = $ani_sprite
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var player = get_tree().get_nodes_in_group("player")[0]  

var is_flip: bool = false
var is_vul: bool = false

func setup(_hp: float, _speed: float, _aggressive:float = 1):
	hp = _hp
	speed = _speed
	aggressive = _aggressive
	
func _process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_nodes_in_group("player")[0]
		return
	
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
	
	if !animation.is_playing():
		animation.play("walk", 0.2)
	
func get_hit(dmg:float, modi:String = "s"):
	pass

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
	sprite.frame = 1
	await get_tree().create_timer(0.2).timeout
	sprite.frame = 0
	var time = randf_range(8,15)
	blink.start(time)
