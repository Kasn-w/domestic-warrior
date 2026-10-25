extends Node2D

const rat_king = preload("uid://nvfadgpinioj")
const ammor_spw = preload("uid://b6c367jdsn4o3")
const medic_spw = preload("uid://bucjjtwmd6l5q")
const rat_spw = preload("uid://blgr6up756ym3")

var in_progress: bool = false

func enter_room():
	for i in get_children():
		if i.is_in_group("spawner"):
			i.open()
		if i.is_in_group("rat"):
			i._on_see_range_body_entered(i.player)
	
func exit_room():
	for i in get_children():
		if i.is_in_group("spawner"):
			i.close()
		if i.is_in_group("rat"):
			i.hp = i.max_hp
			i.global_position = Vector2(134.0, -561)
			i.see = false
	
