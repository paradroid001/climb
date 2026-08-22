extends Control
class_name MenuPlayerConfig

@export var _player_label: Label
@export var _player_panel: Panel
@export var _player_sprite: AnimatedSprite2D
@export var _button_ready: Button
@export var _button_cancel: Button

signal on_player_ready(player_id: int, character_index: int)

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
	_player_ready = false
	_player_panel.grab_focus.call_deferred()
	_player_label.text = "Player "
	# Set the frames to the first entry
	set_sprite_display(_current_character_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _connected_player_controls == null:
		return
		
	if !_player_ready and _connected_player_controls.direction.is_released():
		increment_character(1)
	
	if (! _button_ready.button_pressed and
		  _connected_player_controls.jump.is_held() and 
		  _connected_player_controls.jump.time_held() > 2.0):
			print("Player " + str(_player_id) + " is ready!")
			_player_ready = true
			_button_ready.button_pressed = true
			on_player_ready.emit(_player_id, _current_character_index)

# The menu is telling us that someone chose a character
# Our map will be refreshed, we need to check if we are 'on' that char.
# only if we aren't ready.
func update_characters() -> void:
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
		
		
		
			
