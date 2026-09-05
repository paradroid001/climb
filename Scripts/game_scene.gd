extends Node

const player_camera_scene = preload("res://Scenes/Actor/player_camera.tscn")
const player_scene = preload("res://Scenes/Actor/player.tscn")

@export var screen_container: HBoxContainer
@export var _cam_zoom: Vector2 = Vector2.ONE
@export var _game_start_ui: GameStartUI
@export var _game_win_ui: GameWinUI

var _level_to_load: String = "res://Scenes/Level/level_1.tscn"
var _first_subviewport : SubViewport = null
# This is the actual loaded game level
var _level_node: GameLevel = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If we resize the game, resize the viewports
	get_tree().root.size_changed.connect(_update_viewport_size)
	var added_players: int = 0
	
	for player in ClimbGameManager._players:
		if player != null:
			print("Adding player id " + str(player._player_index) + " as player " + str(added_players) )
			# The player dectection system will already have set
			# player id, controls, and character
			# The PlayerMovement script will set the sprite frames
			# based on the selected character
			var new_player: PlayerMovement = player_scene.instantiate()
			var player_camera: PlayerCamera = null
			new_player.init_player(player._player_index)
			if added_players == 0:
				player_camera = _add_new_player_viewport(new_player)
				_load_level() #loads level into first viewport, sets _level_node
			else:
				player_camera = _add_new_player_viewport(new_player)
				
			new_player.global_position = _level_node.get_random_spawn_point(SpawnPoint.PLAYER_SPAWN_GROUP).assign()
			_level_node.add_child(new_player)
			new_player.set_level(_level_node)
			player_camera.set_target(new_player)
				
			added_players += 1
	_update_viewport_size()
	# at this point all players are added.
	# show the start game UI, and start the countdown.
	_game_start_ui.connect("game_start_countdown_timeout", _on_game_start_countdown_finished)
	_game_start_ui.countdown(3)
	_level_node.connect("level_change_state", _on_level_change_state)
	_level_node.set_state(GameLevel.LevelState.SETTING_UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_game_start_countdown_finished() -> void:
	print("Game Start!")
	_level_node.set_state(GameLevel.LevelState.PLAYING)

# We get this when the level signals there is a winner.
func _on_level_change_state(state: GameLevel.LevelState, old_state: GameLevel.LevelState) -> void:
	if state == GameLevel.LevelState.WIN:
		print("Game recieved signal that level entered WIN state")
		_game_win_ui.enable(true)
	

func _add_new_player_viewport(player_node: CharacterBody2D) -> PlayerCamera:
	var new_svc: SubViewportContainer = SubViewportContainer.new()
	var new_sv: SubViewport = SubViewport.new()
	# pixelly
	new_svc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# not 3d
	new_sv.disable_3d = true
	var new_cam: PlayerCamera = player_camera_scene.instantiate() as PlayerCamera
	new_cam.zoom = _cam_zoom
	new_cam.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	screen_container.add_child(new_svc)
	new_svc.add_child(new_sv)
	new_sv.add_child(new_cam)
	
	if _first_subviewport != null:
		# for non first viewports, the player has been passed in.
		#new_cam.global_position = player_node.global_position
		new_sv.world_2d = _first_subviewport.world_2d
		
	else:
		_first_subviewport = new_sv
		#position the camera on the player
		#for the first viewport the player is in the level already
		#TODO: follow
		#var player_pos:Vector2 = _level_node.get_tree().get_nodes_in_group("player")[0].global_position
		#new_cam.global_position = player_pos
	return new_cam

func _load_level() -> void:
	#Load the level - they all need GameLevel attached to their root
	_level_node = load(_level_to_load).instantiate() as GameLevel
	#The level lives only in the first subviewport
	_first_subviewport.add_child(_level_node)
	
func _update_viewport_size() -> void:
	var num_viewports: int = screen_container.get_children().size()
	var game_size: Vector2 = get_viewport().get_visible_rect().size
	for viewport in screen_container.get_children():
		var subv: SubViewport = viewport.get_child(0) #should be the subviewport
		subv.size.x = (game_size.x / num_viewports)
		subv.size.y = game_size.y
		
				
		 
	
