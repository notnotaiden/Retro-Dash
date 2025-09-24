extends CharacterBody2D

# Reference childrens
@onready var texture: Node2D = $SkinDisplayer
@onready var hitbox: CollisionShape2D = $Hitbox

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

## Holds the state for if the player has died
var dead: bool = false
## Holds the state to check if the player gravity should be flipped
var flipped_gravity: bool = false
## Holds the current gamemode the player is in
@export var gamemode: int = 1

## Holds the recently collided gamemode portal
var gamemode_portal: Area2D
## Holds the recently collided color trigger
var color_trigger: Area2D
var COLOR_TRIGGER_SCENE_FILE: PackedScene = preload("res://files/objects/color_trigger.tscn")

signal player_death

# General Functions
func _ready():
	change_gamemode()
	texture.change_skin(gamemode)
	
	# Default BG and Ground Color
	# Immediently instantiate a color trigger node so it doesn't throw an error
	# Instantiate a new color trigger node and store it in color_trigger
	color_trigger = COLOR_TRIGGER_SCENE_FILE.instantiate()

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
	
	if gamemode == 3:
		if is_on_ceiling() or is_on_floor():
			switch_gravity(0.0)
	
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
	texture.rotation_degrees = 0.0
	
	match gamemode:
		1: # Cube
			hitbox.shape.size = Vector2(80.0, 80.0)
			hitbox.position.y = 0.0
			
			GRAVITY = GameProperties.CUBE_GRAVITY # Change gravity based on gamemode
		2: # Ship
			hitbox.shape.size = Vector2(80.0, 68.0)
			hitbox.position.y = 8.0
			
			GRAVITY = GameProperties.SHIP_GRAVITY # Change gravity based on gamemode
		3: # Ball
			hitbox.shape.size = Vector2(80.0, 80.0)
			hitbox.position.y = 0.0
			
			GRAVITY = GameProperties.BALL_GRAVITY # Change gravity based on gamemode
	
	# Update texture
	texture.change_skin(gamemode)

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
			snapped_rotation = round(texture.rotation_degrees / 90.0) * 90.0
			
			# Transition smoothly
			texture.rotation_degrees = lerp(texture.rotation_degrees, snapped_rotation, 0.2)
		if gamemode == 2: # Ship
			texture.rotation_degrees = lerp(texture.rotation_degrees, 0.0, 0.2)
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

## Basic Player Movement:
## Responsible for switching the player's gravity
## (Helper Function)
func switch_gravity(velo: float):
	# Gravity switching (Using a boolean variable makes it more forgiving and less annoying to switch)
	# Basically a pending gravity switch system
	# It allows the player to change the flipped_gravity bool in midair
	# And the player won't switch gravity not until it hits a surface
	if flipped_gravity:
		GRAVITY = -GRAVITY
		velocity.y = velo
		flipped_gravity = false

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
		
		# If the player collided with the ceiling do nothing EXCEPT if its a cube
		if is_on_ceiling():
			if not GRAVITY < 0.0 and gamemode == 1: # Check if the cube gravity is flipped:
				emit_signal("player_death")
				dead = true
		
		if is_on_floor(): # Kill the player when it touched the floor, is a cube and gravity is flipped
			if GRAVITY < 0.0 and gamemode == 1:
				emit_signal("player_death")
				dead = true
		
		# Kill when colliding with a spike
		if collider.is_in_group("Spikes"):
			emit_signal("player_death")
			dead = true
		
		# Kill when colliding with the sides of a block
		if collider.is_in_group("Blocks"):
			# Find the exact pixel where the collision started
			var collision_point = collision.get_position()
			# Find the exact cell of the block
			var cell = collider.local_to_map(collider.to_local(collision_point))
			# Find the exact position of that same cell
			var cell_pos = collider.map_to_local(cell)
			# Find tile top y postion
			var tile_size = collider.tile_set.tile_size.y * collider.scale.y
			var top_y = collider.to_global(cell_pos).y - tile_size
			# Find the bottom position of the player
			var bottom_y = global_position.y + (hitbox.shape.size.y / 2) 
			
			if normal.y < -0.5: # Forgiveness, teleport player on top of the block
				# Snap position
				if gamemode == 1:
					global_position.y = top_y * sign(GRAVITY)
				
				# Round to nearest 0 or 180 rotation degress
				var snapped_rotation = round(texture.rotation_degrees / 90.0) * 90.0
				
				# Transition smoothly
				texture.rotation_degrees = lerp(texture.rotation_degrees, snapped_rotation, 0.2)
				
				velocity.y = 0.0
			elif abs(bottom_y - top_y) <= 50: # Checks how close the bottom of the player on top of the block
				# Snap position
				if gamemode == 1:
					global_position.y = top_y - 1 * sign(GRAVITY)
				
				# Round to nearest 0 or 180 rotation degress
				var snapped_rotation = round(texture.rotation_degrees / 90.0) * 90.0
				
				# Transition smoothly
				texture.rotation_degrees = lerp(texture.rotation_degrees, snapped_rotation, 0.2)
				
				velocity.y = 0.0
			elif abs(normal.x) > 0.5 and normal.y > -0.5: # The player has collided with the sides of the block
				emit_signal("player_death")
				dead = true
				break

# End of System
