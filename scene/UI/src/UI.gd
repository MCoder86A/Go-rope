extends Control

signal main_control_signal(request)
signal show_ad()

var highest_score = 0
var score = 0
var original_replay_pos = null
var original_saveMe_pos = null
var ad_available_2show : bool = false

var ad_unit_id :String = "standard"

func _ready():
	var node = get_node("/root/Main/Ball")
	node.connect("gameover", self, "gameover")
	
	if(OS.get_name()=="Android"):
		var Main : Node= get_tree().get_root().get_node("Main")
		var scene :Resource= load("res://scene/UI/ad.tscn")
		var inst_ad = scene.instance()
		Main.call_deferred("add_child", inst_ad)
		inst_ad.connect("_on_ad_reward", self, "_on_ad_reward")
		inst_ad.connect("_on_ad_closed", self, "_on_ad_closed")
		inst_ad.connect("_on_ad_loaded", self, "_on_ad_loaded")
	
func gameover(_score: int):
	score = _score
	if _score > highest_score:
		highest_score = _score
	$GameOver.show()
	

func _on_Info_button_down():
	$Tutorial.show()
	$GameOver.hide()


func _on_Cross_button_down():
	get_tree().change_scene("res://scene/UI/dashboard.tscn")


func _on_GameOver_visibility_changed():
	if(!$GameOver.visible):
		return
		
	if(original_replay_pos == null || original_saveMe_pos == null):
		original_replay_pos = $GameOver/replay.rect_position
		original_saveMe_pos = $GameOver/saveMe.rect_position
	
	$GameOver/score.text = String(score)	
	$GameOver/maxScore.text = "Highest score: "+String(highest_score)
	var anim = get_node("Animator").get_animation("UIgameOverOpen")
	var replay_track_idx = anim.find_track("GameOver/replay:rect_position")
	var saveMe_track_idx = anim.find_track("GameOver/saveMe:rect_position")
	
	anim.track_set_key_value(replay_track_idx, 0, 
			original_replay_pos-Vector2(30, 0))
	anim.track_set_key_value(replay_track_idx, 1, 
			original_replay_pos)

	anim.track_set_key_value(saveMe_track_idx, 0, 
			original_saveMe_pos-Vector2(30, 0))
	anim.track_set_key_value(saveMe_track_idx, 1, 
			original_saveMe_pos)
	
	if(visible):
		get_node("Animator").play("UIgameOverOpen")
	

func _on_replay_button_down():
	for controls in get_children():
		if(controls.is_class("Control")):
			controls.hide()
	emit_signal("main_control_signal", "replay")

func _on_saveMe_button_down():
	if(OS.get_name()=="Android"):
		emit_signal("show_ad")
		return
	else:
		_on_ad_reward()

func _on_ad_closed():
	ad_available_2show = false

func _on_ad_loaded():
	ad_available_2show = true
	
func _on_ad_reward(curr:String = "", am:int = -1):
	for controls in get_children():
		if(controls.is_class("Control")):
			controls.hide()
	emit_signal("main_control_signal", "saveMe")
	
