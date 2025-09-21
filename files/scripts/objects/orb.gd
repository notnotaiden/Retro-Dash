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
					1: # Yellow
						body.velocity.y = GameProperties.CUBE_JUMPHEIGHT
					2: # Blue
						return # No switching gravity functionality yet
