class_name Dialog
extends Control
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export var use_click_to_progress := false

var _forced_update := false
var _current_character: Node2D = null
# Cosas del Godot Dialog System ---- {
var _story_reader_class := load(
	'res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd'
)
var _stories_es = load('res://assets/stories/baked_tests.tres')
var _did := 0
var _nid := 0
var _final_nid := 0
var _options_nid := 0
var _in_dialog_with_options := false
var _wait := false
var _selected_slot := -1
var _current_options := ''
# } ----
var _is_listening_click := true
var _current_emotion := ''
var _sub_shown = false
var _played = false

onready var _story_reader: EXP_StoryReader = _story_reader_class.new()
onready var _dialog_mnu_cnt: NinePatchRect = find_node('DialogMenuContainer')
onready var _dialog_mnu: DialogMenu = find_node('DialogMenu')
onready var _autofill: Autofill = find_node('Autofill')
onready var _character_frame: CharacterFrame = find_node('CharacterFrame')
onready var _subs: Label = $Subtitles
onready var _dialog_btn: TextureButton = $DialogButton
onready var _defaults := {
	dialog_btn = _dialog_btn.rect_position
}

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	# Configurar el Data manager para que vaya guardando información de los
	# diálogos (eventualmente esto se guardará en un archivo así como se guardan
	# las opciones de configuración)
	Data.set_data(Data.DIALOGS, {})

	_dialog_mnu.hide()
	_hide_subs()

	match TranslationServer.get_locale():
		_:
			_story_reader.read(_stories_es)

	# Conectarse a eventos de los retoños y de sí mismo
	$Tween.connect('tween_step', self, '_play_subs_sfx')
	_autofill.connect('fill_done', self, '_autofill_completed')
	if use_click_to_progress:
		self.connect('gui_input', self,'_on_gui_input')
	# Esta es de prueba:
	_dialog_mnu.connect('test_option_clicked', self, '_hide_dialog_menu')
	_dialog_btn.connect('pressed', self, '_show_dialog_menu')
	_dialog_mnu_cnt.connect('close_pressed', self, '_hide_dialog_menu')

	# Conectarse a eventos de la vida real
	DialogEvent.connect('dialog_requested', self, '_play_dialog')
	DialogEvent.connect('dialog_continued', self, '_continue_dialog')
	DialogEvent.connect('character_spoke', self, '_on_character_spoke')
	DialogEvent.connect('dialog_option_clicked', self, '_option_clicked')
	HudEvent.connect('continue_requested', self, '_enable_click_listening')
	HudEvent.connect('hud_accept_pressed', _autofill, 'stop')
	
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Eventos propios y de hijos ░░░░
func _autofill_completed() -> void:
	if _current_character:
		HudEvent.emit_signal('talking_bubble_requested')

		var character_copy = _current_character
		_current_character = null

		if character_copy.has_method('spoke'):
			character_copy.spoke()
		character_copy = null

	if _wait:
		# TODO: Puede haber una mejor manera de hacer esto, cosa que la alternación
		# del control del PC suceda en un único lugar dentro del código de esta
		# clase
		PlayerEvent.emit_signal('control_toggled')
		DialogEvent.emit_signal('dialog_paused')
		return

	if not _in_dialog_with_options or not _dialog_mnu.visible:
		_continue_dialog(_selected_slot)


func _on_gui_input(event: InputEvent) -> void:
	var mouse_event: = event as InputEventMouseButton
	if _is_listening_click and mouse_event \
		and mouse_event.button_index == BUTTON_LEFT \
		and mouse_event.pressed:
			_autofill.stop()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Eventos globales ░░░░
func _play_dialog(dialog_name: String) -> void:
	_did = _story_reader.get_did_via_record_name(dialog_name)
	_nid = _story_reader.get_nid_via_exact_text(_did, 'start')
	_final_nid = _story_reader.get_nid_via_exact_text(_did, 'end')
	
	self.mouse_filter = 0 # Escuchar los clics

	if _story_reader.get_nid_via_exact_text(_did, 'return') > 0:
		_in_dialog_with_options = true
		PlayerEvent.emit_signal('control_toggled')
	
	if _dialog_btn.rect_position.x == _defaults.dialog_btn.x:
		_toggle_dialog_btn(false)

	_continue_dialog()


func _continue_dialog(slot := 0) -> void:
	# Para la forma de diálogo anterior al plugin ------------------------------
	if _did == 0:
		_finish_dialog()
		return
	# --------------------------------------------------------------------------

	if _autofill.is_visible(): return
	_hide_subs()

	if _selected_slot < 0 and _nid == _options_nid:
		# Para mostrar el menú de opciones de diálogo al final de la línea
		# que este posiblemente dispare
		_dialog_mnu.show_options()
		return

	_next_dialog_line(max(0, slot))

	if _nid == _final_nid:
		_finish_dialog()
	else:
		_play_dialog_line()


func _next_dialog_line(slot := 0) -> void:
	_nid = _story_reader.get_nid_from_slot(_did, _nid, slot)

func _play_dialog_line() -> void:
	var line_txt := _story_reader.get_text(_did, _nid)

	if _nid == _final_nid:
		_finish_dialog()
		return

	if _in_dialog_with_options:
		# Verificar si el texto del nodo es la palabra clave para volver al menú
		# de opciones activo
		_selected_slot = -1
		if line_txt == 'return':
			_nid = _options_nid
			_dialog_mnu.show_options()
			return

	var line_dic: Dictionary = JSON.parse(line_txt).result

	# ----[ el actor ]----------------------------------------------------------
	# El actor por defecto será el player
	var actor := 'player'
	if line_dic.has('actor'):
		actor = (line_dic.actor as String).replace(' ', '_')

	# ----[ la línea ]----------------------------------------------------------
	var line := ''
	if line_dic.has('line'):
		var code := ('dlg_%d_%d_%s' % [_did, _nid, actor]).to_upper()
		line = tr(code)
		# Cambiar temporalmente el idioma para sacar el subtítulo
		TranslationServer.set_locale('en')
		_subs.set_text(tr(code))
		TranslationServer.set_locale('es')

	# ----[ la emoción ]----------------------------------------------------------
	_current_emotion = ''
	if line_dic.has('emotion'):
		_current_emotion = line_dic.emotion as String

	_wait = false
	if line_dic.has('wait'):
		_wait = true

	# Por defecto se asume que el diálogo continuará con base en una acción del
	# jugador
	var time_to_disappear := -1.0
	if line_dic.has('time'):
		time_to_disappear = line_dic.time as float

	# ▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮ ON START (event) ▮▮▮▮
	if line_dic.has('on_start'):
		var on_start_dict = line_dic.on_start
		if on_start_dict.params.size() == 1:
			get_node("/root/"+on_start_dict.type).emit_signal(on_start_dict.event, on_start_dict.params[0])
		else:
			get_node("/root/"+on_start_dict.type).emit_signal(on_start_dict.event)

	# ▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮ OPCIONES ▮▮▮▮
	if line_dic.has('options'):
		_options_nid = _nid
		_selected_slot = -1

		var options_state := {}
		var dialogs_state: Dictionary = Data.get_data(Data.DIALOGS)
		if dialogs_state.has(_get_options_id()):
			options_state = dialogs_state[_get_options_id()]

		var id := 0
		for opt in line_dic.options:
			opt.id = id
			opt.tr_code = 'dlg_%d_%d_%s_opt_%d' % [_did, _nid, actor, id]

			if options_state:
				opt.show = options_state[opt.id]

			if not opt.has('actor'):
				opt.actor = 'player'
			if not opt.has('time'):
				opt.time = 3
			if not opt.has('emotion'):
				opt.emotion = ''

			id += 1

		_dialog_mnu.create_options(line_dic.options)

	# ▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮ APAGAR OPCIONES ▮▮▮▮
	if line_dic.has('off') or line_dic.has('on'):
		# En este nodo se apagarán opciones
		var cfg := {}

		if line_dic.has('off'):
			for opt in line_dic.off:
				cfg[String(opt)] = false

		if line_dic.has('on'):
			for opt in line_dic.on:
				cfg[String(opt)] = true

		_dialog_mnu.update_options(cfg)

	# Lo último que se hace es disparar la línea de diálogo
	
	if line:
		DialogEvent.emit_signal(
			'line_triggered',
			actor.to_lower(),
			line,
			time_to_disappear,
			_current_emotion
		)


func _on_character_spoke(
		character: Node2D = null,
		message :String = '',
		time_to_disappear := 0.0
	):
	if _autofill.typing:
		_autofill.stop()
		if not is_inside_tree(): return
		yield(get_tree(), 'idle_frame')

	# Definir el color del texto
	var text_color: Color = Color('#222323')
	if character and character.get('dialog_color'):
		text_color = character.dialog_color
	_autofill.set_text_color(text_color)

	if _current_character \
		and _current_character.is_inside_tree() \
		and _current_character.has_method('spoke'):
		# Notificar al personaje que ya terminó de hablar
		_current_character.spoke()

	if message != '':
		_current_character = character

		yield(
			_character_frame.set_character(_current_character, _current_emotion),
			'completed'
		)

		_autofill.set_text(message)
		_autofill.set_disappear_time(time_to_disappear)

		_autofill.show()
		_toggle_subs()
	else:
		_current_character = null
		_current_emotion = ''
		_autofill.finish_and_hide()


func _option_clicked(opt: Dictionary) -> void:
	_selected_slot = opt.id

	if opt.has('say') and opt.say:
		DialogEvent.emit_signal(
			'line_triggered',
			(opt.actor as String).to_lower(),
			opt.line as String,
			opt.time,
			opt.emotion as String
		)
	else:
		_continue_dialog(_selected_slot)

func _enable_click_listening() -> void:
	_is_listening_click = true
	_character_frame.show_continue()


func _finish_dialog() -> void:
	if not _final_nid == 0:
		# Para los diálogos hechos con el plugin
		if _in_dialog_with_options:
			var options_id := _get_options_id()
			var dialogs_state: Dictionary = Data.get_data(Data.DIALOGS)
			var options_state := {}

			if dialogs_state.has(options_id):
				options_state = dialogs_state[options_id]

			for opt in _dialog_mnu.current_options:
				options_state[opt.id] = opt.show
			
			dialogs_state[options_id] = options_state
			Data.set_data(Data.DIALOGS, dialogs_state)

		_did = 0
		_nid = 0
		_final_nid = 0

		if _in_dialog_with_options:
			_options_nid = 0
			_in_dialog_with_options = false
			_dialog_mnu.remove_options()
			PlayerEvent.emit_signal('control_toggled')

	# Para cualquier diálogo
	_current_emotion = ''
	_current_character = null
	_subs.set_text('[ gibberish in spanish ]')
	DialogEvent.emit_signal('dialog_finished')
	_character_frame.dialog_finished()
	_toggle_subs(false)
	self.mouse_filter = 2 # Ignorar los clics
	
	# Mostrar el botón que permite a Quemamais decir algo
	_toggle_dialog_btn()


func _get_options_id() -> String:
	return '%s-%s' % [_did, _options_nid]

func _toggle_subs(show := true) -> void:
	_sub_shown = show
	_played = false
	$Tween.interpolate_property(
		_subs, 'rect_position:y',
		OS.window_size.y if show else 900.0,
		900.0 if show else OS.window_size.y,
		0.3 if show else 0.1,
		Tween.TRANS_BOUNCE if show else Tween.TRANS_SINE,
		Tween.EASE_OUT if show else Tween.EASE_IN
	)
	$Tween.start()


func _hide_subs() -> void:
	_subs.rect_position.y = OS.window_size.y

func _play_subs_sfx(obj: Object, key: NodePath, elapsed: float, val: Object):
	if _sub_shown and not _played and (obj as Control).rect_position.y < 905:
		_played = true
		AudioEvent.emit_signal('play_requested', 'UI', 'sub')


func _show_dialog_menu() -> void:
	_dialog_btn.disabled = true

	_dialog_mnu.show()
	AudioEvent.emit_signal('play_requested', 'UI', 'whoosh')
	$AnimationPlayer.play('show_dialog_menu')
	yield($AnimationPlayer, 'animation_finished')

	_dialog_btn.hide()


func _hide_dialog_menu(opt: Button = null) -> void:
	AudioEvent.emit_signal('play_requested', 'UI', 'whoosh_2')
	$AnimationPlayer.play('show_dialog_menu', -1.0, -1.5, true)
	if opt:
		DialogEvent.emit_signal(
			'line_triggered',
			'quemamais',
			opt.text,
			-1.0,
			''
		)
	else:
		_dialog_btn.show()
		_dialog_btn.disabled = false
	self.mouse_filter = 0 # Escuchar los clics


func _toggle_dialog_btn(show := true) -> void:
	_dialog_btn.show()
	$Tween.interpolate_property(
		_dialog_btn, 'rect_position:x',
		OS.window_size.x + 16 if show else _defaults.dialog_btn.x,
		_defaults.dialog_btn.x if show else OS.window_size.x + 16,
		0.3 if show else 0.1,
		Tween.TRANS_BOUNCE if show else Tween.TRANS_SINE,
		Tween.EASE_OUT if show else Tween.EASE_IN
	)
	$Tween.start()
	_dialog_btn.disabled = !show
