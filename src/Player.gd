extends Actor

var state_machine

const ANIMATION_RUN = "walk"
const ANIMATION_IDLE = "idle"
const ANIMATION_JUMP = "jump"
const ANIMATION_DEATH = "death"
const ANIMATION_HURT = "hurt"
const ANIMATION_ATTACK = "attack"

const INPUT_RIGHT = "move_right"
const INPUT_LEFT = "move_left"
const INPUT_JUMP = "jump"
const INPUT_ATTACK = "attack" # space

func _ready():
	state_machine = $Animation/AnimationTree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released(INPUT_JUMP) and _velocity.y < 0.0
	var direction: = get_direction()
	set_animation(direction)
	_velocity = compute_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	if direction.x != 0:
		$PlayerSprite.flip_h = direction.x < 0

func hurt():
	state_machine.travel(ANIMATION_HURT)

func die():
	state_machine.travel(ANIMATION_DEATH)
	set_physics_process(false)

func set_animation(direction):
	if not is_on_floor():
#		print('not on floor')
		travel_animation(ANIMATION_JUMP)
		return
	if Input.is_action_just_pressed(INPUT_ATTACK):
#		print('attack')
		travel_animation(ANIMATION_ATTACK)
		return
	if Input.is_action_pressed(INPUT_RIGHT) or Input.is_action_pressed(INPUT_LEFT):
#		print('moving ', 'left ? ', direction.x < 0)		
		travel_animation(ANIMATION_RUN)
		return
	if Input.is_action_pressed(INPUT_JUMP):
#		print('jump')
		travel_animation(ANIMATION_JUMP)
		return   
#	print('idle')
	travel_animation(ANIMATION_IDLE)    

func travel_animation(animation: String) -> void:
	if state_machine.get_current_node() != animation:
		print(state_machine.get_current_node(), ' / ', animation)
		state_machine.travel(animation)

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength(INPUT_RIGHT) - Input.get_action_strength(INPUT_LEFT),
		- 1.0 if Input.is_action_just_pressed(INPUT_JUMP) and is_on_floor() else 1.0
	)

func compute_velocity(
	linear_velocity: Vector2,
	direction: Vector2,
	speed: Vector2,
	is_jump_interrupted: bool
) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0: # jump
		out.y = speed.y * direction.y
	if is_jump_interrupted:
		out.y = 0.0
	return out

#extends Actor
#
##onready var animatedSprite = $AnimatedSprite
#onready var animationPlayer = $Animation/AnimationPlayer
#onready var animatedTree = $Animation/AnimationTree
#onready var playerSprite = $PlayerSprite
#
#const ANIMATION_RUN = "run"
#const ANIMATION_IDLE = "idle"
#const ANIMATION_JUMP = "jump"
#const ANIMATION_DEATH = "death"
#const ANIMATION_HURT = "hurt"
#
#const INPUT_RIGHT = "ui_right"
#const INPUT_LEFT = "ui_left"
#const INPUT_JUMP = "ui_up"
#const INPUT_ATTACK = "ui_select" # space
#
#export var stomp_impulse: = 1000.0
#export var life_points: = 3
#
#func _ready():
#	animatedTree.active = true
#
#func _process(delta: float) -> void:
#	var is_jump_interrupted: = Input.is_action_just_released(INPUT_JUMP) and _velocity.y < 0.0
#	var direction: = get_direction()
#	_velocity = compute_velocity(_velocity, direction, speed, is_jump_interrupted)
#	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
#	compute_animation(direction)
#
## func _on_EnnemyDetector_body_entered(body: PhysicsBody2D):
##	print('here ', life_points)
##	life_points -= 1
##	if life_points == 0:
##		print('wtf')
##		animatedSprite.animation = ANIMATION_DEATH
##		yield(animatedSprite, "animation_finished")
##		queue_free()
##	else:
##		animatedSprite.animation = ANIMATION_HURT
#
#
#func get_direction() -> Vector2:
#	return Vector2(
#		Input.get_action_strength(INPUT_RIGHT) - Input.get_action_strength(INPUT_LEFT),
#		- 1.0 if Input.is_action_just_pressed(INPUT_JUMP) and is_on_floor() else 1.0
#	)
#
#func compute_velocity(
#	linear_velocity: Vector2,
#	direction: Vector2,
#	speed: Vector2,
#	is_jump_interrupted: bool
#) -> Vector2:
#	var out: = linear_velocity
#	out.x = speed.x * direction.x
#	out.y += gravity * get_physics_process_delta_time()
#	if direction.y == -1.0: # jump
#		out.y = speed.y * direction.y
#	if is_jump_interrupted:
#		out.y = 0.0
#	return out
#
#func compute_stomp_velocity(linear_velocity: Vector2, 	impulse: float) -> Vector2:
#	var out: = linear_velocity
#	out.y = -impulse
#	return out
#
#func compute_animation(direction: Vector2) -> void:
#		# if jumping or falling
#	if direction.y < 0 or not is_on_floor():
#		set_animation("jump", "parameters/in_air/current", 1)
#		return
#	if direction.x != 0 and is_on_floor():
#		set_animation("walk", "parameters/movement/current", 1)
#		playerSprite.flip_h = direction.x < 0
#	else:
#		set_animation("idle", "parameters/movement/current", 0)
#
#
#
#func set_animation(animation_title: String, animation_name: String, value: int) -> void:
#	if animationPlayer.get_current_animation() != animation_title:
#		animatedTree.set(animation_name, value)
