extends Area2D

@onready var texture: Sprite2D = $Texture
@export var gamemode: int = 2

# General Functions
func _ready():
	# Changing texture based on gamemode
	match gamemode:
		1: # Cube
			texture.region_rect = Rect2(34.0, 0.0, 13.0, 32.0)
		2: # Ship
			texture.region_rect = Rect2(50.0, 0.0, 13.0, 32.0)
		3: # X0.75 Speed Portal
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)
		4: # X1.0 Speed Portal
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)
		5: # X1.2 Speed Portal
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)
		6: # X1.5 Speed Portal
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)
		7: # X1.75 Speed Portal
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)
		8: # X2.0 Speed Portal
			texture.region_rect = Rect2(18.0, 0.0, 13.0, 32.0)

# Change Gamemode
## Change Gamemode System:
## Change the current gamemode of the player
## (Signal Function)
func on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		# Speed Portals
		if gamemode == 3: # X0.75 Speed Portal:
			body.SPEED = body.SPEED * 0.75
		elif gamemode == 4:  # X1.0 Speed Portal:
			body.SPEED = body.SPEED * 1.0
		elif gamemode == 5:  # X1.2 Speed Portal:
			body.SPEED = body.SPEED * 1.2
		elif gamemode == 6:  # X1.5 Speed Portal:
			body.SPEED = body.SPEED * 1.5
		elif gamemode == 7:  # X1.75 Speed Portal:
			body.SPEED = body.SPEED * 1.75
		elif gamemode == 8:  # X2.0 Speed Portal:
			body.SPEED = body.SPEED * 2.0
		
		# Normal Gamemodes
		else: # Cube and Ship
			body.gamemode = gamemode
