extends CharacterBody2D
class_name PlayerMovement

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const MAX_FLOCK_SIZE: int = 8

# Emitted whenever we collide with another player
signal collided_with_player(me: PlayerMovement, them: PlayerMovement)

const _bullet_scene = preload("res://Scenes/Actor/Bullet.tscn")
@export var _player_character: ClimbCharacter
@export var _player_controls: ClimbControl
@export var _player_sprite: AnimatedSprite2D
@export var _player_audio: AudioStreamPlayer
var _player_sfx: AudioStreamPlaybackPolyphonic

@export var _sfx: Dictionary[String, AudioStream]

# The area that players collide with
@export var _player_area2D: Area2D
@export var _name_label: Label
# The position where powerups should be ejected from the player
@export var _eject_point: Node2D
@export var _max_flock_positions: int = 100
@export var _flock_sample_rate:float = 0.01
@export var _flock_scale: float = 0.7
var _flock_spacing_timer: float
var _player_id: int = 0
#did the player start pressing jump this frame?
var _jump_input: float
var _powerups_collected: int
var _jumps_max: int
var _jumps_used: int
var _controls_enabled: bool
var _was_on_floor: bool
var _positions: Array[Vector2]
var _flock: Array[AnimatedSprite2D]
var _current_level: GameLevel

func _ready() -> void:
	add_to_group("player")
	_player_area2D.connect(ClimbGameManager.ON_COLLISION_SIGNAL, _on_body_entered)
	
	# Init Audio
	#var audio_stream = AudioStreamPolyphonic.new()
	#udio_stream.polyphony = 16
	#_player_audio.stream = audio_stream
	_player_audio.play() # start player audio, we will stream into it
	_player_sfx = _player_audio.get_stream_playback()

func _process(delta: float) -> void:
	if _player_controls == null:
		return
	# We detect "just pressed" here,
	if _controls_enabled:
		if _player_controls.jump.just_pressed():
			_jump_input += delta
			#print("just pressed")
		if _player_controls.special.just_released():
			var shoot_direction: Vector2 = _player_controls.direction.vector2()
			if shoot_direction.length() < 0.01: #basically if no input
				shoot_direction = Vector2.UP
			_shoot(shoot_direction)
	
	_flock_spacing_timer += delta
	if _flock_spacing_timer > _flock_sample_rate:
		_flock_spacing_timer = 0
		_positions.push_back(global_position)
		while _positions.size() > _max_flock_positions:
			_positions.pop_front()
	
	#wont happen for flock size 0
	for index in range(_flock.size()):
		_flock[index].global_position = _positions[index * (_max_flock_positions/_flock.size())]
	
	_name_label.text = _player_character.character_name + " (" + str(_jumps_max - _jumps_used) + ")"	
	

# This is called by the game scene when the player is added
func init_player(player_id: int) -> void:
	_player_id = player_id
	
	# Init other state
	_was_on_floor = true
	_powerups_collected = 0
	_jumps_max = 1
	#unless statically set:
	if _player_controls == null:
		# Get the controls this player is using
		_player_controls = ClimbGameManager.get_player(_player_id).get_controls()
	if _player_character == null:
		# Set the character this player has selected
		_player_character = ClimbGameManager.get_player(_player_id).get_character()

	_player_sprite.sprite_frames = _player_character.animation_frames
	# Set name
	_name_label.text = str(_player_id) + ": " + _player_character.character_name
	enable_controls(true)

func get_player_id() -> int:
	return _player_id

func set_level(level: GameLevel) -> void:
	_current_level = level

func play_sfx(name: String) -> void:
	if name in _sfx.keys():
		# sfx, offset, vol(db), pitch
		_player_sfx.play_stream(_sfx[name], 0, 0, 1.0)

# We don't actually change the _player_controls,
# because we still want to recieve inputs for UI.
# We just toggle a local variable
func enable_controls(enabled: bool) -> void:
	_controls_enabled = enabled

func get_num_powerups() -> int:
	return _powerups_collected

func get_eject_point() -> Vector2:
	return _eject_point.global_position

func _add_flock_member() -> void:
	var newguy = _player_sprite.duplicate()
	newguy.scale = Vector2.ONE * _flock_scale
	_flock.push_back(newguy)
	call_deferred("add_child", newguy)

func _remove_flock_member() -> void:
	var flock_member = _flock.pop_front()
	flock_member.queue_free()
	
# Use this to gain or lose powerups
# Returns true if the number of powerups changed
func gain_powerups(num: int) -> bool:
	var _initial_powerups_collected: int = _powerups_collected
	
	_powerups_collected += num
	if _powerups_collected < 0:
		_powerups_collected = 0
	elif _powerups_collected > MAX_FLOCK_SIZE:
		_powerups_collected = MAX_FLOCK_SIZE
	_jumps_max = _powerups_collected + 1
	
	# after all that, if they nothing happened return false
	if _initial_powerups_collected == _powerups_collected:
		return false
	
	# otherwise process the addition		
	for i in range(abs(num)):
		if num > 0:
			_add_flock_member()
			play_sfx("Powerup")
		elif _flock.size() > 0:
			_remove_flock_member()
	
	return true

func reset_jumps() -> void:
	_jumps_used = 0

func _can_jump() -> bool:
	if _jumps_used < _jumps_max:
		return true
	return false

func _jump() -> bool:
	if _jumps_used < _jumps_max:
		play_sfx("Jump")
		velocity.y = JUMP_VELOCITY
		_jumps_used += 1
		return true
	return false
	
func _shoot(direction: Vector2) -> void:
	if _current_level != null and _powerups_collected > 0:
		gain_powerups(-1)
		var bullet: Bullet = _bullet_scene.instantiate()
		bullet.init_bullet(direction, ClimbGameManager.get_player(_player_id), _current_level)
		bullet.global_position = _eject_point.global_position
		_current_level.add_child(bullet)
		play_sfx("Shoot")

func _on_body_entered(body) -> void:
	print("Entered: " + body.name)
	if body is PlayerMovement and body != self:
		collided_with_player.emit(self, body)
		play_sfx("Collide")

func _physics_process(delta: float) -> void:
	#if _player_controls != null:
		#var jump = _player_controls.jump.get_state()
		#match jump:
		#	GameAction.InputState.NOT_PRESSED:
		#		_name_label.text = "NOT_PRESSED"
		#	GameAction.InputState.PRESSED:
		#		_name_label.text = "PRESSED"
		#	GameAction.InputState.HELD:
		#		_name_label.text = "HELD"
		#	GameAction.InputState.RELEASED:
		#		_name_label.text = "RELEASED"
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		_was_on_floor = false
	else:
		reset_jumps()
		if !_was_on_floor:
			_was_on_floor = true
			play_sfx("Land")

	# Handle jump.
	if _jump_input > 0:
		#print("jumping")
		_jump()
	# Reset the jump input sampled in _process
	_jump_input = 0

	if _controls_enabled:
		# Get the input direction and handle the movement/deceleration.
		var direction: float = _player_controls.direction.vector2().x
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
