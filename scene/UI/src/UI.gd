extends Control

signal main_control_signal(request)

var highest_score = 0
var score = 0

func _ready():
	var node = get_node("/root/Main/Ball")
	node.connect("gameover", self, "gameover")

func gameover(score: int):
	if score > highest_score:
		highest_score = score
	$GameOver/score.text = String(score)
	$GameOver.show()
	#$Cross.show()
	#$Info.show()
	


func _on_Info_button_down():
	$Tutorial.show()
	$GameOver.hide()


func _on_Cross_button_down():
	get_tree().change_scene("res://scene/UI/dashboard.tscn")


func _on_GameOver_visibility_changed():
	$GameOver/maxScore.text = "Highest score: "+String(highest_score)


func _on_replay_button_down():
	for controls in get_children():
		controls.hide()
	emit_signal("main_control_signal", "replay")


func _on_saveMe_button_down():
	pass # Replace with function body.
