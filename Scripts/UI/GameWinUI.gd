extends PanelContainer
class_name GameWinUI

@export var _back_to_menu_button: ProgressButton
var _active: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enable(false)
	
func enable(enabled:bool) -> void:
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
