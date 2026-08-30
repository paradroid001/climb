extends CharacterBody2D
class_name PlayerMovement

signal collided_with_player(me: PlayerMovement, them: PlayerMovement)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var _player_id: int = 0
@export var _player_character: ClimbCharacter
@export var _player_controls: ClimbControl

@export var _player_sprite: AnimatedSprite2D
@export var _player_area2D: Area2D
@export var _name_label: Label
@export var _eject_point: Node2D

#did the player release jump this frame?
var _jump_input: float
var _powerups_collected: int
var _jumps_max: int
var _jumps_used: int

func _ready() -> void:
	add_to_group("player")
	_powerups_collected = 0
	_jumps_max = 1
	_player_area2D.connect("body_entered", _on_body_entered)
	
func _process(delta: float) -> void:
	if _player_controls == null:
		return
	if _player_controls.jump.just_pressed():
		_jump_input += delta
		print("just pressed")
	#elif _player_controls.jump.is_pressed():
	#	print("Held: " + str(_player_controls.jump.time_held()))

# This is called by the game scene when the player is added
func init_player(player_id: int) -> void:
	_player_id = player_id
	#unless statically set:
	if _player_controls == null:
		# Get the controls this player is using
		_player_controls = ClimbGameManager._players[_player_id]._control
	if _player_character == null:
		# Set the character this player has selected
		_player_character = ClimbGameManager._players[_player_id]._character
		
	_player_sprite.sprite_frames = _player_character.animation_frames
	# Set name
	_name_label.text = str(_player_id) + ": " + _player_character.character_name

func get_num_powerups() -> int:
	return _powerups_collected

func get_eject_point() -> Vector2:
	return _eject_point.global_position

# Use this to gain or lose powerups
func gain_powerups(num: int) -> int:
	_powerups_collected += num
	if _powerups_collected < 0:
		_powerups_collected = 0
	_jumps_max = _powerups_collected + 1
	return _powerups_collected

func reset_jumps() -> void:
	_jumps_used = 0

func _can_jump() -> bool:
	if _jumps_used < _jumps_max:
		return true
	return false

func _jump() -> bool:
	if _jumps_used < _jumps_max:
		velocity.y = JUMP_VELOCITY
		_jumps_used +=1
		return true
	return false

func _on_body_entered(body) -> void:
	print("Entered: " + body.name)
	if body is PlayerMovement and body != self:
		collided_with_player.emit(self, body)
	

func _physics_process(delta: float) -> void:
	if _player_controls != null:
		var jump = _player_controls.jump.get_state()
		match jump:
			GameAction.InputState.NOT_PRESSED:
				_name_label.text = "NOT_PRESSED"
			GameAction.InputState.PRESSED:
				_name_label.text = "PRESSED"
			GameAction.InputState.HELD:
				_name_label.text = "HELD"
			GameAction.InputState.RELEASED:
				_name_label.text = "RELEASED"
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		reset_jumps()

	# Handle jump.
	if _jump_input > 0:
		print("jumping")
		_jump()
	_jump_input = 0
			
	if _player_controls != null:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction :float  = _player_controls.direction.vector2().x  #Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()
