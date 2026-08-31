extends RigidBody2D
class_name Powerup

enum PowerupState {DISABLED, ENABLED}


# The area that players collide with
@export var _collision_area: Area2D
@export var _sprite: AnimatedSprite2D
# Time from when this powerup is created to when it can be collected
# Set this in the inspector, or before the poweup enters the tree
# Set to 0 to have it be collectible immediately
@export var time_to_enable: float = 1.5
# Time between flickers when disabled
@export var flicker_time: float = 0.03
# The initial force applied for 'on create' motion.
@export var initial_impulse: Vector2

var _state: PowerupState
# Internal tracking for the flicker effect
var _modulate_timer: float

# Either pass a positive delay, or it uses the time to enable
func _ready(delay: float = -1) -> void:
	# Connect the RB2D signal straight away
	connect(ClimbGameManager.ON_COLLISION_SIGNAL, _on_rb2d_body_entered)
	disable()
	apply_impulse(initial_impulse)
	if delay < 0:
		delay = time_to_enable
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	enable()

func get_state() -> PowerupState:
	return _state

func enable() -> void:
	_collision_area.connect(ClimbGameManager.ON_COLLISION_SIGNAL, _on_area2d_body_entered)
	_sprite.modulate.a = 1.0
	_state = PowerupState.ENABLED

func disable() -> void:
	# This is to avoid disconnecting signals that aren't connected
	if _state != PowerupState.DISABLED:
		_collision_area.disconnect(ClimbGameManager.ON_COLLISION_SIGNAL, _on_area2d_body_entered)
		_state = PowerupState.DISABLED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _state == PowerupState.DISABLED:
		_modulate_timer += delta
		if _modulate_timer > flicker_time:
			_modulate_timer = 0
			if _sprite.modulate.a == 1.0:
				_sprite.modulate.a = 0.5
			else:
				_sprite.modulate.a = 1.0

# The way we have set up the collision layer,
# players should not collide. So it will
# only collide with the tilemap.
func _on_rb2d_body_entered(body):
	print("Powerup RB2D collision: " + body.name)
	enable()

func _on_area2d_body_entered(body):
	if body is PlayerMovement:
		#It should be a playermovement script
		var pm: PlayerMovement = body
		pm.gain_powerups(1)
		#delete this object
		queue_free()
	else:
		# Something else collided that wasn't a player
		#print("SOmething else collided: " + body.name)
		pass
