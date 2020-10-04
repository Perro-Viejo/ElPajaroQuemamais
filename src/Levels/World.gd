extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export var world_name := 'WORLD'
export var episode := 1 setget _set_episode

var _current_clickable: Clickable = null
var _current_post_wait := 0

onready var _actors: Node2D = find_node('Actors')
onready var _rooms: Node2D = find_node('Rooms')
onready var _player: Player = _actors.get_node('Player')

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
	AudioEvent.emit_signal("play_requested","Player","Move")
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
				DialogEvent.emit_signal(
					'dialog_requested', _current_clickable.trigger_dialog
				)
			if _current_clickable.look_to != Clickable.DIR.NONE:
				yield(get_tree(), 'idle_frame')
				actor.look_to(_current_clickable.look_to)
	if actor_in_dialog:
		yield(get_tree(), 'idle_frame')
		DialogEvent.emit_signal('dialog_continued')


func _setup_set(_episode: int) -> void:
	# TODO	Que esto quede definido fuera de aquí en algún script que sirva como
	# 		diccionario o algo así.
	match _episode:
		1:
			_actors.get_node('Player').position = _rooms.get_node('RoomC').get_target_position('Clickable2')
			_actors.get_node('Player').look_to(_rooms.get_node('RoomC').get_target('Clickable2').look_to)
			_actors.get_node('AnaMaria').position = _rooms.get_node('RoomB').get_point_position('Entrance')
			_actors.get_node('AnaMaria').show()
			_actors.get_node('Lupe').hide()
			_actors.get_node('Rico').hide()
			$Cameras/HouseCamera.make_current()
			AudioEvent.emit_signal('play_requested', 'BG', 'Hacienda')
		2:
			_actors.get_node('Player').position = _rooms.get_node('Stable').get_target_position('Clickable')
			_actors.get_node('Player').look_to(_rooms.get_node('Stable').get_target('Clickable').look_to)
			_actors.get_node('AnaMaria').position = _rooms.get_node('Stable').get_point_position('Outside')
			_actors.get_node('Lupe').position = _rooms.get_node('Stable').get_point_position('Arrecha')
			_actors.get_node('AnaMaria').show()
			_actors.get_node('Lupe').show()
			_actors.get_node('Rico').hide()
			$Cameras/StableCamera.make_current()
			AudioEvent.emit_signal('play_requested', 'BG', 'Establo')
		3:
			$Cinematic.hide()
			$Cameras/HouseCamera.make_current()
			for actor in _actors.get_children():
				actor.position = Vector2.ZERO
		_:
			for actor in _actors.get_children():
				actor.position = Vector2.ZERO
				if not actor.is_current_player:
					actor.hide()
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
				yield($Cinematic.play_commercial(), 'completed')
				$Cameras/StableCamera.make_current()
				WorldEvent.emit_signal('episode_ended')


func _load_next_episode() -> void:
	# Sumar 1 al episodio actual pa' cargar el siguiente
	Data.data_sumi(Data.EPISODE, 1)
	yield(get_tree().create_timer(1.5), 'timeout')
	_setup_set(Data.get_data(Data.EPISODE))
	WorldEvent.emit_signal('episode_started')


func _setup_for_dialog(rules: Array) -> void:
	for cfg in rules:
		var actor: Actor = _actors.get_node(cfg.actor)
		actor.position = _rooms.get_node(cfg.room).get_point_position(cfg.point)
		actor.show()
		if cfg.has('hidden'):
			actor.hide()
	DialogEvent.emit_signal('dialog_continued')
	
