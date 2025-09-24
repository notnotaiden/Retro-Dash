extends Area2D

@onready var texture: Sprite2D = $Texture
@onready var particles: CPUParticles2D = $Particles
@export_enum("Yellow", "Blue") var pad_type: String = "Yellow"

## Prevents the user from touching the pad again
var has_touched: bool = false

# General Funtions
func _ready():
	match pad_type:
		"Yellow":
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
			particles.color = Color.YELLOW
		"Blue":
			texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)
			particles.color = Color.DEEP_SKY_BLUE

func on_body_entered(body):
	if body is CharacterBody2D: # Checks if its the player
		if not has_touched: # If the player hasn't touched it yet
			has_touched = true
			
			match pad_type:
				"Yellow":
					match body.gamemode:
						1: # Cube
							body.velocity.y = GameProperties.PAD_CUBE_JUMPHEIGHT * sign(body.GRAVITY)
						2: # Ship
							body.velocity.y = GameProperties.PAD_SHIP_JUMPHEIGHT * sign(body.GRAVITY)
						3: # Ball
							body.velocity.y = GameProperties.PAD_BALL_JUMPHEIGHT * sign(body.GRAVITY)
				"Blue":
					if not body.gamemode == 3:
						body.flipped_gravity = !body.flipped_gravity
					
					body.switch_gravity(1.0, true) 
