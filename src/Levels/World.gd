extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'

onready var _player: Player = $Player

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	# Establecer valores por defecto
	_player.show()
	WorldEvent.emit_signal('world_entered')
	DialogEvent.emit_signal('dialog_requested', 'DialogTest')
	PlayerEvent.connect('move_player', self, '_move_player')

func _move_player(end_pos) -> void:
	AudioEvent.emit_signal("play_requested","Player","Move")
	_player.path = $Navigation2D.get_simple_path(_player.position, end_pos)
	_player.position = _player.path[0]
	$Line2D.points = _player.path
