extends Line2D

var is_rope_active: bool= true
var delta_ball_position: Vector2 = Vector2.ZERO
var last_ball_position: Vector2
var heading_toward: Vector2

func _ready():
	get_node("/root/Main/Ball").connect("Extend_rope", self, "on_Extend_rope")
	get_node("/root/Main/Ball").connect("heading_toward", self, "update_heading_toward")
	var ball: KinematicBody2D = get_node("/root/Main/Ball")
	last_ball_position = ball.position
	
func update_heading_toward():
	var last_second_point = points[points.size()-2]
	var last_point = points[points.size()-1]
	heading_toward = last_second_point.direction_to(last_point)
	
func _physics_process(delta):
	pass

func on_Extend_rope(new_position: Vector2):
	delta_ball_position += new_position-last_ball_position
	last_ball_position = new_position
	var last_second_point = points[points.size()-2]
	var last_point = points[points.size()-1]
	if delta_ball_position.length()>=5:
		add_point(last_point+heading_toward*delta_ball_position)
		delta_ball_position = Vector2.ZERO
		remove_point(0)



