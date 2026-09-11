extends RigidBody2D

@export var _area2d: Area2D
@export var _level: GameLevel
@export var _eject_point: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_area2d.connect(ClimbGameManager.ON_COLLISION_SIGNAL, on_body_entered_area2d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_body_entered_area2d(body) -> void:
	if body is PlayerMovement:
		var powerup: Powerup = _level.spawn_powerup(_eject_point.global_position)
		# This came from GameLevel
		var powerup_impulse:Vector2
		powerup_impulse.x = 400
		powerup_impulse.y = 500
		powerup.initial_impulse = Vector2.UP * powerup_impulse.y + Vector2.RIGHT * (powerup_impulse.x * randf() - (powerup_impulse.x/2))
			
