extends Node2D

# Reference scene nodes
@onready var ground_sprite: Sprite2D = $ParallaxGround/Ground
@onready var bg_sprite: Sprite2D = $ParallaxBG/BG
@onready var camera: Camera2D = $Camera

@onready var progress: ProgressBar = $UI/ProgressBar
@onready var send_delay: Timer = $SendDelay
@onready var transition_delay: Timer = $TransitionDelay

@onready var fade_out: ColorRect = $UI/FadeOut
@onready var fade_in: ColorRect = $UI/FadeIn

var random_color: Color
var load_progress: Array

# General Functions
func _ready():
	GameProperties.playing = true # Prevents the main menu song from playing
	
	# Generate new random color
	random_color =  Color(randf(), randf(), randf())
	
	# Start loading the target scene in a separate thread
	ResourceLoader.load_threaded_request("res://files/scenes/gamescene.tscn")
	
	# Fade in
	fade_in.color.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_in, "color:a", 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _process(delta):
	# Moving camera along with parallax
	camera.position.x += GameProperties.camera_speed_menu * delta
	
	# Change BG and Ground color overtime
	ground_sprite.modulate = ground_sprite.modulate.lerp(random_color, 0.001)
	bg_sprite.modulate = bg_sprite.modulate.lerp(random_color, 0.001)
	
	# If the player is close to the randomly assigned color, generate a new color again
	if ground_sprite.modulate.is_equal_approx(random_color):
		# Generate new color
		random_color =  Color(randf(), randf(), randf())
	
	var status = ResourceLoader.load_threaded_get_status("res://files/scenes/gamescene.tscn", load_progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress.value = load_progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			progress.value = load_progress[0] * 100.0
			
			var packed_scene = ResourceLoader.load_threaded_get("res://files/scenes/gamescene.tscn")
			if packed_scene:
				send_delay.start(4.0)
				transition_delay.start(2.0)
				
				var transition: bool = false
				await transition_delay.timeout # Waits for the timer timeout signal
				# Prevents the tween from running again
				if not transition:
					transition = true
					
					var tween = create_tween()
					tween.tween_property(fade_out, "color:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
				
				await send_delay.timeout # Waits for the timer timeout signal
				get_tree().change_scene_to_packed(packed_scene)
