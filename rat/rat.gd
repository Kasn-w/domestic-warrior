extends Node2D
@export var hp: float = 5
@export var speed: float = 20
@export var aggressive: float = 1

@onready var blink: Timer = $blink
@onready var sprite: AnimatedSprite2D = $ani_sprite/AnimatedSprite2D
@onready var ani_sprite: Node2D = $ani_sprite
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var player = get_tree().get_nodes_in_group("player")[0]  

var is_flip: bool = false
var is_vul: bool = false

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_nodes_in_group("player")[0]
		return
	
	var direction := global_position.direction_to(player.global_position)
	global_position += direction * speed * delta
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
