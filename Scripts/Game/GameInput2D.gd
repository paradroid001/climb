class_name GameInput2D # 2D inputs like axis
extends IGameInput

enum Input2DType {HORIZONTAL, VERTICAL}

class InputAxis:
	var _value: float
	func value() -> float:
		return 	_value
	func set_value(val: float) -> void:
		_value = val
	func tick(delta: float) -> void:
		pass
	
class AxisDirect:
	extends InputAxis
	var _device_type: IGameInput.ControllerType
	var _device_id: int
	var _axisnum: int
	
	func _init(type: IGameInput.ControllerType, device_id: int, axis: int) -> void:
		_device_type = type
		_device_id = device_id
		_axisnum = axis
		set_value(0)
		
	func tick(delta: float) -> void:
		if _device_type == IGameInput.ControllerType.GAMEPAD:
			_value = Input.get_joy_axis(_device_id, _axisnum)
		if _device_type == IGameInput.ControllerType.KEYBOARD:
			_value = 0
		if _device_type == IGameInput.ControllerType.WIIMOTE:
			_value = 0

	
class AxisActions:
	extends InputAxis
	var _neg: GameAction
	var _pos: GameAction
	
	func _init(neg: GameAction, pos: GameAction):
		_neg = neg
		_pos = pos
		set_value(0)
	
	func tick(delta: float) -> void:
		_neg.tick(delta)
		_pos.tick(delta)
		var val:float = 0
		if _neg.is_pressed():
			val -= 1
		if _pos.is_pressed():
			val +=1
		set_value(val)
 
var _mapping: Dictionary[Input2DType, InputAxis]
var _value: Vector2
var _values: Dictionary[Input2DType, float]

func _init(type: IGameInput.ControllerType, device_id: int) -> void:
	_device_id = device_id
	_type = type
	_parent_action = null
	_input_type = InputType.TWO_D
	_id = str(_type).right(2) + str(_device_id).right(3)+ str("AXI").right(3)
	_mapping[Input2DType.HORIZONTAL] = null
	_mapping[Input2DType.VERTICAL] = null
	
func tick(delta: float) -> void:
	if _mapping[Input2DType.HORIZONTAL] != null:
		_mapping[Input2DType.HORIZONTAL].tick(delta)
		_value.x = _mapping[Input2DType.HORIZONTAL].value()
	else:
		_value.y = 0.0
	if _mapping[Input2DType.VERTICAL] != null:
		_mapping[Input2DType.VERTICAL].tick(delta)
		_value.y = _mapping[Input2DType.VERTICAL].value()
	else:
		_value.y = 0.0
	if _value.length() > 0.01:
		_parent_action.on_pressed(_id, delta)
	else:
		_parent_action.on_released(_id, delta)
	
# for adding a non native axis, i.e. two buttons or keys
func add_axis_actions(axis: Input2DType, axisneg: GameAction, axispos: GameAction) -> void:
	_mapping[axis] = AxisActions.new(axisneg, axispos)
	
func add_axis(axis: Input2DType, axisnum: int) -> void:
	_mapping[axis] = AxisDirect.new(_type, _device_id, axis)
	

func get_axis(axis: Input2DType, normalised: bool = false) -> float:
	var val: Vector2
	if normalised:
		val = get_vector2()
	else:
		val = _value
		
	if axis == Input2DType.HORIZONTAL:
		return val.x
	else:
		return val.y

func get_vector2() -> Vector2:
	return _value.normalized()
