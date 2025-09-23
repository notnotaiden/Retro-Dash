extends Node2D

# General Functions
func _ready():
	# If the player previews the scene directly here
	# then teleport him to the actual gamescene
	if "Level" in get_tree().current_scene.name :
		get_tree().change_scene_to_file.call_deferred("res://files/scenes/gamescene.tscn")
