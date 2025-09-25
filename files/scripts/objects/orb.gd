extends Area2D
class_name Orb

@onready var texture: Sprite2D = $Texture
@onready var particles: CPUParticles2D = $Particles
@export_enum("Yellow", "Blue") var orb_type: String = "Yellow"

var orb: int
var has_used: bool = false

# General Functions
func _ready():
	# Sets the region rect (The part in the texture we only want to see)
	match orb_type:
		"Yellow":
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
			particles.color = Color.YELLOW
			orb = 1
		"Blue":
			texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)
			particles.color = Color.DEEP_SKY_BLUE
			orb = 2

# Orb System
## Orb System
## Yellow: Makes the player jump mid air, Blue = switches gravity
## (General Function)
func _process(_delta):
	if Input.is_action_just_pressed("Player Jump"):
		for body in get_overlapping_bodies():
			if body is CharacterBody2D:
				if not has_used:
					has_used = true
					
					match orb:
						1: # Yellow ( Extra Jump )
							match body.gamemode:
								1: # Cube
									body.velocity.y = GameProperties.ORB_CUBE_JUMPHEIGHT * sign(body.GRAVITY)
								2: # Ship
									body.velocity.y = GameProperties.ORB_SHIP_JUMPHEIGHT * sign(body.GRAVITY)
								3: # Ball
									# Flip bool back to false so it doesn't switch gravitiy
									body.flipped_gravity = false
									
									body.velocity.y = GameProperties.ORB_BALL_JUMPHEIGHT * sign(body.GRAVITY)
						2: # Blue ( Flip gravtiy )
							if not body.gamemode == 3:
								body.flipped_gravity = !body.flipped_gravity
							
							body.switch_gravity(1.0, true)
