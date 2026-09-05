extends Node
class_name ClimbPlayer

# Which global player index are we
var _player_index:int
var _character: ClimbCharacter
var _control: ClimbControl
#var g_players: Array[ClimbPlayer] # the global player array

func _init(index: int, control: ClimbControl) -> void:
	_player_index = index
	_control = control
	add_child(_control) # make sure the control is a child, so it gets lifecycle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_controls() -> ClimbControl:
	return _control
func get_character() -> ClimbCharacter:
	return _character
func get_player_id() -> int:
	return _player_index
