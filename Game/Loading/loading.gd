extends Control



func _ready():
	$Panel/Animator.play("load_scene")



func _on_Animator_animation_finished(anim_name):
	get_tree().change_scene("res://scene/Main.tscn")
