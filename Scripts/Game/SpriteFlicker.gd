extends Object
class_name SpriteFlicker

@export var flicker_time: float = 0.03
@export var flicker_min_alpha: float = 0.5

var _flicker_timer: float
var enabled: bool = false
# to track when we get turned off, so we can make sure the sprite is visible
var _was_enabled: bool = false

func on() -> void:
	if !enabled:
		enabled = true
		_flicker_timer = 0
func off() -> void:
	enabled = false
	
func update(sprite: Node2D, delta: float) -> void:
	if enabled:
		_was_enabled = true
		_flicker_timer += delta
		if _flicker_timer > flicker_time:
			_flicker_timer = 0
			if sprite.modulate.a == 1.0:
				sprite.modulate.a = flicker_min_alpha
			else:
				sprite.modulate.a = 1.0
	else:
		if _was_enabled:
			sprite.modulate.a = 1.0
			_was_enabled = false
