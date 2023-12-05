#*******************************************************************************
# @file    game_master.gd
# @project GDFish
# @brief   Handles the overall game state
# @author  ImpendingMoon
#*******************************************************************************

extends Node

@onready var World = $World

var FishClass = preload("res://nodes/fish.tscn")
var FoodClass = preload("res://nodes/food.tscn")

const MAX_FOOD = 10

func _process(delta) -> void:

	if(Input.is_action_just_pressed("PrimaryCursorAction")):
		spawnFood()


	if(Input.is_action_pressed("SecondaryCursorAction")):
		World.add_child(FishClass.instantiate())

	if(Input.is_action_just_pressed("ui_down")):
		print("Fish Count: ", get_tree().get_nodes_in_group("Fish").size())

	if(Input.is_action_just_pressed("ui_cancel")):
		for fish in get_tree().get_nodes_in_group("Fish"):
			fish.get_parent().remove_child(fish)
			fish.queue_free()



func spawnFood() -> void:
	if(get_tree().get_nodes_in_group("Food").size() > MAX_FOOD):
		return

	var mousePos = get_viewport().get_mouse_position()
	var FoodObj = FoodClass.instantiate()
	FoodObj.global_position = mousePos
	World.add_child(FoodObj)
