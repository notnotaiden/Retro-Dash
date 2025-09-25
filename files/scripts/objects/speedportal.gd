extends Area2D
class_name Speedportal

@onready var texture: Sprite2D = $Texture
@onready var particles: CPUParticles2D = $Particles
@export_enum("0.75","1.0","1.2","1.5","1.75") var speed: String = "1.0"

var has_used: bool = false

# General Functions
func _ready():
	# Sets the region rect (The part in the texture we only want to see)
	match speed:
		"0.75":
			particles.color = Color.LIGHT_YELLOW
			texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
		"1.0":
			particles.color = Color.LIGHT_BLUE
			texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)
		"1.2":
			particles.color = Color.GREEN_YELLOW
			texture.region_rect = Rect2(64.0, 0.0, 32.0, 32.0)
		"1.5":
			particles.color = Color.PINK
			texture.region_rect = Rect2(96.0, 0.0, 32.0, 32.0)
		"1.75":
			particles.color = Color.LIGHT_CORAL
			texture.region_rect = Rect2(128.0, 0.0, 32.0, 32.0)

# Change Speed
## Change Speed System:
## Change the current speed of the player
## (Signal Function)
func on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		if not has_used:
			has_used = true
			
			# Speed Portals
			body.SPEED = body.SPEED * float(speed)
