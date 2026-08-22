extends Node
#class_name ClimbGame

# This is the global game state.
# Which players are connected, which controls they are using, etc
var _players: Array[ClimbPlayer]
var _gamepad_info: Dictionary
var _device_to_player_index: Dictionary # map of device ids to player ids
@export var max_players: int = 8
@export var character_animations: Array[SpriteFrames]

#Signals
signal on_player_joined(player: ClimbPlayer)
signal on_player_leave(player: ClimbPlayer)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.joy_connection_changed.connect(detect_gamepads)
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# resets the game - clears all player assignments
func reset() -> void:
	print("ClimbGame Resetting")
	_gamepad_info.clear()
	_device_to_player_index.clear()	
	# Fill players with null
	for  id in range( max_players ):
		_players.push_back(null)
	detect_gamepads(0, true)

# Detect the gamepads connected.
func detect_gamepads(device: int, connected: bool) -> void:
	var joy_ids = Input.get_connected_joypads()
	for id in joy_ids:
		_gamepad_info[id] = Input.get_joy_info(id);
	for id in _gamepad_info.keys():
		print("Joy " + str(id))
		for key in _gamepad_info[id]:
			print(str(key) + ": " + str(_gamepad_info[id][key]))
			
# Create a new player if there's any input from a
# source not currently assigned to any player.
func detect_new_player_input() -> void:
	#Check gamepads:
	for id in _gamepad_info.keys():
		# only check if a player isn't already using this.
		if not id in _device_to_player_index.keys():
			if Input.is_joy_button_pressed(id, JOY_BUTTON_A) or Input.is_joy_button_pressed(id, JOY_BUTTON_B):
				#create a new climb control
				var control: ClimbControl = ClimbControl.new(id, ClimbControl.ControllerType.GAMEPAD) #assign_next_player_to_device(id)
				var new_player_id:int = player_join(control)
				if (new_player_id != -1):
					_device_to_player_index[id] = new_player_id

# A player joins, they get back an int which is
# their player index.
# can't join? returns -1
# emits the on_player_joined signal
func player_join(control: ClimbControl) -> int:
	#find first free null
	var player_id = _players.find(null)
	if player_id != -1:
		print("Creating new player")
		var player: ClimbPlayer = ClimbPlayer.new(player_id, control)
		_players[player_id] = player
		add_child(player)
		on_player_joined.emit(_players[player_id])
	return player_id
	return -1
	
# A player leaves.
func player_leave(index: int) -> void:
	pass
