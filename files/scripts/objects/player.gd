extends CharacterBody2D

# Reference childrens
@onready var texture: Sprite2D = $Texture

# Player Properies
var GRAVITY: float = 5000.0
var SPEED: float = 35000.0
var JUMP_HEIGHT: float = -1230.0
const ROTATIONAL_SPEED: float = 6.0

var dead: bool = false

signal player_death

# General Functions
func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
		# Rotates texture
		texture.rotation_degrees += ROTATIONAL_SPEED
	else:
		# Round to nearest 0 or 180 rotation degress
		texture.rotation_degrees = round(texture.rotation_degrees / 180.0) * 180.0
	
	# Move cube infinitely to the side
	player_move(delta)
	# Jumping Mechanic
	player_jump()
	# Move Body
	if not dead:
		move_and_slide()
	# Death Mechanic
	player_death_collide()

# End

# Basic Player Movement
## Basic Player Movement:
## Responsible for jumping
## (Main Function)
func player_jump():
	# Jumping Mechanic (Cube)
	if Input.is_action_pressed("Player Jump") and is_on_floor():
		velocity.y = JUMP_HEIGHT
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
