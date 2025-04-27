class_name WindowPeople

extends GameObject

#============================================================
#	Straightforward mean people looking at your window
#============================================================

#set to true for left to up spies
#false for left to down spies
@export var left: bool = false
@export var speed: float = 100.0

#the first turn the unit starts looking at the window
@export var start_play: int = 0
#the number of turns the unit looks at the window
@export var stay_time: int = 2
#the number of turns before looking at the window
@export var away_time: int = 6

@onready var spyL: Sprite2D = 	$"SpyL"
@onready var spyR: Sprite2D = 	$"SpyR"

#============================================================
#	Code here
#============================================================

#var turn: int = 0
var start_pos: Vector2
var end_pos: Vector2
var aim_pos: Vector2

var movetime: float = 0 #security for end of update
var mean_active: bool = false

#called by the handler, prepare an action or a sequence of actions at turn t
func play(time: int) -> void:
	#turn = time
	var t = time - start_play #relative turn
	if t < 0:
		return #do nothing
	t = t % (stay_time+away_time)
	if t == 0:
		start_mean_person()
	if t >= 0 and t < stay_time:
		update_mean_person(float(t+1)/(stay_time+1))
	if t == stay_time:
		return end_mean_person()

func start_mean_person() -> void:
	global_position = start_pos
	mean_active = true

func end_mean_person() -> void:
	aim_pos = end_pos
	movetime = abs((aim_pos-global_position).x)/speed
	mean_active = false
	
func is_mean_person() -> bool:
	return mean_active
	#var t = turn-start_play
	#return t >= 0 and t%(stay_time+away_time) < stay_time

func update_mean_person(r:float) -> void:
	aim_pos = start_pos + (end_pos-start_pos)*r
	movetime = abs((aim_pos-global_position).x)/speed

#for the handler, say if the object is done
func is_done() -> bool:
	return movetime <= 0

# Does this object prevent the player from being on the same tile?
func occupies_space() -> bool:
	return false

#update function
func _process(delta: float) -> void:
	if is_done():
		return
	movetime -= delta
	var diff: Vector2 = aim_pos-global_position
	var dx = min(diff.x,delta*speed)
	var dy = dx*0.5
	if left:
		dy *= -1
	global_position += Vector2(dx,dy)

func _ready() -> void:
	start_pos = Vector2(global_position)
	aim_pos = Vector2(global_position)
	var y = 220
	var x = y*2
	spyL.visible = left
	spyR.visible = not left
	if left:
		end_pos = start_pos + Vector2(x,-y)
	else:
		end_pos = start_pos + Vector2(x,y)
	
