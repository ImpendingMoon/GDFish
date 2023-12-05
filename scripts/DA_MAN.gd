#*******************************************************************************
# @file    DA_MAN.gd
# @project GDFish
# @brief   Test object to make sure the basics are working. Ignore me >:L
# @author  ImpendingMoon
#*******************************************************************************

extends Sprite2D

var velocity: Vector2 = Vector2(0, 0)
const SPEED: float = 200.0

func _physics_process(delta):
	# Inefficient, yes. There's nothing more to that.
	if(Input.is_action_pressed("ui_right")):
		velocity.x += 1

	if(Input.is_action_pressed("ui_left")):
		velocity.x -= 1

	if(Input.is_action_pressed("ui_up")):
		velocity.y -= 1

	if(Input.is_action_pressed("ui_down")):
		velocity.y += 1

	if(velocity.length() > 1):
		velocity = velocity.normalized()

	# I didn't make this a KinematicBody2D so let's ignore that
	position += (velocity * SPEED * delta)

	velocity = Vector2.ZERO
