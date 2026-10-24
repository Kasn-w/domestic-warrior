extends Control

@onready var player: CharacterBody2D = $".."
@onready var rat_kill: Label = $CanvasLayer/rat_kill
@onready var hp: ProgressBar = $CanvasLayer/hp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rat_kill.text = str(Global.rat_soul)
	hp.value = 9 - player.hp
