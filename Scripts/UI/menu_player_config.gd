extends Control
class_name MenuPlayerConfig

# Timers for holding buttons for ready/unready
@export var _time_to_ready: int = 2.0
@export var _time_to_unready: int = 1.0

@export var _player_label: Label
@export var _player_panel: Panel
@export var _player_sprite: AnimatedSprite2D
@export var _button_ready: ProgressButton
@export var _button_cancel: ProgressButton

signal on_player_ready(player_id: int, character_index: int)
signal on_player_unready(player_id: int, character_index: int)

var _current_character_index:int  = 0
var _player_ready: bool
# We are passed the following items after instantiation
var _player_id: int
var _connected_player_controls: ClimbControl = null
var _available_roster: Dictionary[int, bool]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# focus the player panel so navigation has a start point.
	# TODO: We aren't going to use this in the end, focus is
	# too hard with multiple controllers in the mix.
	
	#_player_panel.grab_focus.call_deferred()
	_player_label.text = "Player "
	_player_ready = false
	
	_button_ready.init(_time_to_ready)
	_button_cancel.init(_time_to_unready)
	
	if _connected_player_controls.device_type == IGameInput.ControllerType.GAMEPAD:
		_button_ready.text = "(B) Ready"
		_button_cancel.text = "(A) Cancel"
	elif _connected_player_controls.device_type == IGameInput.ControllerType.KEYBOARD:
		_button_ready.text = "(Space) Ready"
		_button_cancel.text = "(Ctrl) Cancel"
	update_characters() #sync with the available roster
	# Set the frames to the first entry
	set_sprite_display(_current_character_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _connected_player_controls == null:
		return
	# Selecting character (left and right)	
	if !_player_ready and _connected_player_controls.direction.just_released():
		increment_character(1)
	
	# Detecting if player is trying to ready
	if ! _player_ready:
		if _connected_player_controls.jump.is_pressed():
			_button_ready.set_value(_connected_player_controls.jump.time_held())
		if _connected_player_controls.jump.just_released():
			_button_ready.reset()
			
		if _button_ready.button_pressed:
			print("Player " + str(_player_id) + " is ready!")
			_player_ready = true
			on_player_ready.emit(_player_id, _current_character_index)
	else: #if the player is ready
		if _connected_player_controls.special.is_pressed():
			_button_cancel.set_value(_connected_player_controls.special.time_held())
		if _connected_player_controls.special.just_released():
			_button_cancel.reset()
			
		if _button_cancel.button_pressed:
			_button_ready.reset()
			_button_cancel.reset()
			_player_ready = false
			print("Player " + str(_player_id) + " unreadied")
			on_player_unready.emit(_player_id, _current_character_index)
		
# The menu is telling us that someone chose a character
# Our map will be refreshed, we need to check if we are 'on' that char.
# only if we aren't ready.
func update_characters() -> void:
	# Don't bother if we are already ready.
	if _player_ready:
		return
		
	if !_available_roster[_current_character_index]:
		increment_character(1)
		#TODO: optionally interrupt readying.

# set the display sprite, assume frames index is valid
func set_sprite_display(frames_index: int) -> void:
	var candidate_character: ClimbCharacter = ClimbGameManager.get_character_roster()[frames_index]
	_player_sprite.sprite_frames = candidate_character.animation_frames
	_player_sprite.animation = "default"
	_player_sprite.play("default")
	
# TODO: this function could infinite loop if
# more players join than there are available chars.
#
func increment_character(amount: int) -> void:
	_current_character_index += amount
	var num_characters: int = ClimbGameManager.get_character_roster().size()
	# keep in bounds
	if _current_character_index >= num_characters:
		_current_character_index = 0
	if _current_character_index < 0:
		_current_character_index = num_characters-1
	
	# dont select if invalid.
	if !_available_roster[_current_character_index]:
		increment_character(amount)
	else:
		set_sprite_display(_current_character_index)
		
		
		
			
