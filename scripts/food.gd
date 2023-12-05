#*******************************************************************************
# @file    fish.gd
# @project GDFish
# @brief   Implements simple fish food functionality
# @author  ImpendingMoon
#*******************************************************************************

extends Area2D

@export var fall_speed: float = 20
@export var quality: float = 10
var eaten: bool = false

var SCREEN_SIZE: Vector2i = Vector2i(
	ProjectSettings.get("display/window/size/viewport_width"),
	ProjectSettings.get("display/window/size/viewport_height") - 50
)



func _physics_process(delta) -> void:
	global_position.y += fall_speed * delta
	if(global_position.y > SCREEN_SIZE.y):
		queue_free()
