extends Control
class_name MainMenu

var player_count: int = 0

@export var hbox: HBoxContainer
@export var player_config_prefab : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ClimbGameManager.on_player_joined.connect(new_player_join)

func new_player_join(player: ClimbPlayer) -> void:
	var player_config: MenuPlayerConfig = player_config_prefab.instantiate()
	player_config.connected_player_controls = player._control
	hbox.add_child(player_config)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#detect_joy_activity()
	ClimbGameManager.detect_new_player_input()
