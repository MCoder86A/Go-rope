extends Control

signal main_control_signal(request)
signal show_ad()

var highest_score = 0
var score = 0
var original_replay_pos = null
var original_saveMe_pos = null
var ad_available_2show : bool = false
var db_name: String = "score_dbv1.2.2"
var ad_delay_load : bool = false

onready var db_timer: Timer = Timer.new()

func _ready():
	if not GameDb._is_db_exist(db_name):
		GameDb._create_db(db_name,
		'{'+
			'"MAX_SCORE": 0,'+
			'"LAST_SCORE": 0,'+
			'"GOLD": 0,'+
			'"CHARACTER": 1'+
		'}')
	
	GameDb._open_db(db_name)
	var gstat = GameDb._get_db(db_name)
	highest_score = gstat["MAX_SCORE"]
	
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
	
	add_child(db_timer)
	db_timer.start(2*10)
	db_timer.connect("timeout", self, "_save_game_state_timer")

func _save_game_state_timer():
	GameDb._save_db(db_name)

func gameover(_score: int):
	score = _score
	if _score > highest_score:
		highest_score = _score
	$GameOver.show()
	

	GameDb._update(db_name, "MAX_SCORE", highest_score)
	GameDb._update(db_name, "LAST_SCORE", score)
	

func _on_Info_button_down():
	$Tutorial.show()
	$GameOver.hide()


func _on_Cross_button_down():
	get_tree().change_scene("res://scene/UI/dashboard.tscn")


func _on_GameOver_visibility_changed():
	if(!$GameOver.visible):
		get_node("GameOver/Dialog").hide()
		return

	
	$GameOver/score.text = String(score)	
	$GameOver/maxScore.text = "Highest score: "+String(highest_score)
	
	if(visible):
		get_node("Animator").play("UIgameOverOpen")
		
	

func _on_replay_button_down():
	for controls in get_children():
		if(controls.is_class("Control")):
			controls.hide()
	emit_signal("main_control_signal", "replay")

func low_gold():
	get_node("Animator").play("low_coins")
	

func _on_saveMe_button_down():
	get_node("GameOver/Dialog").show()
	get_node("Animator").play("on_save_me")
	

func _on_Ad_pressed(): #Ad button
	if(OS.get_name()=="Android"):
		get_node("GameOver/Dialog/Ad/icon").show()
		get_node("Animator").play("showing_ad")
		if ad_available_2show:	
			emit_signal("show_ad")
		else:
			ad_delay_load = true
	else:
		_on_ad_reward()


func _on_coin_pressed(): #Coin button
	var gold: int = GameDb._get_db(db_name)["GOLD"]	
	if gold < 50:
		low_gold()
	else:
		gold-=50
		GameDb._update(db_name, "GOLD", gold)
		emit_signal("main_control_signal", "take_gold")
		_on_ad_reward()
		get_node("GameOver/Dialog").hide()
		return
	

func _on_ad_closed():
	ad_available_2show = false

func _on_ad_loaded():
	ad_available_2show = true
	if ad_delay_load:
		emit_signal("show_ad")
	ad_delay_load = false

func _on_ad_reward(curr:String = "", am:int = -1):
	for controls in get_children():
		if(controls.is_class("Control")):
			controls.hide()
	
	get_node("Animator").stop()
	emit_signal("main_control_signal", "saveMe")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		GameDb._save_db(db_name)


func _on_close_dialog_pressed():
	get_node("Animator").play("close_save_dialog")


func _on_Dialog_visibility_changed():
	if not get_node("GameOver/Dialog").visible:
		get_node("GameOver/Dialog/low_coins").hide()
		get_node("GameOver/Dialog/Ad/icon").hide()
