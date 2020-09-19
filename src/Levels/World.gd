extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'

onready var _player: Player = $Player

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	# Establecer valores por defecto
	_player.show()

	_player.path = $Navigation2D.get_simple_path($StartPoint.position, $EndPoint.position)
	_player.position = _player.path[0]
	$Line2D.points = _player.path
	WorldEvent.emit_signal('world_entered')
