extends PanelContainer
class_name GameWinUI

@export var _back_to_menu_button: ProgressButton
@export var _player_name_label: Label
var _active: bool
var _winning_player: ClimbPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enable(false)

func set_winning_player(player: ClimbPlayer) -> void:
	_winning_player = player	

func enable(enabled:bool) -> void:
	if enabled and _winning_player != null:
		_player_name_label.text = _winning_player.get_character().character_name + " wins!"
	#Set the button's total time to 3 seconds for every player.
	_back_to_menu_button.init(ClimbGameManager.get_players().size() * 3)
	_active = enabled
	visible = _active

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !_active:
		return
	var total_time_held:float = 0
	for player: ClimbPlayer in ClimbGameManager.get_players():
		total_time_held += player.get_controls().jump.time_held()
	_back_to_menu_button.set_value(total_time_held)
	print("Progress: " + str(_back_to_menu_button.get_value()) )
	
	if _back_to_menu_button.button_pressed:
		ClimbGameManager.load_scene("Menu")
