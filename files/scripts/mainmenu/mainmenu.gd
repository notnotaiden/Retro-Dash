extends Node2D

# Reference scene nodes
@onready var camera: Camera2D = $Camera
@onready var player: CharacterBody2D = $Gameplay/Player
@onready var version: Label = $UI/Version

# UI
@onready var play: Button = $UI/Play
@onready var icons: Button = $UI/Icons
@onready var exit: Button = $UI/Exit
@onready var settings: Button = $UI/Bottom/Settings
@onready var credits: Button = $UI/Bottom/Credits
@onready var logo: TextureRect = $UI/Logo
@onready var fade_in: ColorRect = $UI/Fadein
@onready var settings_ui: Panel = $UI/Settings
@onready var settings_back: Button = $UI/Settings/Back
@onready var sound_slider: HSlider = $UI/Settings/SoundSlider
@onready var music_slider: HSlider = $UI/Settings/MusicSlider
@onready var credits_ui: Panel = $UI/Credits
@onready var credits_back: Button = $UI/Credits/Back
@onready var ui_layer: CanvasLayer = $UI
@onready var fade_out: ColorRect = $UI/FadeOut

@onready var ground_sprite: Sprite2D = $ParallaxGround/Ground
@onready var bg_sprite: Sprite2D = $ParallaxBG/BG

@onready var play_delay: Timer = $PlayDelay

var on_ui: bool = false
## Holds the state where if the settings or icon select panel is currently on the screen
var on_screen: bool = false
var random_color: Color

# General Functions
func _ready():
	GameProperties.playing = false
	fade_in.visible = true
	
	# Prevents the player from moving infinitely to the side
	player.on_menu = true
	
	# Generate new random color
	random_color =  Color(randf(), randf(), randf())
	
	# Set version
	version.text = "V%s" % [ProjectSettings.get_setting("application/config/version")]
	
	# Animate menu
	runtime_anim()

func _process(delta):
	# Fade in
	if fade_in != null:
		fade_in.color.a = lerp(fade_in.color.a, 0.0, 0.1)
		
		if fade_in.color.a <= 0.001:
			fade_in.queue_free()
	
	# Moving camera along with parallax
	camera.position.x += GameProperties.camera_speed_menu * delta
	
	# Jumping mechanic
	if not on_ui:
		if Input.is_action_pressed("Player Jump"):
			player.player_jump(delta)
	
	# Change BG and Ground color overtime
	ground_sprite.modulate = ground_sprite.modulate.lerp(random_color, 0.001)
	bg_sprite.modulate = bg_sprite.modulate.lerp(random_color, 0.001)
	
	# If the player is close to the randomly assigned color, generate a new color again
	if ground_sprite.modulate.is_equal_approx(random_color):
		# Generate new color
		random_color =  Color(randf(), randf(), randf())

# Play System
## Play System:
## Plays a fade out animation
## (Signal Function)
func on_play_pressed():
	# Make the fade out on top of the UI elements
	fade_out.z_index = 5
	
	# Create tween for tweening the fade out visibility property
	var tween = create_tween()
	tween.tween_property(fade_out, "color:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	play_delay.start(1.0)

## Play System:
## Sends the user to the level select scene after the timer has timed out
## (Signal Function)
func on_play_delay_timeout():
	get_tree().change_scene_to_file("res://files/scenes/levelselect.tscn")

# Runtime Animation
## Runtime Animation:
## Moves the UI buttons to their respective positions upon runtime
## (Main Function)
func runtime_anim():
	play.position.x = -500
	icons.position.x = -500
	exit.position.x = -500
	
	settings.position.y = 800
	credits.position.y = 800
	
	logo.position.y = -200
	
	var play_tween = create_tween()
	play_tween.tween_property(play, "position:x", 34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	var icons_tween = create_tween()
	icons_tween.tween_property(icons, "position:x", 34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.4)
	var exit_tween = create_tween()
	exit_tween.tween_property(exit, "position:x", 34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.5)
	
	var settings_tween = create_tween()
	settings_tween.tween_property(settings, "position:y", 628, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	var credits_tween = create_tween()
	credits_tween.tween_property(credits, "position:y", 628, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.4)
	
	var logo_tween = create_tween()
	logo_tween.tween_property(logo, "position:y", 11.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)

# End of System

# On UI System
## On UI System:
## Prevents the player from jumping when the user is hovering over a UI element (mouse enter)
## (Signal Function)
func on_mouse_enter():
	on_ui = true
# On UI System
## On UI System:
## Prevents the player from jumping when the user is hovering over a UI element (mouse exit)
## (Signal Function)
func on_mouse_exit():
	on_ui = false
# End

# Settings System
## Settings System:
## Shows the settings UI upon button press
## (Signal Function)
func show_settings():
	settings.release_focus()
	
	if not on_screen:
		on_screen = true
	else:
		return
	
	settings_ui.visible = true
	settings_ui.position.y = 800.0
	
	var tween = create_tween()
	tween.tween_property(settings_ui, "position:y", 158.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Update sliders value
	sound_slider.value = GameProperties.user_settings["settings"]["sound_vol"] * 100
	music_slider.value = GameProperties.user_settings["settings"]["music_vol"] * 100

## Settings System:
## Changes the sound volume settings
## (Signal Function)
func on_sound_slider_dragged(value):
	GameProperties.user_settings["settings"]["sound_vol"] = value / 100.0

## Settings System:
## Changes the music volume settings
## (Signal Function)
func on_music_slider_dragged(value):
	GameProperties.user_settings["settings"]["music_vol"] = value / 100.0

## Settings System:
## Moves the settings UI back to offscreen
## (Signal Function)
func on_settings_back():
	settings_back.release_focus()
	on_screen = false
	
	# Release focus to all sliders
	sound_slider.release_focus()
	music_slider.release_focus()
	
	var tween = create_tween()
	tween.tween_property(settings_ui, "position:y", 800.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# End of System

# Credits System
## Credits System:
## Shows the credits UI
## (Signal Function)
func show_credits():
	credits.release_focus()
	
	if not on_screen:
		on_screen = true
	else:
		return
	
	credits_ui.visible = true
	credits_ui.position.y = 800.0
	
	var tween = create_tween()
	tween.tween_property(credits_ui, "position:y", 158.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func on_credits_back():
	credits_back.release_focus()
	on_screen = false
	
	var tween = create_tween()
	tween.tween_property(credits_ui, "position:y", 800.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# End of System
