extends Node


func enter_hub():
	for i in get_children():
		i.enter_hub()

func exit_hub():
	for i in get_children():
		i.exit_hub()
