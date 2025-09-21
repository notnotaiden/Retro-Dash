extends Area2D

@export var gamemode: int = 2

# Change Gamemode
## Change Gamemode System:
## Change the current gamemode of the player
## (Signal Function)
func on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		body.gamemode = gamemode
