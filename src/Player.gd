 extends KinematicBody2D

onready var animatedSprite = $AnimatedSprite

const ANIMATION_RUN = "run"
const ANIMATION_IDLE = "idle"

func _physics_process(delta):
	var axisX = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	print(axisX)
	if axisX > 0:
		animatedSprite.animation = ANIMATION_RUN
		animatedSprite.flip_h = false
	elif axisX < 0:
		animatedSprite.animation = ANIMATION_RUN
		animatedSprite.flip_h = true
	else:
		animatedSprite.animation = ANIMATION_IDLE
