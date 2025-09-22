extends Area2D

@onready var texture: Sprite2D = $Texture
@export_enum("Yellow", "Blue") var orb_type: String = "Yellow"

var orb: int

# General Functions
func _ready():
	# Sets the region rect (The part in the texture we only want to see)
	match orb_type:
		"Yellow":
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
			orb = 1
		"Blue":
			texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)
			orb = 2

# Orb System
## Orb System
## Yellow: Makes the player jump mid air, Blue = switches gravity
## (General Function)
func _process(_delta):
	if Input.is_action_just_pressed("Player Jump"):
		for body in get_overlapping_bodies():
			if body is CharacterBody2D:
				match orb:
					1: # Yellow ( Extra Jump )
						match body.gamemode:
							1: # Cube
								if body.GRAVITY < 0.0: # If the player gravity is flipped
									body.velocity.y = -GameProperties.CUBE_JUMPHEIGHT
								else:
									body.velocity.y = GameProperties.CUBE_JUMPHEIGHT
							2: # Ship
								if body.GRAVITY < 0.0: # If the player gravity is flipped
									body.velocity.y = -GameProperties.CUBE_JUMPHEIGHT / 2.0
								else:
									body.velocity.y = GameProperties.CUBE_JUMPHEIGHT / 2.0
							3: # Ball
								# Flip bool back  so it doesn't switch gravitiy
								body.flipped_gravity = !body.flipped_gravity 
								
								if body.GRAVITY < 0.0: # If the player gravity is flipped
									body.velocity.y = -GameProperties.CUBE_JUMPHEIGHT / 1.5
								else:
									body.velocity.y = GameProperties.CUBE_JUMPHEIGHT / 1.5
					2: # Blue ( Flip gravtiy )
						if body.gamemode == 3:
							body.flipped_gravity = !body.flipped_gravity
							body.GRAVITY = -body.GRAVITY
							body.velocity.y = 0.0
						else:
							body.flipped_gravity = !body.flipped_gravity
