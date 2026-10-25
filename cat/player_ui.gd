extends Control

@onready var player: CharacterBody2D = $".."
@onready var rat_kill: Label = $CanvasLayer/rat_kill
@onready var hp: ProgressBar = $CanvasLayer/hp
@onready var speed_per: Label = $CanvasLayer/speed_per
@onready var attack_per: Label = $CanvasLayer/attack_per

@onready var bite: Sprite2D = $CanvasLayer/bite
@onready var sleep: Sprite2D = $CanvasLayer/sleep
@onready var hit_box: Sprite2D = $CanvasLayer/hit_box
@onready var dash: Sprite2D = $CanvasLayer/dash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rat_kill.text = str(Global.rat_soul)
	hp.value = 9 - player.hp
	attack_per.text = str(player.attack_mul) + " %"
	speed_per.text = str(player.speed_mul) + " %"

func contol_update(do:String):
	if do == "sleep":
		sleep.visible = true
	elif do == "bite":
		bite.visible = true
	elif do == "hit_box":
		hit_box.visible = true
	elif do == "dash_up":
		dash.visible = true
	else:
		print(do)
