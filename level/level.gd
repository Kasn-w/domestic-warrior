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


func spaw_rat():
	var create = rat.instantiate()
	var speed: float = randf_range(10,40)
	create.setup(5,speed,1)
	
	all_rat.add_child(create)
	create.global_position = Vector2(0,0)
