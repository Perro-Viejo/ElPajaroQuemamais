tool

extends Resource

class_name MyAudioData

export var volume: float = -3

export var clip: AudioStream

export var semitones: float setget set_semitones

export var pitch: float 

export var randomize_pitch: bool setget set_randomize

export var pitch_range: Vector2

var twelfthRootOfTwo: = pow(2, (1.0 / 12))

func set_semitones(in_semitones: float):
	semitones = in_semitones
	pitch = pow(twelfthRootOfTwo, in_semitones)
	property_list_changed_notify()

func set_randomize(in_random):
	if in_random:
		var new_semitones = round(rand_range(pitch_range.x, pitch_range.y))
		set_semitones(new_semitones)
