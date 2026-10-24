extends Node2D

const rat = preload("uid://dh1tydhd1nda")
@onready var all_rat: Node2D = $all_rat
@onready var player: CharacterBody2D = $player

var z = 0
var sprite = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(100):
		spaw_rat()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spaw_rat(_hp: float = 5.0, _speed: float = 20.0, _agg: float = 1):
	var create = rat.instantiate()
	var speed: float = randf_range(10,40)
	create.setup(_hp,_speed,_agg)
	
	all_rat.add_child(create)
	create.global_position = Vector2(149,96)
