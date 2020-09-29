class_name DialogMenuContainer
extends NinePatchRect

signal close_pressed

export var voice_disappear_timeout := 0.1

var _first_hover := true
var _voice_disappear_time := 0.0

onready var _voice: TextureRect = find_node('Voice')
onready var _voice_icon: TextureRect = find_node('VoiceIcon')
onready var _defaults := {
	voice_icon = _voice_icon.rect_position
}

func _ready() -> void:
	_voice.self_modulate.a = 0.0

	$DialogMenu.connect('option_hovered', self, '_show_voice_icon')
	$DialogMenu.connect('option_left', self, '_hide_voice_icon')
	$Close.connect('pressed', self, '_emit_close')


func _process(delta):
	if _voice_disappear_time > 0.0:
		_voice_disappear_time -= delta
		if _voice_disappear_time < 0.0:
			_hide_voice()


func _show_voice_icon(btn: DialogOption) -> void:
	_voice_disappear_time = 0.0
	if not _first_hover:
		yield($Tween, 'tween_all_completed')
		if _voice_disappear_time < 0.0: return
	_voice.self_modulate.a = 1.0
	_first_hover = false
	_voice_icon.texture = load(
		'res://assets/images/gui/voice_%s.png' % btn.voice
	)
	_voice_icon.rect_position.y = _defaults.voice_icon.y
	_voice_icon.self_modulate.a = 1.0

func _hide_voice_icon() -> void:
	_voice_disappear_time = voice_disappear_timeout
	$Tween.interpolate_property(
		_voice_icon, 'rect_position:y',
		_defaults.voice_icon.y, _defaults.voice_icon.y - 6,
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	$Tween.interpolate_property(
		_voice_icon, 'self_modulate:a',
		1.0, 0.0,
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	
	$Tween.start()

func _hide_voice() -> void:
	_voice.self_modulate.a = 0.0
	_voice_icon.rect_position.y = _defaults.voice_icon.y
	_voice_icon.self_modulate.a = 0.0
	_first_hover = true


func _emit_close() -> void:
	emit_signal('close_pressed')
