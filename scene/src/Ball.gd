extends KinematicBody2D

signal Extend_rope(position)
signal set_rope_state()
signal on_destroy()
signal on_rope_add(name)
signal gameover(score)

# Import variable
export var path_p: NodePath
export var timer_p: NodePath
export var UI_p: NodePath
export var rope_width: float

#Game state
var speed: float = 200
var score: float = 0
var direction: Vector2 = Vector2(1,0)
var can_add_new_rope: bool = true
var active_rope_direction: Vector2
var active_rope_start_pt: Vector2
var active_rope_end_pt: Vector2
var pos_correction_fin: bool
var swipe_start = null
var minimum_drag = 25

# Resources
var path: Node2D
var timer: Timer
var scorelbl: Label
var res_Rope = load("res://scene/Rope.tscn")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func drawLine(Rope: Line2D, firstPoint: Vector2, secondPoint: Vector2):
	for i in firstPoint.distance_to(secondPoint) :
		Rope.add_point(firstPoint.move_toward(secondPoint, 50))

func _ready():
	set_bg_size()
	path = get_node(path_p)
	timer = get_node(timer_p)
	scorelbl = get_node(UI_p).get_node("scores/grid/number")
	Rope_add(Vector2(position.x-50, position.y), direction)
	rng.randomize()
	timer.start(2)
	
	var control: Control = get_node("/root/Main/UI/inGameUI")
	control.connect("main_control_signal", self, "main_control_signal")
	
	var rect = get_viewport_rect()
	if rect.size.x <= rect.size.y:
		var rguide = get_node("/root/Main/UI/inGameUI/r_guide")
		rguide.show()
	
func main_control_signal(request):
	if request == "replay":
		set_physics_process(1)	
		direction = Vector2.RIGHT
		Rope_add(Vector2(position.x-50, position.y), direction)
		speed = 200
		get_node(UI_p).get_node("scores").show()
		timer.start(2)

func set_bg_size():
	var bg_layer: ParallaxLayer = get_tree().get_root().get_node("/root/Main/BG/L1")
	var sprite: Sprite = bg_layer.get_node("Sprite")
	var win_size = OS.window_size
	var w = sprite.texture.get_width()
	var h = sprite.texture.get_height()
	var scale = max(win_size.x/w, win_size.y/h)
	bg_layer.motion_mirroring = Vector2(w*scale, h*scale)
	sprite.scale = Vector2.ONE*scale

func is_legal_move(new_move: Vector2):
	var angle = round(direction.angle_to(new_move)*180/PI)
	if angle == 90 or angle == -90:
		return true
	
func move(new_move: Vector2):
	if is_legal_move(new_move):
		direction = new_move

	
func _physics_process(delta):
	if Input.get_action_strength("wasd"):
		var new_move: Vector2
		new_move.x = Input.get_action_strength("right")-Input.get_action_strength("left")
		new_move.y = Input.get_action_strength("down")-Input.get_action_strength("up")
		move(new_move)
	position+=direction*speed*delta
	
	score += delta*5
	scorelbl.text = String(round(score))
	
	emit_signal("Extend_rope", position)
	
	if not pos_correction_fin:
		correct_position()

func level_up(new_speed):
	speed = new_speed

func on_rope_started():
	can_add_new_rope = true
	correct_position()
	if pos_correction_fin:
		pos_correction_fin = false
		
	if score < 5:
		level_up(score+220)
	elif score < 10:
		level_up(score+230)
	elif score < 20:
		level_up(score+240)
	elif score < 25:
		level_up(score+250)
	elif score < 30:
		level_up(score+260)
	elif score < 35:
		level_up(score+270)
	elif score < 40:
		level_up(score+280)
	elif score < 45:
		level_up(score+290)
	elif score < 50:
		level_up(score+300)
	elif score < 55:
		level_up(score+302)
	elif score < 60:
		level_up(score+303)
	elif score < 65:
		level_up(score+304)
	elif score < 350:
		level_up(score+308)
	elif score < 550:
		level_up(score+320)
	elif score < 1000:
		level_up(score+400)
	
	
	
var target_pt: Vector2

func correct_position():
	target_pt = calculate_unmStart_pt()
	var delta = get_physics_process_delta_time()
	var limit = position.direction_to(target_pt)*speed/4*delta
	if position.distance_to(target_pt) > limit.length():
		position +=  position.direction_to(target_pt)*speed/4*delta
	else:
		position = target_pt
		pos_correction_fin = true

func _on_BallTimer_timeout():
	var rn = rng.randf_range(1,3)
	if can_add_new_rope:
		var unmodify_start_pt: Vector2 = calculate_unmStart_pt()+active_rope_direction*100
		var new_direction = calculate_new_rope_dir()
		var start_pt: Vector2 = calculate_rope_first_pt(unmodify_start_pt, new_direction)
		Rope_add(start_pt, new_direction)
	timer.start(rn)

func calculate_new_rope_dir():
	var rn_lr = rng.randi_range(0,1)
	var new_direction: Vector2
	if rn_lr:
		new_direction = active_rope_direction.rotated(-(PI/2))
	else:
		new_direction = active_rope_direction.rotated(PI/2)

	return new_direction
	
#return points intersected by perpendicular of Ball into line
func calculate_unmStart_pt():
	var new_x: float
	var new_y: float
	var p = position.x
	var q = position.y
	var x1 = active_rope_start_pt.x
	var y1 = active_rope_start_pt.y
	var x2 = active_rope_end_pt.x
	var y2 = active_rope_end_pt.y
	var m: float
	if y2-y1 == 0:
		new_y = y2
		new_x = p
	elif x2-x1 == 0:
		new_x = x1
		new_y = q
	else:
		m = (y2-y1)/(x2-x1)
		new_x = ((p/m)+q+m*x1-y1)/(m+(1/m))
		new_y = m*(new_x-x1)+y1
		
	return Vector2(new_x, new_y)
	
func calculate_rope_first_pt(start_pt: Vector2, new_direction: Vector2):
	return start_pt+new_direction*rope_width/2
	
func Rope_add(start_pt: Vector2, to_direction: Vector2):
	var Rope = res_Rope.instance()
	var mat = Rope.get_material().duplicate()
	Rope.set_material(mat)
	
	path.add_child(Rope)
	
	Rope.add_point(start_pt)
	Rope.add_point(start_pt+to_direction*200)
	
	active_rope_direction = to_direction
	active_rope_start_pt = start_pt
	active_rope_end_pt = start_pt+to_direction*200
	
	can_add_new_rope = false
	
	Rope.connect("being_destroy", self, "being_destroy")
	Rope.connect("started", self, "on_rope_started")
	emit_signal("set_rope_state")
	emit_signal("on_rope_add", Rope.name)

func game_over(path: Node):
	for i in  path.get_children():
		i.queue_free()
	emit_signal("gameover", round(score))
	speed = 0
	timer.stop()
	score = 0
	get_node(UI_p).get_node("scores").hide()
	set_physics_process(0)
	
# Rope emits destroying signal when ball leave it
func being_destroy():
	emit_signal("on_destroy")
	var n = get_node("/root/Main/Path")
	for i in  n.get_children():
		var rope_rect: Rect2 = i.Rope_rect
		var ball_rect: Rect2 = i.Ball_rect
		if ball_rect.intersects(rope_rect):
			return
	game_over(n)
	
func _on_B_RIGHT_button_up():
	move(Vector2(1,0))

func _on_B_LEFT_button_up():
	move(Vector2(-1,0))

func _on_B_DOWN_button_up():
	move(Vector2(0,1))

func _on_B_UP_button_up():
	move(Vector2(0,-1))


func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			swipe_start = event.position
		if not event.is_pressed():
			_calculate_swipe(event.position)
		
func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return
	var swipe = swipe_end - swipe_start
	if abs(swipe.x) > minimum_drag and abs(swipe.x) > abs(swipe.y):
		if swipe.x > 0:
			move(Vector2(1,0))
		else:
			move(Vector2(-1,0))
		return
	if abs(swipe.y) > minimum_drag:
		if swipe.y > 0:
			move(Vector2(0,1))
		else:
			move(Vector2(0,-1))


func _on_inGameUI_item_rect_changed():
	var rect = get_viewport_rect()
	var rguide = get_node("/root/Main/UI/inGameUI/r_guide")
	if rect.size.x <= rect.size.y:
		rguide.show()
	else:
		rguide.hide()

	set_bg_size()
