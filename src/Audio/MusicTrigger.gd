extends Area2D

export (String) var music_cue

var is_playing = false

func _ready():
	connect('body_entered', self, '_on_area_entered')

func _process(delta):
	if is_playing:
		if not SoundManager.is_playing(music_cue):
			monitoring = false
			is_playing = false

func _on_area_entered(other):
	SoundManager.play_me(music_cue)
	is_playing = true
