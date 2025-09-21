extends CharacterBody2D

# Reference childrens
@onready var texture: Sprite2D = $Texture

# Player Properies
var GRAVITY: float = 5000.0
var SPEED: float = 42000.0

const ROTATIONAL_SPEED: float = 6.0

const SHIP_ROTATIONAL_SPEED: float = 6.0
const SHIP_MAXANGLE_UP: float = -45.0
const SHIP_MAXANGLE_DOWN: float = 45.0
const SHIP_MAXVELO_y: float = 1000.0

# Skins
var CUBE_SKIN = preload("res://files/assets/sprites/skins/cube1.png")
var SHIP_SKIN = preload("res://files/assets/sprites/skins/ship1.png")

var dead: bool = false
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
			# Makes the ship tilt upward or downward
			if Input.is_action_pressed("Player Jump"):
				# Tilt upwards
				texture.rotation_degrees = lerp(texture.rotation_degrees , SHIP_MAXANGLE_UP, SHIP_ROTATIONAL_SPEED * delta)
			else:
				# Tilt downwards
				texture.rotation_degrees = lerp(texture.rotation_degrees , SHIP_MAXANGLE_DOWN, SHIP_ROTATIONAL_SPEED * delta)
	else:
		if gamemode == 1:
		# Round to nearest 0 or 180 rotation degress
			texture.rotation_degrees = round(texture.rotation_degrees / 180.0) * 180.0
		if gamemode == 2:
			texture.rotation_degrees = 0.0
	
	# Change texture for different gamemodes
	match gamemode:
		1: # Cube
			texture.texture = CUBE_SKIN
		2: # Ship
			texture.texture = SHIP_SKIN
	
	# Jumping Mechanic
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
	if Input.is_action_pressed("Player Jump"):
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
		
		# If the player collided with a spike
		if collider.is_in_group("Spikes"):
			emit_signal("player_death")
			dead = true
			break
		
		# Check if the player is NOT on top of the blocks and collided with the sides
		if not normal.is_equal_approx( Vector2(0, -1) ):
			emit_signal("player_death")
			dead = true
			break

# End of System
