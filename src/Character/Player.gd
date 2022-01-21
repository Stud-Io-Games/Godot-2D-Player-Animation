extends Actor

var state_machine

const ANIMATION_RUN = "walk"
const ANIMATION_IDLE = "idle"
const ANIMATION_JUMP = "jump"
const ANIMATION_DEATH = "death"
const ANIMATION_HURT = "hurt"
const ANIMATION_ATTACK = "attack"

# You need to create inputs for "move_right", "move_left", "jump", "attack" in Project > Project Setting > Input Map
const INPUT_RIGHT = "move_right" # right_arrow, d
const INPUT_LEFT = "move_left" # left_arrow, a
const INPUT_JUMP = "jump" # up_arrow, w
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

func _on_AttackHit_area_entered(area):
	if area.is_in_group("hurtbox"):
		area.take_damage()

func _on_EnnemyDetector_area_entered(area):
	if area.is_in_group("enemy_attack"):
		if life_point > 0:
			life_point -= 1
			hurt()
		else:
			die()

func hurt():
	state_machine.travel(ANIMATION_HURT)
	# obliged to stop process because physics_process will override the animation with "IDLE" or "WALK"
	set_physics_process(false)

func hurt_finished_animation():
	# AnimationPlayer "Call Method Track" and insert a key with the function name 
	# to start physics_process again at the end of the animation	
	set_physics_process(true)

func die():
	state_machine.travel(ANIMATION_DEATH)
	set_physics_process(false)

func set_animation(direction):
	if not is_on_floor():
		state_machine.travel(ANIMATION_JUMP)
		return
	if Input.is_action_just_pressed(INPUT_ATTACK):
		state_machine.travel(ANIMATION_ATTACK)
		return
	if Input.is_action_pressed(INPUT_RIGHT) or Input.is_action_pressed(INPUT_LEFT):	
		if (direction.x != 0):
			state_machine.travel(ANIMATION_RUN)
			return
	state_machine.travel(ANIMATION_IDLE)    

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
