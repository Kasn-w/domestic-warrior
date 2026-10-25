extends Node2D

const rat_king = preload("uid://nvfadgpinioj")
const ammor_spw = preload("uid://b6c367jdsn4o3")
const medic_spw = preload("uid://bucjjtwmd6l5q")
const rat_spw = preload("uid://blgr6up756ym3")

var in_progress: bool = false

func _process(delta: float) -> void:
	if in_progress:
		Global.rat_king_time += delta
	elif Global.rat_king_time != 0:
		Global.rat_king_time = 0
	
func enter_room():
	in_progress = true
	for i in get_children():
		if i.is_in_group("spawner"):
			i.open()
		if i.is_in_group("rat"):
			i._on_see_range_body_entered(i.player)
	
func exit_room():
	in_progress = false
	for i in get_children():
		if i.is_in_group("spawner"):
			i.close()
		if i.is_in_group("rat"):
			i.hp = i.max_hp
			if i.name == "rat_king":
				i.global_position = Vector2(134.0, -561)
			i.see = false
	if !has_node("rat_king"):
		spawn_rat_king()

func spawn_rat_king():
	var create = rat_king.instantiate()
	add_child.call_deferred(create)
	create.global_position = Vector2(134.0, -561)
