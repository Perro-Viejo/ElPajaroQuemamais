class_name Actor
extends KinematicBody2D

signal died()
signal moved_to_coordinate(cfg)
signal moved_to_reference(cfg)
signal movement_finished(me)
signal movement_started(me)

export var dialog_color: Color
export var speed := 300
export var dialog_name := ''
# El spritesheet con las emociones del personaje para que se muestren en el
# cuadro de diálogo
export var expressions: Texture
export var expressions_map := {
	angry = -1,
	excited = -1,
	sad = -1,
	thinking = -1,
	worried = -1,
	normal = -1,
	happy = -1
}
export var expressions_offset := Vector2.ZERO
export var is_current_player := false
export var voice: Texture = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒variables públicas ▒▒▒▒
var path := PoolVector2Array() setget _set_path
var velocity := Vector2.ZERO

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _in_dialog := false setget set_in_dialog, is_in_dialog
var _is_moving := false setget _set_is_moving, is_moving
var _temporary_speed := 0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables onready ▒▒▒▒
#onready var inventory = $Inventory
onready var state_machine = $StateMachine
onready var _lower_name := name.to_lower()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	if dialog_name:
		_lower_name = dialog_name.to_lower().replace(' ', '_')
	
	Data.set_data(dialog_name, {
		voice = voice
	})

	DialogEvent.connect('line_triggered', self, '_should_speak')
	DialogEvent.connect('moved_to_coordinate', self, '_move_to_coordinate')
	DialogEvent.connect('moved_to_reference', self, '_move_to_reference')

func _physics_process(delta):
	var direction = Vector2(0,0)

	if path.size() > 0:
		var _speed := speed
		if _temporary_speed > 0:
			_speed = _temporary_speed
		
		var next_position = path[0]
		var distance_to_next_point = position.distance_to(next_position)
		
		if(abs(position.x - next_position.x) <= 1 \
			and abs(position.y - next_position.y) <= 1):
			path.remove(0)
			
		if(distance_to_next_point != 0):
			next_position = position.linear_interpolate(
				next_position, (_speed*delta)/distance_to_next_point
			)

		direction = next_position - position;
		direction.normalized()
		
		move_and_slide(direction * _speed * delta)
	elif _is_moving:
		self._is_moving = false

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
# Called when the node enters the scene tree for the first time.
func speak(text := '', time_to_disappear := 0):
	$StateMachine.transition_to_key('Talk')
	DialogEvent.emit_signal('character_spoke', self, text, time_to_disappear)


func spoke():
	$StateMachine.transition_to_key('Idle')
	if _in_dialog:
		_in_dialog = false
		DialogEvent.emit_signal('dialog_continued')


func look_to(dir: int) -> void:
	match dir:
		Clickable.DIR.LEFT:
			rotation_degrees = 0
			scale.x = 1.0
		Clickable.DIR.UP:
			rotation_degrees = 90
		Clickable.DIR.RIGHT:
			rotation_degrees = 0
			scale.x = -1.0
		Clickable.DIR.DOWN:
			rotation_degrees = -90


func set_in_dialog(new_val: bool) -> void:
	_in_dialog = new_val


func is_in_dialog() -> bool:
	return _in_dialog


func is_moving() -> bool:
	return _is_moving
# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
# Este método se llama cuando se asigna un nuevo valor a la propiedad 'path' desde
# una clase externa (p.e. $Player.path = lo_que_sea).
func _set_path(new_path: PoolVector2Array) -> void:
	path = new_path
	self._is_moving = true


func _set_is_moving(new_state: bool) -> void:
	_is_moving = new_state
	if _is_moving:
		emit_signal('movement_started', self)
	else:
		emit_signal('movement_finished', self)
		_in_dialog = false
		_temporary_speed = 0


func _its_me(target_name := '') -> bool:
	var mario := false
	if is_current_player and target_name.to_lower() == 'player':
		mario = true
	elif _lower_name == target_name.to_lower():
		mario = true
	return mario


func _should_speak(character_name, text, time, emotion) -> void:
	if _its_me(character_name):
		_in_dialog = true
		speak(text, time)
		AudioEvent.emit_signal('dx_requested' , character_name, emotion)


# Hace que el actor se mueva a una coordenada dentro de la escena:
# 	props: { 
# 		actor: String,
# 		target_position: Vector2,
# 		final_direction: Vector2,
# 		speed: float,
# 		is_relative: bool,
# 	}
func _move_to_coordinate(props: Dictionary):
	if props.has('speed'):
		_temporary_speed = props.speed
	if _its_me(props.actor):
		_in_dialog = true
		var target: Vector2 = props.target_position
		
		if props.has('is_relative'):
			target += self.position
		
		emit_signal('moved_to_coordinate', {
			actor = self,
			target = target
		})


# Hace que el actor se mueva a un punto (Position2D) dentro de una habitación
# del mundo (Node2D).
# 	props: { 
# 		actor: String,
# 		room: String,
# 		reference: String,
# 		final_direction: Vector2,
# 		speed: float
# 	}
func _move_to_reference(props: Dictionary):
	if props.has('speed'):
		_temporary_speed = props.speed
	if _its_me(props.actor):
		_in_dialog = true
		emit_signal('moved_to_reference', {
			actor = self,
			room = props.room,
			point_name = props.reference
		})
