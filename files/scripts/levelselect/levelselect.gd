extends Node2D

@onready var camera: Camera2D = $Camera
@onready var fade_in: ColorRect = $UI/FadeIn

# General Functions
func _ready():
	fade_in.visible = true

func _process(delta):
	# Moving camera along with parallax
	camera.position.x += GameProperties.camera_speed_menu * delta
	
	# Fade in
	if fade_in != null:
		fade_in.color.a = lerp(fade_in.color.a, 0.0, 0.1)
		
		if fade_in.color.a <= 0.001:
			fade_in.queue_free()
