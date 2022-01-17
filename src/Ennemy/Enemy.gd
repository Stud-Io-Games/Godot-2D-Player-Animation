extends "res://src/Actor.gd"


func _ready():
	set_physics_process(false) # deactivate the enemy at start of the game
	_velocity.x = -speed.x # go to the left
