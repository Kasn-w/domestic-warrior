extends Area2D
@onready var timer: Timer = $Timer
@onready var colli: CollisionShape2D = $CollisionShape2D
const rat = preload("uid://dh1tydhd1nda")

@export var interval: float = 10
@export var amout: float = 25
@export var hp: float = 1.0
@export var speed: float = 1.0
@export var agg: int = 1

func randome_postion():
	var half: Vector2 = (colli.shape as RectangleShape2D).size / 2.0
	var local_position := Vector2(
		randf_range(-half.x, half.x),
		randf_range(-half.y, half.y)
	)
	return local_position

func spaw_rat(_hp: float = 5.0, _speed: float = 20.0, _agg: int = 1):
	var create = rat.instantiate()
	if (randf_range(0,1) > 0.95):
		_speed *= 3
	if (_agg == 1):
		_agg = randi_range(0, 2)
	create.setup(_hp,_speed,_agg)
	
	add_child(create)
	create.position = randome_postion()

func _on_timer_timeout() -> void:
	var check = false
	for i in get_children():
		if i.is_in_group("rat"):
			check = true
			break
	
	if !check:
		for i in range(amout):
			spaw_rat(hp, speed, agg)
	timer.start(randf_range(interval-1, interval+1))
