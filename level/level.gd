extends Node2D

@onready var shrne_drain: AudioStreamPlayer2D = $shrne_drain

const rat = preload("uid://dh1tydhd1nda")
@onready var all_rat: Node2D = $all_rat
@onready var player: CharacterBody2D = $player
@onready var shrine: Node2D = $shrine
var _start: bool = true

@onready var den_exp: Label = $den_exp
@onready var shrin_exp: Label = $shrin_exp

@onready var control: Label = $control
@onready var victory: Label = $victory

var z = 0
var sprite = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#for i in range(100):
		#spaw_rat()
	_on_player_upgrade("do")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !victory.visible and Global.rat_king_defeat > 0:
		victory.visible = true
	victory.text = "rat king defeat: "+ str(Global.rat_king_defeat) + "\n"
	var minute := int(Global.rat_king_time_fast / 60.0)
	var second := int(Global.rat_king_time_fast) % 60
	var ms := int((Global.rat_king_time_fast - int(Global.rat_king_time_fast)) * 1000.0)
	victory.text += "fastest: "+ str(minute) + ":" + str(second) + ":" + str(ms)

	if Global.is_boost:
		if (Global.boost_temp >= 50):
			Global.boost_temp -= 50
			player.boost()
			if _start:
				_start = false
				den_exp.text = "Besure to read the"+'\n'+"control, it's important"
				shrin_exp.visible = false
			
		if Global.rat_soul > 0:
			if !shrne_drain.playing:
				shrne_drain.play()
			Global.amount += Global.rat_soul_rate * delta
			var whole = int(Global.amount)
			if whole > 0:
				var value = maxi(Global.rat_soul - whole, 0)
				Global.boost_temp += Global.rat_soul - value
				Global.rat_soul = value
				Global.amount -= whole
		else:
			if shrne_drain.playing:
				shrne_drain.stop()

func _shrine_stop():
	if shrne_drain.playing:
		shrne_drain.stop()
	
func spaw_rat(_hp: float = 5.0, _speed: float = 20.0, _agg: float = 1):
	var create = rat.instantiate()
	create.setup(_hp,_speed,randi_range(0, 2))
	
	all_rat.add_child(create)
	create.global_position = Vector2(149,96)


func _on_player_upgrade(do: String) -> void:
	control.text = "     -control-\nwasd   - movement\nM_left - claw swipe\nM_right - dash\n"
	if player.dash_up:
		control.text += "  (now do damanage!)\n"
	if player.bite_up:
		control.text += "hold m-left + wasd\n               - bite\n"
	if player.sleep_up:
		control.text += "E - sleep and tp back\n"
	if player.hit_box_up:
		control.text += "(bigger hit box)\n"
