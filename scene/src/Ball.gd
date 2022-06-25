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
var speed: float = 430
var gold: float = 0
var score: float = 0
var scoreSpeed = 50
var direction: Vector2 = Vector2(1,0)
var can_add_new_rope: bool = true
var current_rope_direction: Vector2
var active_rope: Line2D
var active_rope_direction: Vector2
var active_rope_start_pt: Vector2
var active_rope_end_pt: Vector2
var pos_correction_fin: bool
var swipe_start = null
var minimum_drag = 25
var game_start_time: int
var game_elapsed_time: int
var rope_no = 0
var speed_x_factor: float
var db_name: String = "score_dbv1.2.3"
var n_speed: float
var audio_player: AudioStreamPlayer
var is_sound: bool = 0

# Resources
var path: Node2D
var timer: Timer
var scorelbl: Label
var goldlbl: Label
var res_Rope = load("res://scene/Rope.tscn")
var gold_collected = preload("res://asset/sound/mixkit-gold-coin-prize-1999.wav")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func drawLine(Rope: Line2D, firstPoint: Vector2, secondPoint: Vector2):
	for i in firstPoint.distance_to(secondPoint) :
		Rope.add_point(firstPoint.move_toward(secondPoint, 50))

func _ready():
	path = get_node(path_p)
	timer = get_node(timer_p)
	scorelbl = get_node(UI_p).get_node("noOfStar")
	goldlbl = get_node(UI_p).get_node("noOfGold")
	
	if not GameDb._is_db_exist(db_name):
		GameDb._create_db(db_name,
		'{'+
			'"MAX_SCORE": 0,'+
			'"LAST_SCORE": 0,'+
			'"GOLD": 0,'+
			'"CHARACTER": 1,'+
			'"PURCHASED": ["item"],'+
			'"SOUND": 1'+
		'}')
	GameDb._open_db(db_name)
	gold = GameDb._get_db(db_name)["GOLD"]
	goldlbl.text = String(round(gold))
	
	if int(GameDb._get_db(db_name)["SOUND"]) == 1:
		is_sound = true
		get_node(UI_p).get_node("Sound").show()
		
	else:
		is_sound = false
		get_node(UI_p).get_node("Mute").show()
	
	Rope_add(Vector2(position.x-50, position.y), direction)
	rng.randomize()
	timer.start(2)
	
	var control: Control = get_node("/root/Main/UI/inGameUI")
	control.connect("main_control_signal", self, "main_control_signal")
	
	var rect = get_viewport_rect()
	if rect.size.x <= rect.size.y:
		var rguide = get_node("/root/Main/UI/inGameUI/r_guide")
		rguide.show()
	
	match int(GameDb._get_db(db_name)["CHARACTER"]):
		1:
			$Ball.play("ball")
			$Ball.scale = Vector2.ONE
			$Ball.position = Vector2.ZERO
		2:
			$Ball.play("character1")
			$Ball.scale = Vector2(0.4, 0.4)
			$Ball.position = Vector2(0, 8)
			
	audio_player = get_node("/root/Main/AudioPlayer")
	audio_player.set_stream(gold_collected)


func main_control_signal(request):
	match request:
		"replay":
			game_start_time = OS.get_ticks_msec()
			rope_no = 0
			var n = get_node("/root/Main/Path")
			game_over(n)
			set_physics_process(true)	
			direction = Vector2.RIGHT
			Rope_add(Vector2(position.x-50, position.y), direction)
			speed = 300
#			get_node(UI_p).get_node("noOfGold").show()
			timer.start(2)
			score = 0
			speed_x_factor = 0
			if $Ball.get_animation() != "ball":
				$Ball.set_rotation_degrees(rad2deg(\
					active_rope_direction.angle()))
		"saveMe":
			game_start_time = OS.get_ticks_msec()
			rope_no = 0
			_on_BallTimer_timeout()
			set_physics_process(true)
			position = active_rope_start_pt
			direction = active_rope_direction
			current_rope_direction = active_rope_direction
			active_rope.is_started = true
			can_add_new_rope = true
			timer.start(2)
			if $Ball.get_animation() != "ball":
				$Ball.set_rotation_degrees(rad2deg(\
					active_rope_direction.angle()))
	
		"take_gold":
			gold = GameDb._get_db(db_name)["GOLD"]
			goldlbl.text = String(round(gold))
			


func is_legal_move(new_move: Vector2):
	var angle = round(direction.angle_to(new_move)*180/PI)
	if angle == 90 or angle == -90:
		return true
	
func move(new_move: Vector2):
	var ballToRopeDeg = round(rad2deg(
		new_move.angle_to(current_rope_direction))
		)
	if is_legal_move(new_move) and abs(ballToRopeDeg)==90 :
		direction = new_move
		if $Ball.get_animation() != "ball":
			$Ball.set_rotation_degrees(rad2deg(direction.angle()))

func _physics_process(delta):
	if Input.get_action_strength("wasd"):
		var new_move: Vector2
		new_move.x = Input.get_action_strength("right")-\
			Input.get_action_strength("left")
		new_move.y = Input.get_action_strength("down")-\
			Input.get_action_strength("up")
		move(new_move)
	position+=direction*speed*delta
	
	score += delta*scoreSpeed
	scorelbl.text = String(round(score))
	emit_signal("Extend_rope", position)
	if not pos_correction_fin:
		correct_position()
	
	#	"speed_x_factor" is the input that determine the output of ball
	#	speed function
	#	NOTE - multiplying a constant with it will result in quickly speeding
	#	up of ball speed
	speed_x_factor = speed_x_factor+delta
	
	if speed_x_factor < 100:
		n_speed = (1.0/100)*pow(speed_x_factor,2) + 300
	elif speed_x_factor < 632.655:
		n_speed = 2*sqrt(speed_x_factor) + 380
	else:
		n_speed = log(speed_x_factor)/log(2) + 421
		
	level_up(n_speed)
	
	
func level_up(new_speed):
	speed = new_speed

func on_rope_started():
	rope_no = rope_no+1
	if rope_no == 1:
		game_start_time = OS.get_ticks_msec()
	
	game_elapsed_time = (OS.get_ticks_msec() - game_start_time)/1e3
	
	var _gold_b = gold
	if n_speed < 400 and rope_no > 1:
		gold += pow(n_speed/300.0, 4)
	elif n_speed < 430 and rope_no > 1:
		gold += pow(n_speed/300.0, 6)
	elif rope_no > 1:
		gold += pow(n_speed/300.0, 7)

	if _gold_b < round(gold) and is_sound:
		audio_player.play()
	
	goldlbl.text = String(round(gold))
	GameDb._update(db_name, "GOLD", round(gold))
	
	current_rope_direction = active_rope_direction
	can_add_new_rope = true
	correct_position()
	if pos_correction_fin:
		pos_correction_fin = false
	
	
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
		var unmodify_start_pt: Vector2 = calculate_unmStart_pt()\
			+ active_rope_direction*100
		var new_direction = calculate_new_rope_dir()
		var start_pt: Vector2 = calculate_rope_first_pt(
			unmodify_start_pt,
			new_direction)
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
	
func calculate_rope_first_pt(start_pt: Vector2,
		new_direction: Vector2):
	return start_pt+new_direction*rope_width/2
	
func Rope_add(start_pt: Vector2, to_direction: Vector2):
	var Rope = res_Rope.instance()
	var mat = Rope.get_material().duplicate()
	Rope.set_material(mat)
	
	path.add_child(Rope)
	
	Rope.add_point(start_pt)
	Rope.add_point(start_pt+to_direction*200)
	
	active_rope = Rope
	active_rope_direction = to_direction
	active_rope_start_pt = start_pt
	active_rope_end_pt = start_pt+to_direction*200
	
	can_add_new_rope = false
	
	Rope.connect("being_destroy", self, "being_destroy")
	Rope.connect("started", self, "on_rope_started")
	emit_signal("set_rope_state")
	emit_signal("on_rope_add", Rope.name)

func game_over(_path: Node):
	for i in  _path.get_children():
		i.free()
	
# Rope emits destroying signal when ball leave it
func being_destroy():
	emit_signal("on_destroy")
	var n = get_node("/root/Main/Path")
	for i in  n.get_children():
		var rope_rect: Rect2 = i.Rope_rect
		var ball_rect: Rect2 = i.Ball_rect
		if ball_rect.intersects(rope_rect):
			return
	timer.stop()
	set_physics_process(false)
	emit_signal("gameover", round(score))
	
	
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


#func _on_inGameUI_item_rect_changed():
#	var rect = get_viewport_rect()
#	var rguide = get_node("/root/Main/UI/inGameUI/r_guide")
#	if rect.size.x <= rect.size.y:
#		rguide.show()
#	else:
#		rguide.hide()
#
#	set_bg_size()


func _on_HomeIco_pressed():
	get_tree().change_scene("res://Game/Market/market.tscn")


func _on_Mute_pressed():
	is_sound = true
	get_node(UI_p).get_node("Sound").show()
	get_node(UI_p).get_node("Mute").hide()
	GameDb._update(db_name, "SOUND", 1)


func _on_Sound_pressed():
	is_sound = false
	get_node(UI_p).get_node("Mute").show()
	get_node(UI_p).get_node("Sound").hide()
	GameDb._update(db_name, "SOUND", 0)
