extends Control
class_name MenuPlayerConfig

var connected_player_controls: ClimbControl = null

@export var _player_label: Label
@export var _player_panel: Panel
@export var _player_sprite: AnimatedSprite2D
@export var _button_ready: Button
@export var _button_cancel: Button
@export var _character_frames: Array[SpriteFrames] = [null, null]

var _current_character_frames:int  = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# focus the player panel so navigation has a start point.
	_player_panel.grab_focus.call_deferred()
	_player_label.text = "Player "
	# Set the frames to the first entry
	set_sprite_display(_current_character_frames)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if connected_player_controls == null:
		return
	elif connected_player_controls.direction.is_released():
		increment_character(-1)
	
	if (! _button_ready.button_pressed and
		  connected_player_controls.jump.is_held() and 
		  connected_player_controls.jump.time_held() > 2.0):
			print("Player is ready!")
			_button_ready.button_pressed = true
			
	#if device_id != -1:
		#if Input.is_joy_button_pressed(device_id, JOY_BUTTON_A):
			#pass
		#if Input.is_joy_button_pressed(device_id, JOY_BUTTON_B):
			#pass
		##var h: float = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
		#if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_LEFT):
			#print("Joy " + str(device_id) + "DPAD Left")
			#increment_character(-1)
		#if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_RIGHT):
			#print("Joy " + str(device_id) + "DPAD Right")
			#increment_character(1)
		#if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_UP):
			#print("Joy " + str(device_id) + "DPAD Up")
		#if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_DOWN):
			#print("Joy " + str(device_id) + "DPAD Down")
# set the display sprite, assume frames index is valid
func set_sprite_display(frames_index: int) -> void:
	_player_sprite.sprite_frames = _character_frames[frames_index]
	_player_sprite.animation = "default"
	_player_sprite.play("default")
	
func increment_character(amount: int) -> void:
	_current_character_frames += amount
	if _current_character_frames >= _character_frames.size():
		_current_character_frames = 0
	if _current_character_frames < 0:
		_current_character_frames = _character_frames.size()-1
	set_sprite_display(_current_character_frames)
		
		
		
			
