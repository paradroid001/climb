extends Node
class_name GameScene

class PlayerViewport:
	var player_id: int
	var sub_viewport: SubViewport
	var player_camera: PlayerCamera
	var parallax_layer: Parallax2D 


const player_camera_scene = preload("res://Scenes/Actor/PlayerCamera.tscn")
const player_scene = preload("res://Scenes/Actor/Player.tscn")

@export var _version_label: Label
@export var screen_container: HBoxContainer
@export var _cam_zoom: Vector2 = Vector2.ONE
@export var _game_start_ui: GameStartUI
@export var _game_win_ui: GameWinUI

var _level_to_load: String = "res://Scenes/Level/Level1.tscn"

# Keeping track of added viewports - mapping of playerid to PlayerViewport
var _player_viewports: Dictionary[int, PlayerViewport]
var _first_subviewport : SubViewport = null
# This is the actual loaded game level
var _level_node: GameLevel = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If we resize the game, resize the viewports
	get_tree().root.size_changed.connect(_update_viewport_size)
	var added_players: int = 0
	_version_label.text = ClimbGameManager.get_overlay_text()
	
	for player in ClimbGameManager._players:
		if player != null:
			print("Adding player id " + str(player.get_player_id()) + " as player " + str(added_players) )
			# The player dectection system will already have set
			# player id, controls, and character
			# The PlayerMovement script will set the sprite frames
			# based on the selected character
			var new_player: PlayerMovement = player_scene.instantiate()
			var player_camera: PlayerCamera = null
			new_player.init_player(player._player_index)
			var player_viewport = _add_new_player_viewport(new_player)
			player_viewport.player_id = player.get_player_id()
			if added_players == 0:
				_load_level() #loads level into first viewport, sets _level_node
			player_viewport.parallax_layer = _level_node._parallax_layer.duplicate()
			player_viewport.sub_viewport.add_child(player_viewport.parallax_layer)
			player_viewport.parallax_layer.visible = true
			print("SV cam = " + player_viewport.sub_viewport.get_camera_2d().name)
			player_camera = player_viewport.player_camera
			_player_viewports[player.get_player_id()] = player_viewport
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
	

func _add_new_player_viewport(player_node: CharacterBody2D) -> PlayerViewport:
	var player_viewport: PlayerViewport = PlayerViewport.new()
	 
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
	
	#make this camera the current for the subviewport
	new_cam.make_current()
	
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
	
	player_viewport.player_camera = new_cam
	player_viewport.sub_viewport = new_sv
	return player_viewport

func _load_level() -> void:
	#Load the level - they all need GameLevel attached to their root
	_level_node = load(_level_to_load).instantiate() as GameLevel
	# Each subviewport will copy the parallax layer, we want to
	# disable the main level one.
	_level_node._parallax_layer.visible = false
	#The level lives only in the first subviewport
	_first_subviewport.add_child(_level_node)
	
func _update_viewport_size() -> void:
	var num_viewports: int = screen_container.get_children().size()
	var game_size: Vector2 = get_viewport().get_visible_rect().size
	for viewport in screen_container.get_children():
		var subv: SubViewport = viewport.get_child(0) #should be the subviewport
		subv.size.x = (game_size.x / num_viewports)
		subv.size.y = game_size.y
		
				
		 
	
