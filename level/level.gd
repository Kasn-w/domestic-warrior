extends Node2D

const rat = preload("uid://dh1tydhd1nda")
@onready var all_rat: Node2D = $all_rat
@onready var player: CharacterBody2D = $player
@onready var shrine: Node2D = $shrine
var _start: bool = true

@onready var den_exp: Label = $den_exp
@onready var shrin_exp: Label = $shrin_exp

var z = 0
var sprite = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in range(100):
		#spaw_rat()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.is_boost:
		if (Global.boost_temp >= 50):
			Global.boost_temp -= 50
			player.boost()
			if _start:
				_start = false
				den_exp.visible = false
				shrin_exp.visible = false
			
		if Global.rat_soul > 0:
			Global.amount += Global.rat_soul_rate * delta
			var whole = int(Global.amount)
			if whole > 0:
				var value = maxi(Global.rat_soul - whole, 0)
				Global.boost_temp += Global.rat_soul - value
				Global.rat_soul = value
				Global.amount -= whole



func spaw_rat(_hp: float = 5.0, _speed: float = 20.0, _agg: float = 1):
	var create = rat.instantiate()
	create.setup(_hp,_speed,randi_range(0, 2))
	
	all_rat.add_child(create)
	create.global_position = Vector2(149,96)
