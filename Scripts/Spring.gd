extends RigidBody2D

enum SpringState {READY, RESETTING, SPRUNG}

@export var spring_velocity: float = 600
@export var reset_time: float = 1.0
@export var _area2d: Area2D
@export var _sprite: AnimatedSprite2D
@export var _audio: AudioStreamPlayer

var _state: SpringState
var _reset_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_area2d.connect(ClimbGameManager.ON_COLLISION_SIGNAL, _on_area2d_body_entered)
	_state = SpringState.READY
	_reset_timer = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _state == SpringState.SPRUNG:
		_reset_timer += delta
		if _reset_timer >= reset_time:
			set_state(SpringState.RESETTING)
	elif _state == SpringState.RESETTING:
		_reset_timer += delta
		if _reset_timer >= reset_time:
			set_state(SpringState.READY)
	
func spring(player: PlayerMovement) -> void:
	print("Test spring..." + player.name)
	if set_state(SpringState.SPRUNG) == SpringState.SPRUNG:
		player.velocity = Vector2.UP * spring_velocity

func set_state(new_state: SpringState) -> SpringState:
	match new_state:
		SpringState.READY:
			if _state == SpringState.RESETTING:
				_sprite.play("default")
				_state = new_state
				print("Have reset to READY")
		SpringState.RESETTING:
			if _state == SpringState.SPRUNG:
				_sprite.play("reset")
				_reset_timer = 0
				_state = new_state
		SpringState.SPRUNG:
			if _state == SpringState.READY:
				_sprite.play("spring")
				_audio.play(0)
				_reset_timer = 0
				_state = new_state
			else:
				print("Couldn't spring, state was: " + str(_state))
	return _state

func _on_area2d_body_entered(body) -> void:
	if body is PlayerMovement:
		spring(body)
			
