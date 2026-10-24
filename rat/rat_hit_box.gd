extends Area2D

signal a_get_hit(dmg:float, modi:String, _knock_s: float)

func get_hit(dmg:float,_knock_s: float = 100, modi:String = "s"):
	emit_signal("a_get_hit", dmg, modi, _knock_s)
