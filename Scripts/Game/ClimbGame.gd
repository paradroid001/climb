extends Node
# not using class name because this is an autoload script, I want
# to be able to call it something else.
#class_name ClimbGame

enum ClimbGameState {STARTING, LOADING, PLAYING}


# This is the global game state.
# Which players are connected, which controls they are using, etc
var _game_state: ClimbGameState
var _settings: ClimbSettings
var _players: Array[ClimbPlayer]
var _characters: Array[ClimbCharacter]
var _gamepad_info: Dictionary
# Convenience: is a player using a certain device?
var _device_to_player_index: Dictionary # map of device ids to player ids

# Scene loading variables
var _loading_screen: PackedScene
var _scene_path_to_load: String
var _load_scenes_with_threads: bool = true
var _load_progress_value: Array[float] #this will only ever hold one value
var _loaded_scene: PackedScene = null

#Signals
signal on_player_joined(player: ClimbPlayer)
signal on_player_leave(player: ClimbPlayer)
#Scene loading
signal load_scene_progress_changed(progress: float)
signal load_scene_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_game_state = ClimbGameState.STARTING
	_settings = load("res://Resources/GameSettings.tres") as ClimbSettings
	_loading_screen = load(_settings.scene_paths["LoadingScreen"])
	_characters = _settings.characters # the available characters
	Input.joy_connection_changed.connect(detect_gamepads)
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _game_state == ClimbGameState.LOADING:
		var load_status = ResourceLoader.load_threaded_get_status(_scene_path_to_load, _load_progress_value)
		load_scene_progress_changed.emit(_load_progress_value[0])
		match load_status:
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				print("Scene Load: Invalid resource")
				# Go back to playing state, no load has happened
				_game_state == ClimbGameState.PLAYING
			ResourceLoader.THREAD_LOAD_FAILED:
				print("Scene Load: failed")
				# Go back to playing state, no load has happened
				_game_state == ClimbGameState.PLAYING
			ResourceLoader.THREAD_LOAD_LOADED:
				print("Scene Load: finished!")
				_loaded_scene = ResourceLoader.load_threaded_get(_scene_path_to_load)
				# Change to this scene
				get_tree().change_scene_to_packed(_loaded_scene)
				_game_state = ClimbGameState.PLAYING
				load_scene_finished.emit()
	
func load_scene(scene_name: String) -> bool:
	if _game_state == ClimbGameState.LOADING:
		print("Can't load a scene while an existing load is happening")
		return false
	var scene_path = _settings.scene_paths.get(scene_name)
	if scene_path == null:
		print("Scene path for " + scene_name + " did not exist in settings")
		return false
	
	_game_state = ClimbGameState.LOADING
	_scene_path_to_load = scene_path

	var new_loading_screen: LoadingScreen = _loading_screen.instantiate()
	load_scene_progress_changed.connect(new_loading_screen._on_progress_changed)
	load_scene_finished.connect(new_loading_screen._on_load_finished)
	add_child(new_loading_screen)
	
	# wait for the loading screen to signal that it is ready
	await new_loading_screen.loading_screen_ready
	
	var loadstate = ResourceLoader.load_threaded_request(_scene_path_to_load, "", _load_scenes_with_threads)
	if loadstate != OK:
		print("Error " + str(loadstate) + " trying to load the scene " + _scene_path_to_load)
		return false
	
	return true
	
# resets the game - clears all player assignments
func reset() -> void:
	print("ClimbGame Resetting")
	_gamepad_info.clear()
	_device_to_player_index.clear()	
	# Fill players with null
	for  id in range( _settings.MAX_PLAYERS ):
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
	# KB allow one player
	if Input.is_key_pressed(KEY_SPACE):
		var id = 99
		if not id in _device_to_player_index.keys():
			var control: ClimbControl = ClimbControl.new(id, IGameInput.ControllerType.KEYBOARD)
			var new_player_id:int = player_join(control)
			# Add to the device to player map
			if new_player_id != -1:
				_device_to_player_index[id] = new_player_id
	#Check gamepads:
	for id in _gamepad_info.keys():
		# only check if a player isn't already using this.
		if not id in _device_to_player_index.keys():
			if Input.is_joy_button_pressed(id, JOY_BUTTON_A) or Input.is_joy_button_pressed(id, JOY_BUTTON_B):
				#create a new climb control
				var control: ClimbControl = ClimbControl.new(id, IGameInput.ControllerType.GAMEPAD) #assign_next_player_to_device(id)
				var new_player_id:int = player_join(control)
				# Add to the device to player map
				if new_player_id != -1:
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

# A player leaves.
func player_leave(index: int) -> void:
	pass
	
func get_character_roster() -> Array[ClimbCharacter]:
	return _characters
