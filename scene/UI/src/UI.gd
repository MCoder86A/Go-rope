extends Control

signal main_control_signal(request)

var highest_score = 0
var score = 0
var original_replay_pos
var original_saveMe_pos

func _ready():
	var node = get_node("/root/Main/Ball")
	node.connect("gameover", self, "gameover")
	
	original_replay_pos = $GameOver/replay.rect_position
	original_saveMe_pos = $GameOver/saveMe.rect_position

func gameover(score: int):
	if score > highest_score:
		highest_score = score
	$GameOver/score.text = String(score)
	$GameOver.show()
	

func _on_Info_button_down():
	$Tutorial.show()
	$GameOver.hide()


func _on_Cross_button_down():
	get_tree().change_scene("res://scene/UI/dashboard.tscn")


func _on_GameOver_visibility_changed():
	$GameOver/maxScore.text = "Highest score: "+String(highest_score)
	var anim = get_node("Animator").get_animation("UIgameOverOpen")
	var replay_track_idx = anim.find_track("GameOver/replay:rect_position")
	var saveMe_track_idx = anim.find_track("GameOver/saveMe:rect_position")
	
	anim.track_set_key_value(replay_track_idx, 0, original_replay_pos-Vector2(30, 0))
	anim.track_set_key_value(replay_track_idx, 1, original_replay_pos)

	anim.track_set_key_value(saveMe_track_idx, 0, original_saveMe_pos-Vector2(30, 0))
	anim.track_set_key_value(saveMe_track_idx, 1, original_saveMe_pos)
	
	if(visible):
		get_node("Animator").play("UIgameOverOpen")
	

func _on_replay_button_down():
	for controls in get_children():
		if(controls.is_class("Control")):
			controls.hide()
	emit_signal("main_control_signal", "replay")


func _on_saveMe_button_down():
	$GameOver.hide()
	emit_signal("main_control_signal", "saveMe")


func _on_GameOver_resized():
	original_replay_pos = $GameOver/replay.rect_position
	original_saveMe_pos = $GameOver/saveMe.rect_position
	pass
