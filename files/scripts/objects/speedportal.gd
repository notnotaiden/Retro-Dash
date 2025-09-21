extends Area2D

@onready var texture: Sprite2D = $Texture
@export_enum("0.75","1.0","1.2","1.5","1.75") var speed: String = "1.0"

# General Functions
func _ready():
	# Sets the region rect (The part in the texture we only want to see)
	match speed:
		"0.75":
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
		"1.0":
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
		"1.2":
			texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)
		"1.5":
			texture.region_rect = Rect2(64.0, 0.0, 32.0, 32.0)
		"1.75":
			texture.region_rect = Rect2(64.0, 0.0, 32.0, 32.0)

# Change Speed
## Change Speed System:
## Change the current speed of the player
## (Signal Function)
func on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		# Speed Portals
		body.SPEED = body.SPEED * float(speed)
