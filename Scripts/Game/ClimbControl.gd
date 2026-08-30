extends Node
class_name ClimbControl

@export var device_id: int
@export var device_type: IGameInput.ControllerType

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
var direction: GameAction #ClimbInput
var jump: GameAction #ClimbInput
var special: GameAction #ClimbInput

func _init(id: int = 99, type: IGameInput.ControllerType = IGameInput.ControllerType.KEYBOARD) -> void:
	device_id = id
	device_type = type
	#direction = ClimbInput.new(ClimbInput.InputType.AXIS)
	#jump = ClimbInput.new(ClimbInput.InputType.BUTTON)
	#special = ClimbInput.new(ClimbInput.InputType.BUTTON)
	
	direction = GameAction.new()
	jump = GameAction.new()
	special = GameAction.new()
	
	if type == IGameInput.ControllerType.GAMEPAD:
		print("new gamepad: " + str(device_id))
		jump.add_input(GameInput1D.new(type, device_id, JOY_BUTTON_A))
		special.add_input(GameInput1D.new(type, device_id, JOY_BUTTON_B))
		var dir_joy: GameInput2D = GameInput2D.new(type, device_id)
		dir_joy.add_axis(GameInput2D.Input2DType.HORIZONTAL, JOY_AXIS_LEFT_X)
		dir_joy.add_axis(GameInput2D.Input2DType.VERTICAL, JOY_AXIS_LEFT_Y)
		
		
		var action_joypad_left = GameAction.new()
		var input_joypad_left = GameInput1D.new(type, device_id, JOY_BUTTON_DPAD_LEFT)
		action_joypad_left.add_input(input_joypad_left)
		var action_joypad_right = GameAction.new()
		var input_joypad_right = GameInput1D.new(type, device_id, JOY_BUTTON_DPAD_RIGHT)
		action_joypad_right.add_input(input_joypad_right)
		var action_joypad_up = GameAction.new()
		action_joypad_up.add_input(GameInput1D.new(type, device_id, JOY_BUTTON_DPAD_UP))
		var action_joypad_down = GameAction.new()
		action_joypad_down.add_input(GameInput1D.new(type, device_id, JOY_BUTTON_DPAD_DOWN))
		
		
		var dir_joypad = GameInput2D.new(type, device_id)
		dir_joypad.add_axis_actions(GameInput2D.Input2DType.HORIZONTAL, action_joypad_left, action_joypad_right)
		dir_joypad.add_axis_actions(GameInput2D.Input2DType.VERTICAL, action_joypad_down, action_joypad_up)
		
		direction.add_input(dir_joypad)
		
		direction.add_input(dir_joy)
		
		
	elif type == IGameInput.ControllerType.KEYBOARD:
		print("new keyboard " + str(device_id))
		jump.add_input(GameInput1D.new(type, device_id, KEY_SPACE))
		special.add_input(GameInput1D.new(type, device_id, KEY_CTRL))
		
		var dir_action_left:GameAction = GameAction.new()
		dir_action_left.add_input(GameInput1D.new(type, device_id, KEY_LEFT))
		var dir_action_right:GameAction = GameAction.new()
		dir_action_right.add_input(GameInput1D.new(type, device_id, KEY_RIGHT))
		var dir_action_up:GameAction = GameAction.new()
		dir_action_up.add_input(GameInput1D.new(type, device_id, KEY_UP))
		var dir_action_down:GameAction = GameAction.new()
		dir_action_down.add_input(GameInput1D.new(type, device_id, KEY_DOWN))
		
		var dir: GameInput2D = GameInput2D.new(type, 99)
		dir.add_axis_actions(GameInput2D.Input2DType.HORIZONTAL, dir_action_left, dir_action_right)
		dir.add_axis_actions(GameInput2D.Input2DType.VERTICAL, dir_action_down, dir_action_up)
		
		direction.add_input(dir)
		
	elif type == IGameInput.ControllerType.WIIMOTE:
		pass
	else:
		print ("Unmsupported Input type")
	
	#joy:
		#device_id: 1
		#"horizontal": AXIS, 1
		#"vertical": AXIS, 2
		#"jump": BUTTON, BUTTON_A
		#"special": BUTTON, BUTTON_B
	#
	#var joy_mapping: Dictionary[String, Dictionary[ClimbInput.InputType, int]]
	
	#AddKeyMappings()
	
func AddKeyMappings() -> void:
	var action_name = "Jump"
	# 1. Check if the action exists; if not, create it
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	# 2. Define a physical key (e.g., Spacebar)
	var key_event = InputEventKey.new()
	key_event.physical_keycode = KEY_SPACE
	#var joy_event = InputEventJoypadButton.new()
	#var axis_event = InputEventAction.new()
	#axis_event.
	
	# 3. Bind the physical key to the action
	InputMap.action_add_event(action_name, key_event)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#action_states[actions_started] = []
	#action_states[actions_ended] = []
	#action_states[actions_current] = []
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction.tick(delta)
	jump.tick(delta)
	special.tick(delta)	
	#match device_type:
		#ControllerType.GAMEPAD:
			#collect_gamepad_input(delta)
		#ControllerType.KEYBOARD:
			#collect_kb_input(delta)

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

func collect_kb_input(delta: float) -> void:
	if Input.is_action_pressed("Jump"):
		print("Kb Jump")
		jump.press(delta)
	if Input.is_action_just_released("Jump"):
		print("Kb jump released, held: " + str(jump.time_held()))
		jump.release()
