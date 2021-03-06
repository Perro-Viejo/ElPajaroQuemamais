extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export var world_name := 'WORLD'
export var episode := 1 setget _set_episode
export var ignore_fade := false

var _current_clickable: Clickable = null
var _current_post_wait := 0
var _available_dialogue := {}

onready var _actors: Node2D = find_node('Actors')
onready var _rooms: Node2D = find_node('Rooms')
onready var _room_a: Room = _rooms.get_node('RoomA')
onready var _room_b: Room = _rooms.get_node('RoomB')
onready var _room_c: Room = _rooms.get_node('RoomC')
onready var _stable: Room = _rooms.get_node('Stable')
onready var _player: Player = _actors.get_node('Player')
onready var _rico: NPC = _actors.get_node('Rico')
onready var _lupe: NPC = _actors.get_node('Lupe')
onready var _anamar: NPC = _actors.get_node('AnaMaria')
onready var _mamais: NPC = _actors.get_node('MamaIs')

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	TranslationServer.set_locale('es')

	# Establecer valores por defecto
	_player.show()
	_setup_set(Data.get_data(Data.EPISODE))
	Data.endings[1] = 0
	Data.endings[2] = 0
	Data.endings[3] = 0
	
	# Conectarse a señales de los hijos de la mamá
	for actor in _actors.get_children():
		var _actor: Actor = actor
		_actor.connect('moved_to_coordinate', self, '_move_actor_to_coordinate')
		_actor.connect('moved_to_reference', self, '_move_actor_to_reference')
		_actor.connect('movement_finished', self, '_actor_moved')
	
	# Conectarse a señales del universo pokémon
	PlayerEvent.connect('move_player', self, '_move_player')
	GuiEvent.connect('curtain_hidden', self, '_start_episode')
	DialogEvent.connect('dialog_finished', self, '_end_episode')
	GuiEvent.connect('curtain_shown', self, '_load_next_episode')
	DialogEvent.connect('scene_setup_requested', self, '_setup_for_dialog')

	WorldEvent.emit_signal('world_entered')
	WorldEvent.emit_signal('episode_started')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func move_actor(actor: Actor, target: Vector2) -> void:
	actor.path = $Navigation2D.get_simple_path(actor.position, target)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _move_player(clickable: Clickable) -> void:
	SoundManager.play_se('sfx_player_move')
	_player.path = $Navigation2D.get_simple_path(
		_player.position,
		clickable.get_room_relative_position()
	)
	_player.position = _player.path[0]
	$Line2D.points = _player.path
	_current_clickable = clickable


func _move_actor_to_coordinate(props: Dictionary) -> void:
	move_actor(props.actor, props.target)


func _move_actor_to_reference(props: Dictionary) -> void:
	var room: Room = _rooms.get_node(props.room)
	(props.actor as Actor).current_room = room
	_current_post_wait = props.post_wait

	move_actor(props.actor, room.get_point_position(props.point_name))


func _actor_moved(actor: Actor) -> void:
	var actor_in_dialog := actor.is_in_dialog()
	if _current_post_wait > 0:
		yield(get_tree().create_timer(_current_post_wait), 'timeout')
	if actor.is_current_player:
		$Line2D.points = PoolVector2Array()
		if _current_clickable:
			if not SectionEvent.in_dialog and _current_clickable.trigger_dialog:
				if _available_dialogue.has(_current_clickable.trigger_dialog):
					if not _available_dialogue[_current_clickable.trigger_dialog].played:
						DialogEvent.emit_signal(
							'dialog_requested', _available_dialogue[_current_clickable.trigger_dialog].dialog_key
						)
						_available_dialogue[_current_clickable.trigger_dialog].played = true
				
			if _current_clickable.look_to != Clickable.DIR.NONE:
				yield(get_tree(), 'idle_frame')
				actor.look_to(_current_clickable.look_to)
	if actor_in_dialog:
		yield(get_tree(), 'idle_frame')
		DialogEvent.emit_signal('dialog_continued')


func _setup_set(_episode: int) -> void:
	# Establecer configuración por defecto para todas las escenas
	for actor in _actors.get_children():
		actor.position = Vector2.ZERO
		if not actor.is_current_player:
			actor.hide()
	$Cameras/HouseCamera.make_current()
	SoundManager.stop('bg_hacienda')
	SoundManager.stop('bg_stable')

	# TODO	Que esto quede definido fuera de aquí en algún script que sirva como
	# 		diccionario o algo así.
	match _episode:
		1:
			_available_dialogue = {
				Palito = {
					dialog_key = 'Ep1Sc2',
					played = false,
				},
				Desk = {
					dialog_key = 'Ep1Sc3',
					played = false,
				},
			}
			_player.position = _room_c.get_target_position('BookcasePlatform')
			_player.look_to(_room_c.get_target('BookcasePlatform').look_to)
			_anamar.position = _room_b.get_point_position('Entrance')
			_anamar.show()

			SoundManager.play_bgs('bg_hacienda')
		2:
			_player.position = _stable.get_target_position('Clickable')
			_player.look_to(_stable.get_target('Clickable').look_to)
			_anamar.position = _stable.get_point_position('Outside')
			_lupe.position = _stable.get_point_position('Arrecha')
			_anamar.show()
			_lupe.show()

			$Cameras/StableCamera.make_current()
			SoundManager.set_volume_db(-12 ,'bg_hacienda')
			SoundManager.play_bgs('bg_stable')
		3:
			_player.position = _room_a.get_target_position('Clickable')
			_player.look_to(_room_a.get_target('Clickable').look_to)
			_mamais.position = _room_a.get_point_position('BedB')
			_rico.position = _room_a.get_point_position('BedA')
			_mamais.show()
			_rico.show()

			SoundManager.play_bgs('bg_hacienda')
		4:
			_available_dialogue = {
				Library = {
					dialog_key = 'Ep4Sc2',
					played = false,
				},
			}
			_player.position = _room_b.get_target_position('Clickable')
			_player.look_to(_room_b.get_target('Clickable').look_to)
			_anamar.position = _room_b.get_point_position('Desk')
			_anamar.show()
			_lupe.position = _room_b.get_point_position('Entrance')
			_lupe.show()
			
			SoundManager.play_bgs('bg_hacienda')
		5:
			_player.position = _room_c.get_target_position('LiquorPlatform')
			_player.look_to(_room_c.get_target('LiquorPlatform').look_to)
			_mamais.position = _room_c.get_point_position('Liquor1')
			_mamais.show()
			_rico.position = _room_c.get_point_position('Liquor2')
			_rico.show()
			_anamar.position = _room_c.get_point_position('Sofa1')
			_anamar.show()
			_lupe.position = _room_c.get_point_position('Corner1')
			_lupe.show()
			
			SoundManager.play_bgs('bg_hacienda')
		_:
			$Cameras/HouseCamera.make_current()


func _set_episode(new_val: int) -> void:
	episode = new_val
	_setup_set(new_val)
	property_list_changed_notify()


func _start_episode() -> void:
	yield(get_tree().create_timer(1), 'timeout')
	var dialog_name: String = 'Ep%dSc1' % Data.get_data(Data.EPISODE)
	DialogEvent.emit_signal('dialog_requested', dialog_name)


func _end_episode(dialog_name) -> void:
	match Data.get_data(Data.EPISODE):
		1:
			if dialog_name == 'Ep1Sc4':
				WorldEvent.emit_signal('episode_ended')
		2:
			if dialog_name == 'Ep2Sc1':
				WorldEvent.emit_signal('episode_ended')
		3: 
			if dialog_name == 'Ep3Sc1':
				WorldEvent.emit_signal('episode_ended')
		4: 
			if dialog_name == 'Ep4Sc3':
				WorldEvent.emit_signal('episode_ended')
		5: 
			if dialog_name == 'Ep5Sc1':
				WorldEvent.emit_signal('episode_ended')


func _load_next_episode() -> void:
	# Sumar 1 al episodio actual pa' cargar el siguiente
	Data.data_sumi(Data.EPISODE, 1)
	yield(get_tree().create_timer(1.5), 'timeout')

	if Data.get_data(Data.EPISODE) > 5:
		SoundManager.stop('bg_hacienda')
		if Data.endings[1] == 2:
			HudEvent.emit_signal('ending_requested', 1)
		elif Data.endings[2] == 2:
			HudEvent.emit_signal('ending_requested', 2)
		else:
			HudEvent.emit_signal('ending_requested', 3)
	else:
		if Data.get_data(Data.EPISODE) == 3:
			HudEvent.emit_signal('curtain_toggle_requested')
			SoundManager.stop('bg_stable')
			SoundManager.stop('bg_hacienda')
			yield($Cinematic.play_commercial(), 'completed')
			HudEvent.emit_signal('curtain_toggle_requested')
			$Cinematic.hide()
		_setup_set(Data.get_data(Data.EPISODE))
		WorldEvent.emit_signal('episode_started')


func _setup_for_dialog(rules: Array) -> void:
	for cfg in rules:
		var actor: Actor = _actors.get_node(cfg.actor)
		if cfg.has('point'):
			actor.position = _rooms.get_node(cfg.room).get_point_position(cfg.point)
		elif cfg.has('target'):
			actor.position = _rooms.get_node(cfg.room).get_target_position(cfg.target)
		actor.show()
		if cfg.has('hidden'):
			actor.hide()
	DialogEvent.emit_signal('dialog_continued')
