extends Node

var song = AudioStreamPlayer.new()
var stream = preload("res://files/assets/music/mainmenu.mp3")

# General Functions
func _ready():
	song.stream = stream
	
	add_child(song)

func _process(delta):
	song.volume_linear = GameProperties.user_settings["settings"]["music_vol"]
	
	if not GameProperties.playing:
		if not song.playing:
			song.play()
	else:
		song.stop()
