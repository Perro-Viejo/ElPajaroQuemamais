tool
extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export var world_name := 'WORLD'
export var episode := 1 setget _set_episode

var _current_clickable: Clickable = null

onready var _player: Player = $Actors/Player

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	# Establecer valores por defecto
	_player.show()
	
	# Conectarse a señales de los hijos de la mamá
	for actor in $Actors.get_children():
		var _actor: Actor = actor
		_actor.connect('moved_to_coordinate', self, '_move_actor_to_coordinate')
		_actor.connect('moved_to_reference', self, '_move_actor_to_reference')
		_actor.connect('movement_finished', self, '_actor_moved')
	
	# Conectarse a señales del universo pokémon
	WorldEvent.emit_signal('world_entered')
	PlayerEvent.connect('move_player', self, '_move_player')
	
	yield(get_tree(), 'idle_frame')
	
	match Data.get_data(Data.EPISODE):
		1:
			_setup_set(1)
			yield(get_tree().create_timer(2), 'timeout')
			DialogEvent.emit_signal('dialog_requested', 'Ep1Sc1')
		2:
			_setup_set(2)
			yield(get_tree().create_timer(2), 'timeout')
			DialogEvent.emit_signal('dialog_requested', 'Ep2Sc1')
		_:
			_setup_set(1)


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
	var room: Room = get_node('Rooms/%s' % props.room)
	move_actor(props.actor, room.get_point_position(props.point_name))


func _actor_moved(actor: Actor) -> void:
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
	if actor.is_in_dialog():
		yield(get_tree(), 'idle_frame')
		DialogEvent.emit_signal('dialog_continued')


func _setup_set(_episode: int) -> void:
	match _episode:
		1:
			$Actors/Player.position = $Rooms/RoomC.get_target_position('Clickable2')
			$Actors/AnaMaria.position = $Rooms/RoomB.get_point_position('Entrance')
			$Actors/AnaMaria.show()
			$Actors/Lupe.hide()
			$Actors/Rico.hide()
			$Cameras/HouseCamera.make_current()
		2:
			$Actors/AnaMaria.position = $Rooms/Stable.get_point_position('Entrance')
			$Actors/Lupe.position = $Rooms/Stable.get_point_position('Arrecha')
			$Actors/AnaMaria.show()
			$Actors/Lupe.show()
			$Actors/Rico.hide()
			$Cameras/StableCamera.make_current()
		_:
			for actor in $Actors.get_children():
				actor.position = 0
				actor.hide()


func _set_episode(new_val: int) -> void:
	episode = new_val
	_setup_set(new_val)
	property_list_changed_notify()
