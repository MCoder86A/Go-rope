extends KinematicBody2D

signal Extend_rope(position)
signal set_rope_state()
signal on_destroy()

# Import variable
export var speed: float = 10
export var path_p: NodePath
export var timer_p: NodePath
export var rope_width: float

#Game state
var direction: Vector2 = Vector2(1,0)
var can_add_new_rope: bool = true
var active_rope_direction: Vector2
var active_rope_start_pt: Vector2
var active_rope_end_pt: Vector2
var pos_correction_fin: bool
var swipe_start = null
var minimum_drag = 50

# Resources
var path: Node2D
var timer: Timer
var res_Rope = load("res://scene/Rope.tscn")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func drawLine(Rope: Line2D, firstPoint: Vector2, secondPoint: Vector2):
	for i in firstPoint.distance_to(secondPoint) :
		Rope.add_point(firstPoint.move_toward(secondPoint, 50))

func _ready():
	path = get_node(path_p)
	timer = get_node(timer_p)
	Rope_add(Vector2(position.x-50, position.y), direction)
	rng.randomize()
	timer.start(2)

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
	
	emit_signal("Extend_rope", position)
	
	if not pos_correction_fin:
		correct_position()


func on_rope_started():
	correct_position()
	if pos_correction_fin:
		pos_correction_fin = false

var target_pt: Vector2

func correct_position():
	target_pt = calculate_unmStart_pt()
	if position.distance_to(target_pt) > 5:
		var delta = get_physics_process_delta_time()
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
	
	emit_signal("set_rope_state")
	Rope.connect("being_destroy", self, "being_destroy")
	Rope.connect("started", self, "on_rope_started")

func being_destroy():
	emit_signal("on_destroy")
	
	
func _on_B_RIGHT_button_up():
	move(Vector2(1,0))

func _on_B_LEFT_button_up():
	move(Vector2(-1,0))

func _on_B_DOWN_button_up():
	move(Vector2(0,1))

func _on_B_UP_button_up():
	move(Vector2(0,-1))


func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			swipe_start = event.position
		if not event.is_pressed():
			_calculate_swipe(event.position)
		
func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return
	var swipe = swipe_end - swipe_start
	if abs(swipe.x) > minimum_drag:
		if swipe.x > 0:
			move(Vector2(1,0))
		else:
			move(Vector2(-1,0))
	if abs(swipe.y) > minimum_drag:
		if swipe.y > 0:
			move(Vector2(0,1))
		else:
			move(Vector2(0,-1))
