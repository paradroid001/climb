extends Object
class_name GameAction

enum InputState {NOT_PRESSED, PRESSED, HELD, RELEASED}

var _inputs: Dictionary[String, IGameInput]
var _state: InputState
var _time_held: float
# this is where you are going to have held time and
# a normalised direction etc

func _init() -> void:
	_state = InputState.NOT_PRESSED
	_time_held = 0

func tick(delta: float) -> void:
	# if you ENTER the tick state in released, you
	# become NOT PRESSED
	#if _state == InputState.RELEASED:
	#	_state == InputState.NOT_PRESSED
	# now collect new input
	for input in _inputs.values():
		#print("Input: " + input.get_id())
		input.tick(delta)
	
func add_input(input: IGameInput) -> void:
	var newid: String = input.get_id()
	print("Adding input " + input.get_id())
	if ! newid in _inputs.keys():
		_inputs[newid] = input
		input.set_parent_action(self)

func remove_input(input: IGameInput) -> void:
	if input.get_id() in _inputs.keys():
		input.set_parent_action(null)
		_inputs.erase(input.get_id())
		
# one of the inputs was pressed
func on_pressed(id: String, delta: float) -> void:
	if _state == InputState.NOT_PRESSED:
		#print("Pressed " + id)
		_state = InputState.PRESSED
		_time_held = delta
	elif _state == InputState.PRESSED or _state == InputState.HELD:
		_time_held += delta
		_state == InputState.HELD
	
# one of the inputs was released
func on_released(id: String, delta: float) -> void:
	if _state == InputState.PRESSED or _state == InputState.HELD:
		#print("Released " + id)
		_state = InputState.RELEASED
		_time_held = 0
	elif _state == InputState.RELEASED:
		_state = InputState.NOT_PRESSED
		_time_held = 0

func just_pressed() -> bool:
	return _state == InputState.PRESSED

func is_pressed() -> bool:
	return _state == InputState.HELD or just_pressed()

func not_pressed() -> bool:
	return _state == InputState.NOT_PRESSED or just_released()
	
func just_released() -> bool:
	return _state == InputState.RELEASED
	
func time_held() -> float:
	return _time_held
	
func vector2() -> Vector2:
	for input in _inputs.values():
		if input.get_input_type() == IGameInput.InputType.TWO_D:
			#get the normalised vector
			return input.get_vector2()
	return Vector2.ZERO
	
