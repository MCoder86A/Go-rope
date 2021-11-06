extends Line2D

signal being_destroy()
signal started()

var is_rope_active: bool= true
var is_started: bool = false
var delta_ball_position: Vector2 = Vector2.ZERO
var last_ball_position: Vector2
var heading_toward: Vector2
var decaying_speed: float = 4
var uvx: float = 0
var Ball: KinematicBody2D
var Ball_rect: Rect2
var Rope_rect: Rect2

func _ready():
	Ball = get_node("/root/Main/Ball")
	Ball.connect("Extend_rope", self, "on_Extend_rope")
	Ball.connect("on_destroy", self, "on_rope_destroy")
	Ball.connect("set_rope_state", self, "set_rope_state")
	var ball: KinematicBody2D = get_node("/root/Main/Ball")
	last_ball_position = ball.position
	set_ball_rope_rect()


func _physics_process(delta):
	pass

func set_ball_rope_rect():
	var Ball_texture: Sprite = Ball.get_node("Ball")
	var width = Ball_texture.texture.get_width()
	var height = Ball_texture.texture.get_height()
	var ball_position = Vector2(Ball.position.x-width/2, Ball.position.y-height/2)
	Ball_rect = Rect2(Vector2(ball_position), Vector2(width, height))

func get_rope_size():
	var first_point: Vector2 = points[0]
	var last_point: Vector2 = points[points.size()-1]
	var rope_height: float = first_point.distance_to(last_point)
	var x: float
	var y: float
	if heading_toward.x == 1 or heading_toward.x == -1:
		x = rope_height
		y = width
	elif heading_toward.y == 1 or heading_toward.y == -1:
		x = width
		y = rope_height
	
	return Vector2(x, y)

func get_rope_position():
	var first_point: Vector2 = points[0]
	var last_point: Vector2 = points[points.size()-1]
	var x: float
	var y: float
	if heading_toward.x == 1:
		x = first_point.x
		y = first_point.y-(width/2)
	elif heading_toward.x == -1:
		x = last_point.x
		y = last_point.y-(width/2)
	elif heading_toward.y == 1:
		x = first_point.x-(width/2)
		y = first_point.y
	elif heading_toward.y == -1:
		x = last_point.x-(width/2)
		y = last_point.y
	
	return Vector2(x, y)

func update_ball_rope_rect():
	var ball_x = Ball.position.x-Ball_rect.size.x/2
	var ball_y = Ball.position.y-Ball_rect.size.y/2
	var ball_position = Vector2(ball_x, ball_y)
	Ball_rect = Rect2(Vector2(ball_position), Ball_rect.size)
	
	var rope_position = get_rope_position()
	var rope_size = get_rope_size()
	Rope_rect = Rect2(rope_position, rope_size)

#Called when if any rope get inactivated
func on_rope_destroy():
	if Ball_rect.intersects(Rope_rect) and not is_started:
		is_started = true
		emit_signal("started")
		

func set_rope_state():
	var first_point = points[0]
	var last_point = points[points.size()-1]
	heading_toward = first_point.direction_to(last_point)
	if get_node("/root/Main/Path").get_child_count() == 1:
		is_started = true
	is_rope_active = true
	
func on_Extend_rope(new_position: Vector2):
	update_ball_rope_rect()
	if not Ball_rect.intersects(Rope_rect) and is_started == true and is_rope_active == true:
		is_rope_active = false
		emit_signal("being_destroy")
		$fire_point1.emitting = true
		$fire_point2.emitting = true
	
	delta_ball_position += new_position-last_ball_position
	delta_ball_position = Vector2(abs(delta_ball_position.x), abs(delta_ball_position.y))
	last_ball_position = new_position
	var first_point: Vector2 = points[0]
	var last_point: Vector2 = points[points.size()-1]
	if delta_ball_position.length()>=1 and is_rope_active and is_started:
		var first_pt = first_point+heading_toward*delta_ball_position*0
		var second_pt = last_point+heading_toward*delta_ball_position
		set_rope_position(first_pt, second_pt)
		delta_ball_position = Vector2.ZERO
	elif not is_rope_active and is_started:
		var first_pt = first_point+heading_toward*decaying_speed
		var second_pt = last_point-heading_toward*decaying_speed
		set_rope_position(first_pt, second_pt)
		if first_point.distance_to(last_point)<width:
			queue_free()

func set_rope_position(first_pt_vec: Vector2, second_pt_vec: Vector2):
	var first_point: Vector2 = points[0]
	set_point_position(0, first_pt_vec)
	set_point_position(1, second_pt_vec)
	$fire_point1.position = first_point
	$fire_point1.direction = -heading_toward
	$fire_point2.position = second_pt_vec
	$fire_point2.direction = heading_toward
	var delta_first_point: Vector2 = points[0]-first_point
	uvx += fmod(delta_first_point.length()/width, 1)
	material.set_shader_param("x_axis", uvx)




