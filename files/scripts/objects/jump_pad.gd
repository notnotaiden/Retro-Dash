extends Area2D

@onready var texture: Sprite2D = $Texture
@export_enum("Yellow", "Blue") var pad_type: String = "Yellow"

## Prevents the user from touching the pad again
var has_touched: bool = false

# General Funtions
func _ready():
	match pad_type:
		"Yellow":
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
		"Blue":
			texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)

func on_body_entered(body):
	if body is CharacterBody2D: # Checks if its the player
		if not has_touched: # If the player hasn't touched it yet
			has_touched = true
			
			match pad_type:
				"Yellow":
					match body.gamemode:
						1: # Cube
							body.velocity.y = ( GameProperties.CUBE_JUMPHEIGHT * 1.35 ) * sign(body.GRAVITY)
						2: # Ship
							body.velocity.y = ( GameProperties.CUBE_JUMPHEIGHT * 1.0 ) * sign(body.GRAVITY)
						3: # Ball
							body.velocity.y = ( GameProperties.CUBE_JUMPHEIGHT * 1.0 ) * sign(body.GRAVITY)
				"Blue":
					body.flipped_gravity = !body.flipped_gravity
					
					if body.GRAVITY < 0.0: # If its flipped
						body.switch_gravity(500.0 ) 
					else:
						body.switch_gravity(-500.0 ) 
