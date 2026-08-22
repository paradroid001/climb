extends Node
class_name ClimbControl

enum ControllerType { GAMEPAD, WIIMOTE, KEYBOARD }
var device_id: int
var device_type: ControllerType

"""
# mapping between name and device input
var action_map: Dictionary
var action_states: Dictionary

# Inputs
const input_horizontal: String = "horizontal"
const input_vertical: String = "vertical"
const input_button_A: String = "button_a"
const input_button_B: String = "button_b"

# Actions

# Action States
const actions_started: String = "started"
const actions_current: String = "current"
const actions_ended: String = "ended"
"""

# pressed direction
var direction: ClimbInput
var jump: ClimbInput
var special: ClimbInput

func _init(id: int, type: ControllerType) -> void:
	device_id = id
	device_type = type
	direction = ClimbInput.new()
	jump = ClimbInput.new()
	special = ClimbInput.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#action_states[actions_started] = []
	#action_states[actions_ended] = []
	#action_states[actions_current] = []
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if device_type == ControllerType.GAMEPAD:
		collect_gamepad_input(delta)

func collect_gamepad_input(delta: float) -> void:
	#for button_id in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN]:
	##var h: float = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_RIGHT):
		direction.press(delta)
	else:
		direction.release()
	if Input.is_joy_button_pressed(device_id, JOY_BUTTON_A):
		jump.press(delta)
	else:
		jump.release()
	
	if Input.is_joy_button_pressed(device_id, JOY_BUTTON_B):
		special.press(delta)
	else:
		special.release()
