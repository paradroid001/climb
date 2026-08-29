@abstract
class_name IGameInput
extends Object

enum ControllerType { GAMEPAD, WIIMOTE, KEYBOARD }
enum InputType {ONE_D, TWO_D}

var _device_id: int
var _type: ControllerType
var _parent_action: GameAction
var _id : String
var _input_type: InputType

@abstract func tick(delta: float) -> void
#@abstract func set_parent_action(action: GameAction) -> void
#@abstract func get_id() -> String

func get_input_type() -> InputType:
	return _input_type

func get_id() -> String:
	return _id

func set_parent_action(parent: GameAction) -> void:
	_parent_action = parent

#@abstract func just_pressed() -> bool
#@abstract func is_pressed() -> bool
#@abstract func not_pressed() -> bool
#@abstract func just_released() -> bool
