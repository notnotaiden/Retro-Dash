extends Node2D

# Reference scene nodes
@onready var camera: Camera2D = $Camera
@onready var player: CharacterBody2D = $Gameplay/Player
@onready var version: Label = $UI/Version

# UI
@onready var play: Button = $UI/Play
@onready var icons: Button = $UI/Icons
@onready var exit: Button = $UI/Exit
@onready var settings: Button = $UI/Settings
@onready var credits: Button = $UI/Credits

@onready var logo: TextureRect = $UI/Logo

@onready var fade_in: ColorRect = $UI/Fadein

@onready var settings_ui: Panel = $UI/SettingsUI
@onready var settings_back: Button = $UI/SettingsUI/Back
@onready var sound_slider: HSlider = $UI/SettingsUI/SoundSlider
@onready var music_slider: HSlider = $UI/SettingsUI/MusicSlider

@onready var credits_ui: Panel = $UI/CreditsUI
@onready var credits_back: Button = $UI/CreditsUI/Back

@onready var ui_layer: CanvasLayer = $UI

@onready var fade_out: ColorRect = $UI/FadeOut

@onready var exit_ui: Panel = $UI/ExitUI

@onready var ground_sprite: Sprite2D = $ParallaxGround/Ground
@onready var bg_sprite: Sprite2D = $ParallaxBG/BG

@onready var icons_ui: Panel = $UI/IconsUI

@onready var play_delay: Timer = $PlayDelay

var on_ui: bool = false
## Holds the state where if the settings or icon select panel is currently on the screen
var on_screen: bool = false

var on_settings: bool = false
var on_credits: bool = false
var on_icons: bool = false
var on_exit: bool = false

var random_color: Color

# General Functions
func _ready():
	# Connecting window size changed signal
	get_viewport().connect("size_changed", _on_window_size_changed)
	_on_window_size_changed()
	
	GameProperties.playing = false
	fade_in.visible = true
	
	# Counters the camera movement
	player.on_menu = true
	
	# Generate new random color
	random_color =  Color(randf(), randf(), randf())
	
	# Set version
	version.text = "V%s" % [ProjectSettings.get_setting("application/config/version")]
	
	# Animate menu
	runtime_anim()

func _on_window_size_changed():
	if not on_settings:
		settings_ui.offset_top = 440
		settings_ui.offset_bottom = 908
	if not on_credits:
		credits_ui.offset_top = 440
		credits_ui.offset_bottom = 908
	if not on_icons:
		icons_ui.offset_left = 43
		icons_ui.offset_right = 877

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
	
	player.get_node("SkinDisplayer").change_skin(1)

# Play System
## Play System:
## Plays a fade out animation and teleports the user to the level select scene
## (Signal Function)
func on_play_pressed():
	if not on_screen:
		# Make the fade out on top of the UI elements
		fade_out.z_index = 5
		
		# Create tween for tweening the fade out visibility property
		var tween = create_tween()
		tween.tween_property(fade_out, "color:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		play_delay.start(1.0)
	
	await play_delay.timeout
	get_tree().change_scene_to_file.call_deferred("res://files/scenes/levelselect.tscn")

# Runtime Animation
## Runtime Animation:
## Moves the UI buttons to their respective positions upon runtime
## (Main Function)
func runtime_anim():
	play.offset_left = -500
	play.offset_right = -153
	
	icons.offset_left = -500
	icons.offset_right = -153
	
	exit.offset_left = -500
	exit.offset_right = -153
	
	settings.offset_top = 69
	settings.offset_bottom = 147
	credits.offset_top = 69
	credits.offset_bottom = 147
	
	logo.offset_top = -260
	logo.offset_bottom = -81
	
	var tween = create_tween()
	# Play
	tween.tween_property(play, "offset_left", 34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	tween.parallel().tween_property(play, "offset_right", 381, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	
	# Icons
	tween.parallel().tween_property(icons, "offset_left", 34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.4)
	tween.parallel().tween_property(icons, "offset_right", 381, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.4)
	
	# Exit
	tween.parallel().tween_property(exit, "offset_left", 34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.5)
	tween.parallel().tween_property(exit, "offset_right", 381, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.5)
	
	# Settings
	tween.parallel().tween_property(settings, "offset_top", -92, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	tween.parallel().tween_property(settings, "offset_bottom", -14, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	
	# Credits
	tween.parallel().tween_property(credits, "offset_top", -92, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.4)
	tween.parallel().tween_property(credits, "offset_bottom", -14, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.4)
	
	# Logo
	tween.parallel().tween_property(logo, "offset_top", 11.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)
	tween.parallel().tween_property(logo, "offset_bottom", 190, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)

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

# Exit System
## Exit System:
## Displays a confirmation UI
## (Signal Function)
func on_exit_pressed():
	if not on_screen:
		on_screen = true
		exit_ui.visible = true

## Exit System:
## Hides the confirmation UI (No Option)
## (Signal Function)
func on_exit_no_pressed():
	on_screen = false
	exit_ui.visible = false

## Exit System:
## Closes the game (Yes Option)
## (Signal Function)
func on_exit_yes_pressed():
	get_tree().quit()

# End of System

# Settings System
## Settings System:
## Shows the settings UI upon button press
## (Signal Function)
func show_settings():
	settings.release_focus()
	
	if not on_screen:
		on_screen = true
		on_settings = true
	else:
		return
	
	settings_ui.visible = true
	settings_ui.position.y = get_window().size.y + 100
	
	var tween = create_tween()
	tween.tween_property(settings_ui, "offset_top", -192, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(settings_ui, "offset_bottom", 276, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Update sliders value
	sound_slider.value = GameProperties.user_settings["settings"]["sound_vol"] * 100
	music_slider.value = GameProperties.user_settings["settings"]["music_vol"] * 100

## Settings System:
## Changes the sound volume settings
## (Signal Function)
func on_sound_slider_dragged(value):
	GameProperties.user_settings["settings"]["sound_vol"] = value / 100.0
	GameProperties.save_user_data()

## Settings System:
## Changes the music volume settings
## (Signal Function)
func on_music_slider_dragged(value):
	GameProperties.user_settings["settings"]["music_vol"] = value / 100.0
	GameProperties.save_user_data()

## Settings System:
## Moves the settings UI back to offscreen
## (Signal Function)
func on_settings_back():
	settings_back.release_focus()
	on_screen = false
	on_settings = false
	
	# Release focus to all sliders
	sound_slider.release_focus()
	music_slider.release_focus()
	
	var tween = create_tween()
	tween.tween_property(settings_ui, "offset_top", 440, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(settings_ui, "offset_bottom", 908, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# End of System

# Credits System
## Credits System:
## Shows the credits UI
## (Signal Function)
func show_credits():
	credits.release_focus()
	credits_ui.modulate.a = 1.0
	
	if not on_screen:
		on_screen = true
		on_credits = true
	else:
		return
	
	credits_ui.visible = true
	credits_ui.position.y = get_window().size.y + 100
	
	var tween = create_tween()
	tween.tween_property(credits_ui, "offset_top", -192, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(credits_ui, "offset_bottom", 276, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func on_credits_back():
	credits_back.release_focus()
	on_screen = false
	on_credits = false
	
	var tween = create_tween()
	tween.tween_property(credits_ui, "offset_top", 440, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(credits_ui, "offset_bottom", 908, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# End of System

# SIcons Select
## Icon Select:
## Shows the icon select UI
## (Signal Function)
func on_icon_pressed():
	if not on_screen:
		on_screen = true
	else:
		return 
	
	on_icons = true
	icons_ui.position.x = get_window().size.x + 100
	
	var tween = create_tween()
	tween.tween_property(icons_ui, "offset_left", -868, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(icons_ui, "offset_right", -34, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

## Icon Select:
## Hides the icon select UI
## (Signal Function)
func on_icon_back_pressed():
	on_screen = false
	on_icons = false
	
	var tween = create_tween()
	tween.tween_property(icons_ui, "offset_left", 43, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(icons_ui, "offset_right", 867, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
# End
