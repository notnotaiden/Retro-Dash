extends CharacterBody2D

# Reference childrens
@onready var texture: Sprite2D = $Texture
@onready var feet_area: Area2D = $FeetArea

# Player Properies
var GRAVITY: float = 5000.0
var SPEED: float = 42000.0
const ROTATIONAL_SPEED: float = 6.0
## The rotational speed for the ship gamemode
const SHIP_ROTATIONAL_SPEED: float = 6.0
## The max angle the player can go upward for the ship gamemode
const SHIP_MAXANGLE_UP: float = -70.0
## The max angle the player can go downward for the ship gamemode
const SHIP_MAXANGLE_DOWN: float = 60.0
## The max y velocity the player could go for the ship gamemode
const SHIP_MAXVELO_y: float = 1000.0

# Skins
var CUBE_SKIN = preload("res://files/assets/sprites/skins/cube1.png")
var SHIP_SKIN = preload("res://files/assets/sprites/skins/ship1.png")

## Holds the state for if the player has died
var dead: bool = false
## Holds the current gamemode the player is in
@export var gamemode: int = 1

signal player_death

# General Functions
func _physics_process(delta):
	# Change gravity based on gamemode
	match gamemode:
		1: # Cube
			GRAVITY = 5000.0
		2: # Ship
			GRAVITY = 1400.0
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
		# Rotates texture
		if gamemode == 1:
			texture.rotation_degrees += ROTATIONAL_SPEED
		if gamemode == 2:
			var rotation_speed: float = ( SHIP_ROTATIONAL_SPEED * delta ) / 3.0
			# Makes the ship tilt upward or downward
			if Input.is_action_pressed("Player Jump"):
				# Tilt upwards
				texture.rotation_degrees = lerp(texture.rotation_degrees , SHIP_MAXANGLE_UP, rotation_speed)
			else:
				# Tilt downwards
				texture.rotation_degrees = lerp(texture.rotation_degrees , SHIP_MAXANGLE_DOWN, rotation_speed)
	else:
		var snapped_rotation: float
		if gamemode == 1:
		# Round to nearest 0 or 180 rotation degress
			snapped_rotation = round(texture.rotation_degrees / 180.0) * 180.0
		if gamemode == 2:
			snapped_rotation = 0.0
		
		# Transition smoothly
		texture.rotation_degrees = lerp(texture.rotation_degrees, snapped_rotation, 0.2)
	
	# Change texture for different gamemodes
	match gamemode:
		1: # Cube
			texture.texture = CUBE_SKIN
		2: # Ship
			texture.texture = SHIP_SKIN
	
	# Jumping Mechanic
	if Input.is_action_pressed("Player Jump"):
		player_jump(delta)
	# Move cube infinitely to the side
	player_move(delta)
	if not dead:
		move_and_slide()
	# Death Mechanic
	player_death_collide()

# End

# Basic Player Movement
## Basic Player Movement:
## Responsible for jumping
## (Main Function)
func player_jump(delta):
	# Jumping Mechanic (Cube)
	match gamemode:
		1: # Cube
			if is_on_floor():
				velocity.y = GameProperties.CUBE_JUMPHEIGHT
		2: # Ship
			velocity.y += GameProperties.SHIP_JUMPHEIGHT * delta
			# Clamp
			velocity.y = clamp(velocity.y, -SHIP_MAXVELO_y, SHIP_MAXVELO_y)
## Basic Player Movement:
## Responsible for infinitely moving the player on the x axis
## (Main Function)
func player_move(delta):
	velocity.x = SPEED * delta

# End System

# Death Mechanic
## Death Mechanic:
## Responsible for emitting "player_death" signal when the player collides with a spike or a wall
## (Main Function)
func player_death_collide():
	for slide in range(get_slide_collision_count()):
		var collision = get_slide_collision(slide)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		# If the player collided with the ceiling do nothing
		if collider.is_in_group("Ceiling"):
			break
		
		# Kill when colliding with a spike
		if collider.is_in_group("Spikes"):
			emit_signal("player_death")
			dead = true
			break
		
		# Kill when colliding with the sides of a block
		if collider.is_in_group("Blocks"):
			# Tolerance system (So the player doesn't immediently die when it collides to the corner of the block)
			var up_dot = Vector2(0, -1)
			var tolerance: float = 0.5 
			
			if normal.dot(up_dot) > tolerance and velocity.y >= 0.0:
				break
			else:
				emit_signal("player_death")
				dead = true
				break

# End of System
