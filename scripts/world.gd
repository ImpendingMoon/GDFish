#*******************************************************************************
# @file    world.gd
# @project GDFish
# @brief   The primary game area.
# @less_serious_brief provides a place for the fishies to live :)
# @author  ImpendingMoon
#*******************************************************************************

extends Node2D

@onready var Background: Sprite2D = $Background

const Tank1ImagePath: String = "res://assets/backgrounds/tank1.png"
const Tank2ImagePath: String = "res://assets/backgrounds/tank2.png"
const Tank3ImagePath: String = "res://assets/backgrounds/tank3.png"
const Tank4ImagePath: String = "res://assets/backgrounds/tank4.png"



func _ready() -> void:
	changeBackgroundImage(Tank1ImagePath)



func changeBackgroundImage(image_path: String) -> void:
	# Godot should automatically free the previous texture when not in use.
	Background.texture = load(image_path)
