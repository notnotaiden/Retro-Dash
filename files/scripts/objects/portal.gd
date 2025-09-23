extends Area2D

@onready var texture: Sprite2D = $Texture
@export_enum("Cube","Ship", "Ball", "Flipped Gravity") var gamemode_type: String = "Ship"

var gamemode: int
var has_touched: bool = false

# General Functions
func _ready():
	# Sets the region rect (The part in the texture we only want to see)
	match gamemode_type:
		"Cube": # Cube
			texture.region_rect = Rect2(34.0, 0.0, 13.0, 32.0)
			gamemode = 1
		"Ship": # Ship
			texture.region_rect = Rect2(50.0, 0.0, 13.0, 32.0)
			gamemode = 2
		"Ball": # Ball
			texture.region_rect = Rect2(2.0, 32.0, 13.0, 32.0)
			gamemode = 3
		"Flipped Gravity": # Flips the gravity of the player
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)
			gamemode = 4

# Change Gamemode
## Change Gamemode System:
## Change the current gamemode of the player
## (Signal Function)
func on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		if not has_touched:
			has_touched = true
			
			var gamemodes: Array = [1, 2, 3]
			if gamemode in gamemodes: # Check if the gamemode is cube, ship, or ball
				body.gamemode = gamemode
				body.gamemode_portal = self
				body.change_gamemode()
			else:
				body.flipped_gravity = !body.flipped_gravity
				
				if body.GRAVITY < 0.0: # If its flipped
					body.switch_gravity(-500.0 ) 
				else:
					body.switch_gravity(500.0 ) 
