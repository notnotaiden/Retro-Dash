extends Node2D

# Different skin colors
@onready var outline: Sprite2D = $Outline
@onready var p1: Sprite2D = $P1
@onready var p2: Sprite2D = $P2

# Ship
@onready var ship: Node2D = $Ship

@onready var ship_outline: Sprite2D = $Ship/Outline
@onready var ship_p1: Sprite2D = $Ship/P1
@onready var ship_p2: Sprite2D = $Ship/P2

# Change Skin System
## Change Skin System:
## Changes the texture for different gamemodes
## (Main Function)
func change_skin(gamemode: int):
	match gamemode:
		1: # Cube
			outline.region_rect = GameProperties.user_settings["customization"]["cube_skin"]["outline"]
			p1.region_rect = GameProperties.user_settings["customization"]["cube_skin"]["p1"]
			p2.region_rect = GameProperties.user_settings["customization"]["cube_skin"]["p2"]
			
			# Update scale
			outline.scale = Vector2(2.5, 2.5)
			p1.scale = Vector2(2.5, 2.5)
			p2.scale = Vector2(2.5, 2.5)
			
			# Hide Ship Texture
			ship.visible = false
		2: # Ship
			# Cube Texture
			outline.region_rect = GameProperties.user_settings["customization"]["cube_skin"]["outline"]
			p1.region_rect = GameProperties.user_settings["customization"]["cube_skin"]["p1"]
			p2.region_rect = GameProperties.user_settings["customization"]["cube_skin"]["p2"]
			# Move Cube Texture on top of ship
			outline.scale = Vector2(1.0, 1.0)
			p1.scale = Vector2(1.0, 1.0)
			p2.scale = Vector2(1.0, 1.0)
			
			# Show Ship Texture
			ship.visible = true
			
			# Ship Texture
			ship_outline.region_rect = GameProperties.user_settings["customization"]["ship_skin"]["outline"]
			ship_p1.region_rect = GameProperties.user_settings["customization"]["ship_skin"]["p1"]
			ship_p2.region_rect = GameProperties.user_settings["customization"]["ship_skin"]["p2"]
		3: # Ball
			outline.region_rect = GameProperties.user_settings["customization"]["ball_skin"]["outline"]
			p1.region_rect = GameProperties.user_settings["customization"]["ball_skin"]["p1"]
			p2.region_rect = GameProperties.user_settings["customization"]["ball_skin"]["p2"]
			
			# Update scale
			outline.scale = Vector2(2.5, 2.5)
			p1.scale = Vector2(2.5, 2.5)
			p2.scale = Vector2(2.5, 2.5)
			
			# Hide Ship Texture
			ship.visible = false
	
	# Update Color
	p1.modulate = GameProperties.user_settings["customization"]["p1_color"]
	p2.modulate = GameProperties.user_settings["customization"]["p2_color"]
	
	ship_p1.modulate = GameProperties.user_settings["customization"]["p1_color"]
	ship_p2.modulate = GameProperties.user_settings["customization"]["p2_color"]
