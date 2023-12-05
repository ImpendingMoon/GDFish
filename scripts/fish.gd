#*******************************************************************************
# @file    fish.gd
# @project GDFish
# @brief   Implements generic fish behavior
# @author  ImpendingMoon
#*******************************************************************************

extends CharacterBody2D

@onready var navCollider = $NavigationHelper
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

@export var hungerThreshold: float = 30
@export var starveThreshold: float = 60
@export var movementSpeed: Vector2 = Vector2(100, 50)

@export var foodGroup: String = "GuppyFood"
@export var lethalFoodGroup: String = "DeadlyFood"
@export var chaseGroup: String = "ChaseMe"

var currentTarget: Vector2 = Vector2.ZERO
var direction: bool = true
var nextDirection: bool = true
var currentGoal = goalStates.IDLE
var currentState = swimStates.SWIM

var timeAlive = 0.0
var timeSinceEaten = 0.0

var SCREEN_SIZE: Vector2i = Vector2i(
	ProjectSettings.get("display/window/size/viewport_width"),
	ProjectSettings.get("display/window/size/viewport_height") - 50
)

func _ready() -> void:
	currentTarget = Vector2(randf_range(0, SCREEN_SIZE.x), randf_range(0, SCREEN_SIZE.y))
	movementSpeed += Vector2(randf_range(-10, 10), randf_range(-10, 10))



func _physics_process(delta) -> void:

	match currentGoal:
		goalStates.IDLE:
			# Check if reached target. If so, pick a new one
			if(navCollider.get_global_rect().has_point(currentTarget)):
				calculateNewTarget()

		goalStates.HUNGER:
			# Search for food
			# If none exist, slow down and randomly target
			if(get_tree().get_nodes_in_group(foodGroup).is_empty()):
				movementSpeed = Vector2(80, 30)

				if(navCollider.get_global_rect().has_point(currentTarget)):
					calculateNewTarget()

			# If food exists, speed up and chase it
			else:
				movementSpeed = Vector2(120, 70)
				currentTarget = findFood()


		goalStates.CHASE:
			# ChaseTargets will send signals to all fish, but not all fish
			# are meant to follow
			if(!get_tree().get_nodes_in_group(chaseGroup).is_empty()):
				currentTarget = get_tree().get_first_node_in_group(chaseGroup).global_position
			else:
				currentGoal = goalStates.IDLE

		goalStates.DIE:
			# No more goals :(
			pass



	match currentState:
		swimStates.SWIM:
			# Calculate new velocity
			velocity = (currentTarget - global_position).normalized() * movementSpeed

			# Handle turning if needed
			nextDirection = velocity.x < 0

			if(nextDirection != direction):
				velocity = Vector2.ZERO
				turn(nextDirection)

			direction = nextDirection

			# Move tha fishy
			move_and_slide()

		swimStates.TURN:
			pass

		swimStates.EAT:
			# CONSUME
			pass

		swimStates.DEAD:
			if(global_position.y > SCREEN_SIZE.y):
				queue_free()
			velocity = Vector2(0, movementSpeed.y / 2)
			move_and_slide()

	if(isHungry()):
		currentGoal = goalStates.HUNGER
		# TEMP until animations are added
		sprite.modulate.r = 0.75
		sprite.modulate.b = 0.75

	if(timeSinceEaten > starveThreshold):
		die()

	# We don't want a fish to grow up or starve if it's dead
	if(currentGoal != goalStates.DIE):
		timeAlive += delta
		timeSinceEaten += delta



func turn(direction: bool) -> void:
	# Don't want to turn if we're busy dying or something
	if(currentState != swimStates.SWIM):
		return

	currentState = swimStates.TURN

	# This will have animations to do later
	await get_tree().create_timer(0.5).timeout
	sprite.flip_h = !direction

	# State can be interrupted by outside events, like eating or dying
	if(currentState == swimStates.TURN):
		currentState = swimStates.SWIM



func findFood() -> Vector2:
	# If no food exists, closest target is the current target
	var closestTarget: Vector2 = self.currentTarget
	var closestDistance: float = INF

	# Objects in the food group should inherit Node2D or it will crash
	# Unfortunately no static typing in for loops
	for item in get_tree().get_nodes_in_group(foodGroup):
		var difference: Vector2 = (item.global_position - self.global_position)
		var distance: float = difference.length_squared()
		if(distance < closestDistance):
			closestTarget = item.global_position
			closestDistance = distance

	return closestTarget



func eat(quality: float) -> void:
	timeSinceEaten = 0.0 - quality
	sprite.modulate.r = 1.0
	sprite.modulate.b = 1.0
	if(currentGoal == goalStates.HUNGER):
		currentGoal = goalStates.IDLE
		calculateNewTarget()



func die() -> void:
	currentGoal = goalStates.DIE
	currentState = swimStates.DEAD
	# TODO: Play a death animation
	await get_tree().create_timer(0.5).timeout
	sprite.flip_v = true



func calculateNewTarget() -> void:
	currentTarget = Vector2(randf_range(0, SCREEN_SIZE.x), randf_range(0, SCREEN_SIZE.y))
	movementSpeed += Vector2(randf_range(-10, 10), randf_range(-10, 10))
	movementSpeed = movementSpeed.clamp(Vector2(80, 30), Vector2(120, 70))



func isHungry() -> bool:
	return timeSinceEaten > hungerThreshold



func _on_food_detector_area_entered(area: Area2D):
	if(!isHungry() || currentGoal == goalStates.DIE):
		return

	var areaGroup = area.get_groups()

	var edible: bool = areaGroup.has(foodGroup)
	var lethal: bool = areaGroup.has(lethalFoodGroup)

	# Ignore if not edible or lethal
	if( !(edible || lethal) ):
		return

	# Ignore if food has been eaten and is queued to be freed
	if(area.eaten):
		return

	area.eaten = true
	area.queue_free()
	eat(area.quality)



enum goalStates
{
	IDLE,
	HUNGER,
	CHASE,
	DIE,
}

enum swimStates
{
	SWIM,
	TURN,
	EAT,
	DEAD
}
