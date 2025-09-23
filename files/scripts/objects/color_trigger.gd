extends Area2D

@export var bg_color: Color = Color.ROYAL_BLUE
## The amount of seconds it takes to change the BG color
@export var bg_change_time: float = 0.0
@export var ground_color: Color =  Color.ROYAL_BLUE
## The amount of seconds it takes to change the ground color
@export var ground_change_time: float = 0.0

signal color_trigger

func _on_body_entered(body):
	if body is CharacterBody2D: # Check if its the player
		body.color_trigger = self # Pass self to body
		emit_signal("color_trigger")
