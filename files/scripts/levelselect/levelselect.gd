extends Node2D

@onready var camera: Camera2D = $Camera
@onready var fade_in: ColorRect = $UI/FadeIn
@onready var fade_out: ColorRect = $UI/FadeOut
@onready var fade_out_delay: Timer = $FadeOutDelay

@onready var levels: Control = $UI/Levels
@onready var level_margins: MarginContainer = $UI/Levels/Margins
@onready var hbox: HBoxContainer = $UI/Levels/Margins/HBoxContainer

@onready var ground_sprite: Sprite2D = $ParallaxGround/Ground
@onready var bg_sprite: Sprite2D = $ParallaxBG/BG

var current_level: int = 1
## Holds the current path to the scene we want to teleport our user in
var scene_path: String
## Holds the current position of the level node
var level_pos_x: float = 0.0

var random_color: Color

# General Functions
func _ready():
	GameProperties.playing = false
	fade_in.visible = true
	
	# Generate new random color
	random_color =  Color(randf(), randf(), randf())

func _process(delta):
	# Moving camera along with parallax
	camera.position.x += GameProperties.camera_speed_menu * delta
	
	# Fade in
	if fade_in != null:
		fade_in.color.a = lerp(fade_in.color.a, 0.0, 0.1)
		
		if fade_in.color.a <= 0.001:
			fade_in.queue_free()
	
	# Change BG and Ground color overtime
	ground_sprite.modulate = ground_sprite.modulate.lerp(random_color, 0.001)
	bg_sprite.modulate = bg_sprite.modulate.lerp(random_color, 0.001)
	
	# If the player is close to the randomly assigned color, generate a new color again
	if ground_sprite.modulate.is_equal_approx(random_color):
		# Generate new color
		random_color =  Color(randf(), randf(), randf())

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			# Level switching
			if event.keycode == KEY_LEFT or event.keycode == KEY_A:
				on_previous_pressed()
			if event.keycode == KEY_RIGHT or event.keycode == KEY_D:
				on_next_pressed()
			
			# Back system
			if event.keycode == KEY_ESCAPE:
				on_back_pressed()

# Back System
## Back System:
## Sends the user back to the main menu
## (Signal Function)
func on_back_pressed():
	start_fade_out()
	scene_path = "res://files/scenes/mainmenu.tscn"

# End

# Play System
## Play System:
## Sends the user to GameScene
## (Signal Function)
func on_play_pressed():
	start_fade_out()
	scene_path = "res://files/scenes/loading_screen.tscn"

# End

# Fade out
## Fade out:
## Fades out the screen and teleports the user to a new scene, either Gamescene or the Main Menu
## (Main Function)
func start_fade_out():
	# Make the fade out on top of the UI elements
	fade_out.z_index = 5
	fade_out.color.a = 0.0
	fade_out.visible = true
	
	# Create tween for tweening the fade out visibility property
	var tween = create_tween()
	tween.tween_property(fade_out, "color:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	fade_out_delay.start(1.0)
	
	await fade_out_delay.timeout
	get_tree().change_scene_to_file.call_deferred(scene_path)

# End of System

# Changing Levels
## Changing Levels Mechanic:
## Goes to the next level
## (Signal Function)
func on_next_pressed():
	if not current_level == 4:
		current_level += 1
		level_pos_x -= 1280
		
		var tween = create_tween()
		tween.tween_property(levels, "position:x", level_pos_x, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

## Changing Levels Mechanic:
## Goes to the previous level
## (Signal Function)
func on_previous_pressed():
	if not current_level == 1:
		current_level -= 1
		level_pos_x += 1280
		
		var tween = create_tween()
		tween.tween_property(levels, "position:x", level_pos_x, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# End of System
