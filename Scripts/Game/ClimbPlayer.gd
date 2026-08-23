extends Node
class_name ClimbPlayer

enum ClimbPlayerState {NOT_PLAYING, SPAWNING, PLAYING, DYING }

# Which global player index are we
var _player_index:int
var _sprite_frames: SpriteFrames
var _control: ClimbControl
var _state: ClimbPlayerState
#var g_players: Array[ClimbPlayer] # the global player array

func _init(index: int, control: ClimbControl) -> void:
	_player_index = index
	_control = control
	add_child(_control) # make sure the control is a child, so it gets lifecycle
	_state = ClimbPlayerState.NOT_PLAYING
	# TODO need to go get sprite frames.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_sprite_frames(frames: SpriteFrames) -> void:
	_sprite_frames = frames
