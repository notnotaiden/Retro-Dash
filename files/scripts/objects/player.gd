extends CharacterBody2D

# Reference childrens
@onready var texture: Sprite2D = $Texture
@onready var feet_area: Area2D = $FeetArea

# Player Properies
var GRAVITY: float
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
var BALL_SKIN = preload("res://files/assets/sprites/skins/ball1.png")

## Holds the state for if the player has died
var dead: bool = false
## Holds the state to check if the player gravity should be flipped
var flipped_gravity: bool = false
## Holds the current gamemode the player is in
@export var gamemode: int = 1
var gamemode_portal: Area2D

signal player_death

# General Functions
func _ready():
	change_gamemode()

func _physics_process(delta):
	# Apply gravity
	if gamemode == 3:
		velocity.y += GRAVITY * delta
	else:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
	
	# Rotating texture
	if is_on_ceiling() or is_on_floor():
		rotate_texture(true, delta)
	else:
		rotate_texture(false, delta)
	
	# Gravity switching (Using a boolean variable makes it more forgiving and less annoying to switch)
	# Basically a pending gravity switch system
	# It allows the player to change the flipped_gravity bool in midair
	# And the player won't switch gravity not until it hits a surface
	if gamemode == 3:
		if flipped_gravity and ( is_on_floor() or is_on_ceiling() ):
			GRAVITY = -GRAVITY
			velocity.y = 0.0
			flipped_gravity = false
	else:
		if flipped_gravity:
			GRAVITY = -GRAVITY
			flipped_gravity = false
	
	# Jumping Mechanic
	player_jump(delta)
	# Move cube infinitely to the side
	player_move(delta)
	if not dead:
		move_and_slide()
	# Death Mechanic
	player_death_collide()

# End

# Change gamemode system
## Change gamemode system:
## Updates player properties whenever it becomes a new gamemode
## (Main Function
func change_gamemode():
	match gamemode:
		1: # Cube
			texture.texture = CUBE_SKIN # Changing texture for different gamemodes
			GRAVITY = GameProperties.CUBE_GRAVITY # Change gravity based on gamemode
		2: # Ship
			texture.texture = SHIP_SKIN # Changing texture for different gamemodes
			GRAVITY = GameProperties.SHIP_GRAVITY # Change gravity based on gamemode
		3: # Ball
			texture.texture = BALL_SKIN # Changing texture for different gamemodes
			GRAVITY = GameProperties.BALL_GRAVITY # Change gravity based on gamemode

# End

# Texture Rotation System
## Texture Rotation System:
## How the texture rotates based on different gamemodes
## (Main Function)
func rotate_texture(on_floor: bool, delta: float):
	if not on_floor:
		# How the texture rotates based on different gamemodes
		if gamemode == 1: # Cube
			texture.rotation_degrees += ROTATIONAL_SPEED
		if gamemode == 2: # Ship
			var rotation_speed: float = ( SHIP_ROTATIONAL_SPEED * delta ) / 3.0
			# Makes the ship tilt upward or downward
			if Input.is_action_pressed("Player Jump"):
				# Tilt upwards
				texture.rotation_degrees = lerp(texture.rotation_degrees , SHIP_MAXANGLE_UP, rotation_speed)
			else:
				# Tilt downwards
				texture.rotation_degrees = lerp(texture.rotation_degrees , SHIP_MAXANGLE_DOWN, rotation_speed)
		if gamemode == 3: # Ball
			texture.rotation_degrees += ROTATIONAL_SPEED
	else:
		# How the texture snaps back to the default rotation based on different gamemodes
		if gamemode == 1: # Cube
			var snapped_rotation: float
			# Round to nearest 0 or 180 rotation degress
			snapped_rotation = round(texture.rotation_degrees / 180.0) * 180.0
			
			# Transition smoothly
			texture.rotation_degrees = lerp(texture.rotation_degrees, snapped_rotation, 0.2)
		if gamemode == 2: # Ship
			texture.rotation_degrees = 0.0
		if gamemode == 3: # Ball
			# Rotate it regardless if its on the ground
			texture.rotation_degrees += ROTATIONAL_SPEED

# End of System

# Basic Player Movement
## Basic Player Movement:
## Responsible for one click actions
## (Main Function)
func player_jump(delta):
	# Jumping Mechanic (Cube)
	match gamemode:
		1: # Cube (Jumping)
			if Input.is_action_pressed("Player Jump"):
				if is_on_floor() or is_on_ceiling():
					if GRAVITY < 0.0: # If gravity is flipped
						velocity.y = -GameProperties.CUBE_JUMPHEIGHT
					else:
						velocity.y = GameProperties.CUBE_JUMPHEIGHT
		2: # Ship (Propelling upwards)
			if Input.is_action_pressed("Player Jump"):
				if GRAVITY < 0.0: # If gravity is flipped
					velocity.y += -GameProperties.SHIP_JUMPHEIGHT * delta
				else:
					velocity.y += GameProperties.SHIP_JUMPHEIGHT * delta
				
				# Clamp velocity so it doesn't goes past the max velocity
				velocity.y = clamp(velocity.y, -SHIP_MAXVELO_y, SHIP_MAXVELO_y)
		3: # Ball (Switching Gravity)
			if Input.is_action_just_pressed("Player Jump"):
				flipped_gravity = !flipped_gravity
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
			var down_dot = Vector2(0, 1)
			var tolerance: float = 0.5 
			
			if normal.dot(up_dot) > tolerance and velocity.y >= 0.0:
				break
			# If the player has its gravity flipped or is a ball 
			# allow them to not die upon hitting the bottom of a block
			elif normal.dot(down_dot)> tolerance and velocity.y >= 0.0 and ( gamemode == 3 or GRAVITY < 0.0) :
				break
			else:
				emit_signal("player_death")
				dead = true
				break

# End of System
