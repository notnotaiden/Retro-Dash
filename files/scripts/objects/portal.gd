extends Area2D

@onready var texture: Sprite2D = $Texture
@export_enum("Cube","Ship") var gamemode_type: String = "Ship"

var gamemode: int

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

# Change Gamemode
## Change Gamemode System:
## Change the current gamemode of the player
## (Signal Function)
func on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		body.gamemode = gamemode
