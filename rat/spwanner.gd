extends Area2D

@export var enable: bool = true

@onready var timer: Timer = $Timer
@onready var colli: CollisionShape2D = $CollisionShape2D
const rat = preload("uid://dh1tydhd1nda")
@onready var player = get_tree().get_nodes_in_group("player")[0] 

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
	if !enable:
		return

	var create = rat.instantiate()
	if (randf_range(0,1) > 0.95):
		_speed *= 3
	if (_agg == 1):
		_agg = randi_range(0, 2)
	create.setup(_hp,_speed,_agg)
	
	add_child.call_deferred(create)
	create.position = randome_postion()

func enter_hub():
	for i in get_children():
		if i.is_in_group("rat"):
			i._on_unsee_range_body_exited(player)

func exit_hub():
	for i in get_children():
		if i.is_in_group("rat") and i.global_position.distance_to(player.global_position) <= 163:
			i._on_see_range_body_entered(player)

func close():
	enable = false
	for i in get_children():
		if i.is_in_group("rat"):
			i.set_process(false)

func open():
	enable = true
	for i in get_children():
		if i.is_in_group("rat"):
			i.set_process(true)
	timer.stop()
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	var check = false
	if get_children().size() > amout / 4:
		check = true
	#for i in get_children():
		#if i.is_in_group("rat"):
			#check = true
			#break
	
	if !check:
		for i in range(amout):
			spaw_rat(hp, speed, agg)
	timer.start(randf_range(interval-1, interval+1))
