extends Control
class_name MainMenu

var _player_count: int = 0
var _players_ready: int = 0
var _time_ready_elapsed: float = 0

#var _character_index_to_player_id: Dictionary #[int, int]
var _available_roster: Dictionary[int, bool]
var _player_configs: Array[MenuPlayerConfig]

@export var hbox: HBoxContainer
@export var player_config_prefab : PackedScene
@export var _button_start_game: ProgressButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the available roster:
	var index = 0
	for character:ClimbCharacter in ClimbGameManager.get_character_roster():
		_available_roster[index] = true #available
		index +=1
		print("Adding available character " + character.character_name)
	
	# Init the start button to a 5 second countdown with a 1 second step
	_button_start_game.init(5, 1)
	
	#Listen for players joining
	ClimbGameManager.on_player_joined.connect(new_player_join)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# detect_joy_activity: this will trigger the on_player_joiuned signal.
	ClimbGameManager.detect_new_player_input()
	if _player_count != 0 and _players_ready == _player_count:
		_time_ready_elapsed += delta
		_button_start_game.set_value(_time_ready_elapsed)		
	else:
		_time_ready_elapsed = 0
		_button_start_game.reset()
		
	# If the start button is pressed, we transition scenes.
	if _button_start_game.button_pressed:
		ClimbGameManager.load_scene("Game")
	
func new_player_join(player: ClimbPlayer) -> void:
	_player_count += 1
	var player_config: MenuPlayerConfig = player_config_prefab.instantiate()
	player_config._player_id = player._player_index
	player_config._connected_player_controls = player._control
	player_config._available_roster = _available_roster
	# Connect the signal
	player_config.on_player_ready.connect(player_is_ready)
	player_config.on_player_unready.connect(player_is_unready)
	# add to our list
	_player_configs.push_back(player_config)
	# add to the scene
	hbox.add_child(player_config)

func player_is_ready(player_id: int, character_index: int) -> void:
	# Mark character unavailable
	_available_roster[character_index] = false
	ClimbGameManager._players[player_id]._character = ClimbGameManager._characters[character_index]
	_players_ready += 1
	notify_character_availability_changed()
	
func player_is_unready(player_id: int, character_index: int) -> void:
	# Free the character up
	_available_roster[character_index] = true
	ClimbGameManager._players[player_id]._character = null
	_players_ready -= 1
	notify_character_availability_changed()
	
func notify_character_availability_changed() -> void:
	for config_child: MenuPlayerConfig in _player_configs:
		config_child.update_characters() # force all children to update
