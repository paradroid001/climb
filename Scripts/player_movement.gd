extends CharacterBody2D
class_name PlayerMovement

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var _player_id: int = 0
var _player_character: ClimbCharacter
var _player_controls: ClimbControl

@export var _player_sprite: AnimatedSprite2D
@export var _name_label: Label

func _ready() -> void:
	add_to_group("player")
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if _player_controls.jump.is_pressed() and is_on_floor():
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction :float  = _player_controls.direction.vector2().x  #Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func init_player(player_id: int) -> void:
	_player_id = player_id
	# Get the controls this player is using
	_player_controls = ClimbGameManager._players[_player_id]._control
	# Set the character this player has selected
	_player_character = ClimbGameManager._players[_player_id]._character
	_player_sprite.sprite_frames = _player_character.animation_frames
	# Set name
	_name_label.text = str(_player_id) + ": " + _player_character.character_name
