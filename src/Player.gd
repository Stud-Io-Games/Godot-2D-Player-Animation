extends Actor

onready var animatedSprite = $AnimatedSprite

const ANIMATION_RUN = "run"
const ANIMATION_IDLE = "idle"
const ANIMATION_JUMP = "jump"


const INPUT_RIGHT = "ui_right"
const INPUT_LEFT = "ui_left"
const INPUT_JUMP = "ui_up"
const INPUT_ATTACK = "ui_select" # space

export var stomp_impulse: = 1000.0

func _physics_process(delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released(INPUT_JUMP) and _velocity.y < 0.0
	var direction: = get_direction()
	_velocity = compute_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	set_animation(direction)

func _on_EnemyDetector_area_entered(area: Area2D):
	_velocity = compute_stomp_velocity(_velocity, stomp_impulse)

func _on_EnemyDetector_body_entered(body: PhysicsBody2D):
	queue_free()

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

func compute_stomp_velocity(linear_velocity: Vector2, 	impulse: float) -> Vector2:
	var out: = linear_velocity
	out.y = -impulse
	return out

func set_animation(direction: Vector2) -> void:
	if direction.y < 0 or not is_on_floor():
		animatedSprite.animation = ANIMATION_JUMP
		return
	if direction.x > 0 and is_on_floor():
		animatedSprite.animation = ANIMATION_RUN
		animatedSprite.flip_h = false
	elif direction.x < 0 and is_on_floor():
		animatedSprite.animation = ANIMATION_RUN
		animatedSprite.flip_h = true
	elif is_on_floor():
		animatedSprite.animation = ANIMATION_IDLE
