extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
signal scene_is_loaded

enum {IDLE, TRANSITION_IN, TRANSITION_OUT}

export var current_episode := 1

onready var current_scene = null
onready var current_scene_instance = $Levels.get_child($Levels.get_child_count() - 1)

export var is_mouse_hidden = false

var next_scene
var transition_state:int = IDLE

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	Data.set_data(Data.CURRENT_SCENE, 'MainMenu')
	Data.set_data(Data.FORCE_FOCUS, is_mouse_hidden)
	# mateo: 	Estaría chimba que esto se guarde en disco y se pueda cargar al
	# 			iniciar el juego
	Data.set_data(Data.EPISODE, current_episode)
	Data.set_data(Data.CURRENT_TUTORIAL, 0)

	GuiEvent.connect("Options",	self, "on_options")
	GuiEvent.connect("Exit",		self, "on_exit")
	GuiEvent.connect("ChangeScene",self, "on_change_scene")
	GuiEvent.connect("Restart", 	self, "restart_scene")
	#Background loader
	SceneLoader.connect("scene_loaded", self, "on_scene_loaded")

	GUIManager.gui_collect_focusgroup()

	if is_mouse_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		$MouseBlocker/Control.mouse_filter = 2

func on_options(options) -> void:
	GUIManager.gui_collect_focusgroup()

func on_change_scene(scene):
	if transition_state != IDLE:
		return

	if Settings.HTML5:
		next_scene = load(scene)
	else:
		SceneLoader.load_scene(scene, {scene="Level"})

	if not current_scene_instance.ignore_fade:
		transition_state = TRANSITION_OUT

		$TransitionLayer/TransitionTween.interpolate_property(
			$TransitionLayer, "percent",
			0.0, 1.0,
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0
		)
		$TransitionLayer/TransitionTween.start()
	else:
		transition_state = IDLE
		yield(self, "scene_is_loaded")
		change_scene()

func on_exit()->void:
	if transition_state != IDLE:
		return
	get_tree().quit()

func on_scene_loaded(loaded)->void:
	next_scene = loaded.resource
	emit_signal("scene_is_loaded")	#Scene fade signal in case it loads longer than fade out

func change_scene()->void: #handle actual scene change
	if next_scene == null:
		return
	yield(get_tree(), "idle_frame") #continue on idle frame
	current_scene_instance.free()
	current_scene = next_scene
	next_scene = null
	current_scene_instance = current_scene.instance()
	$Levels.add_child(current_scene_instance)
	Data.set_data(Data.CURRENT_SCENE, current_scene_instance.name)

func restart_scene():
	if transition_state != IDLE:
		return
	yield(get_tree(), "idle_frame")
	current_scene_instance.free()
	current_scene_instance = current_scene.instance()
	$Levels.add_child(current_scene_instance)

func _on_TransitionTween_tween_completed(object, key)->void:
	match transition_state:
		IDLE:
			pass
		TRANSITION_OUT:
			if next_scene == null:
				print("Not loaded, please wait!")
				yield(self, "scene_is_loaded")
			change_scene()
			transition_state = TRANSITION_IN
			$TransitionLayer/TransitionTween.interpolate_property(
				$TransitionLayer, "percent",
				1.0, 0.0,
				0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0
			)
			$TransitionLayer/TransitionTween.start()
		TRANSITION_IN:
			transition_state = IDLE

func play_song(mx: AudioStream) -> void:
	$Music.stream = mx
	$Music.play()
