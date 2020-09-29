extends Node2D


export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'

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


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func move_actor(actor: Actor, target: Vector2) -> void:
	actor.path = $Navigation2D.get_simple_path(actor.position, target)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _move_player(end_pos) -> void:
	AudioEvent.emit_signal("play_requested","Player","Move")
	_player.path = $Navigation2D.get_simple_path(_player.position, end_pos)
	_player.position = _player.path[0]
	$Line2D.points = _player.path


func _move_actor_to_coordinate(props: Dictionary) -> void:
	move_actor(props.actor, props.target)


func _move_actor_to_reference(props: Dictionary) -> void:
	var path := NodePath('%s/%s' % [props.room, props.point_name])
	var _target := (get_node(path) as Position2D).position
	move_actor(props.actor, _target)


func _actor_moved(actor: Actor) -> void:
	if actor.is_current_player:
		DialogEvent.emit_signal('dialog_requested', 'DialogTest')
	if actor.is_in_dialog():
		DialogEvent.emit_signal('dialog_continued')
