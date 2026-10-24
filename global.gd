extends Node

var aggresion = [{"think_t": 5, "act_t": 5},
{"think_t": 1, "act_t": 6},
{"think_t": 0.5, "act_t": 10}]

var player_upgrade = []
var rat_soul = 0
var cam_lock: bool = true

var normal: Dictionary = {}
func _ready() -> void:
	for property in get_script().get_script_property_list():
		var prop_name = property.name
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			normal[prop_name] = get(prop_name)

func reset() -> void:
	for prop_name in normal:
		set(prop_name, normal[prop_name])
