extends Node2D

# Reference scene nodes
@onready var disclaimer: Panel = $Disclaimer/Disclaimer
@onready var guide: Label = $Disclaimer/GuideText
@onready var tip: Label = $Disclaimer/Tip
@onready var presents: Label = $Disclaimer/Presents

var continued: bool = false

# General Function
func _ready():
	GameProperties.playing = true # Prevents the main menu song from playinh
	
	tip.modulate.a = 0.0
	presents.modulate.a = 0.0

func _process(_delta):
	# Continue
	if Input.is_anything_pressed():
		disclaimer.visible = false
		guide.visible  = false
		
		if not continued:
			continued = true
			
			var tween = create_tween()
			tween.tween_property(tip, "modulate:a", 1.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(1.0)
			tween.parallel().tween_property(tip, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(4.0)
			
			tween.parallel().tween_property(presents, "modulate:a", 1.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(5.0)
			tween.parallel().tween_property(presents, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(8.0)
			
			await tween.finished
			get_tree().change_scene_to_file("res://files/scenes/mainmenu.tscn")
