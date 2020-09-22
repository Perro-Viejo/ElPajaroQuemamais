extends Button

export(String, 'none', 'bounce', 'move') var focus_animation = 'bounce'
export var animation_time := 0.3

var _defaults := {
	pos = self.rect_position
}

func _ready() -> void:
	self.rect_pivot_offset = Vector2(self.rect_size.x / 2, self.rect_size.y / 2)
	if focus_animation != 'none':
		self.connect('focus_entered', self, '_%s' % focus_animation)
		self.connect('mouse_entered', self, '_%s' % focus_animation)


func _bounce() -> void:
	$Tween.interpolate_property(
		self, 'rect_scale',
		Vector2.DOWN, Vector2.ONE,
		animation_time, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	$Tween.start()

func _move() -> void:
	$Tween.interpolate_property(
		self, 'rect_position:x',
		_defaults.pos.x + 32.0, _defaults.pos.x,
		animation_time, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	$Tween.start()
