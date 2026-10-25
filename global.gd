extends Node

var aggresion = [{"think_t": 5, "act_t": 5},
{"think_t": 1, "act_t": 6},
{"think_t": 0.5, "act_t": 10}]

var is_boost: bool = false
var player_upgrade = []
var rat_soul:int = 0
var cam_lock: bool = true

var amount: float = 0
var rat_soul_rate:float = 25
var boost_temp: int = 0

var save_zone:bool = true

var rat_king_defeat:int = 0
var rat_king_time: float = 0
var rat_king_time_fast: float = INF

var normal: Dictionary = {}

func fast_time():
	if rat_king_time < rat_king_time_fast:
		rat_king_time_fast = rat_king_time
	
func _ready() -> void:
	for property in get_script().get_script_property_list():
		var prop_name = property.name
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			normal[prop_name] = get(prop_name)
	
func reset() -> void:
	for prop_name in normal:
		set(prop_name, normal[prop_name])
