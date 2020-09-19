extends RichTextLabel

signal fill_done

export var animation_time := 0.01
export var character_speed := 2
export var animate_on_set_text := true
export var typing := true
export var disappear_wait := 3.0

var _current_disappear: = 0.0
var _chars: = []
var _count: = 0
var _text: String
var _forced_update := false
var _is_disappearing := false
var _time_to_dissapear := 0.0
var _test_texts := [
	'¿Pero y si un día le dijera lo mucho que me importa y que ese culo me pone loco de sólo verlo moverse debajo de la puerta?',
	'Hola pedazo de mierda!',
	'Pero...',
	'¡Neh! mejor me la jalo.'
]

onready var default_position = get_position()
onready var default_size = get_size()

func _ready():
	hide()

	if _time_to_dissapear == 0.0:
		_current_disappear = -1.0

	connect('gui_input', self,'_on_gui_input')
	$Timer.set_wait_time(animation_time)
	$Timer.connect('timeout', self, '_write_character')
	
	yield(get_tree().create_timer(1), 'timeout')
	set_text(_test_texts.pop_front())


func _process(delta: float) -> void:
#	rect_position.y = default_position.y
	if _forced_update:
		_forced_update = false

	if _is_disappearing:
		_time_to_dissapear -= delta
		if _time_to_dissapear < 0:
			_hide_and_emit()


func start_animation():
	if not is_inside_tree(): return
	if has_node('Timer'): $Timer.start()
	show()
	typing = true


func set_text(text):
	set_defaults()

	if text != '':
		_text = text
		AudioEvent.emit_signal('play_requested', 'UI', 'Dialogue')
		if animate_on_set_text:
			start_animation()
		else:
			.set_text(text)
	else:
		_text = ''
		_count = 0
		_current_disappear = 0.0
		_is_disappearing = false
		_time_to_dissapear = 0.0

		hide()


func set_defaults():
	self.text = ''
	rect_size = default_size
	_is_disappearing = false
	_time_to_dissapear = 0.0

	$Timer.stop()


func stop(auto_complete: bool = true) -> void:
	# Ignorar el skip si el texto ya está en su estado final
	if not visible: return

	if text == _text:
		_hide_and_emit()
		return

	if auto_complete:
		text = _text
		_forced_update = true

	_finish()
	_disappear()


func set_disappear_time(time := 0.0) -> void:
	_current_disappear = time


func set_text_color(color: Color) -> void:
	add_color_override("font_color", color)


func finish_and_hide() -> void:
	_finish()
	_hide()


func _write_character():
	if text.length() < _text.length():
		add_text(_text[_count])
		_count += 1
	else:
		# El texto ya tiene todos los caracteres
		_finish()
		_disappear()


# Detiene el temporizador y resetea el contador de caracteres escritos a cero
# pues el texto ya se está mostrando completo.
func _finish() -> void:
	_count = 0
	$Timer.stop()

	if typing:
		typing = false


func _disappear(forced_wait := 0.0) -> void:
	if _current_disappear > 0:
		_time_to_dissapear = _current_disappear
	elif _current_disappear == 0.0:
		_time_to_dissapear = disappear_wait
	else:
		# El texto no desaparecerá sólo, sino que se espera una señal que lo
		# haga desaparecer
		HudEvent.emit_signal('continue_requested')
		return

	_is_disappearing = true


func _hide() -> void:
	set_text('')


func _hide_and_emit() -> void:
	if visible and not typing:
		_hide()
		emit_signal('fill_done')


func _on_gui_input(event: InputEvent) -> void:
	var mouse_event: = event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == BUTTON_LEFT \
		and mouse_event.pressed:
			if not _test_texts.empty():
				clear()
				set_size(default_size)
				set_position(default_position)
				set_text(_test_texts.pop_front())
			else:
				set_text('')
