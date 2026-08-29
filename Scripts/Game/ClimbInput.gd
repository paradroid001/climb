extends Object
class_name ClimbInput
enum InputState {NOT_PRESSED, PRESSED, HELD, RELEASED}
enum InputType {AXIS, BUTTON}

# A single input type for the Climb Game.

# Some internal state
var _type: InputType
var _state: InputState
var _timeHeld: float
var _vec2: Vector2

func _init(type: InputType) -> void:
	_state = InputState.NOT_PRESSED
	_timeHeld = 0
	_vec2 = Vector2.ZERO
	#print("ClimbInput inited")

func press(dt: float) -> void:
	if not_pressed():
		_state = InputState.PRESSED
		_timeHeld = 0
		print("Pressed")
	else:
		_state = InputState.HELD
		_timeHeld += dt
		#print("Held")
		
func release() -> void:
	if is_held():
		_state = InputState.RELEASED
		_timeHeld = 0
		print("Released")
	else:
		_state = InputState.NOT_PRESSED
		_timeHeld = 0

# Player is not pressing the button, includes 'just released' state
func not_pressed() -> bool:
	return _state == InputState.NOT_PRESSED || _state == InputState.RELEASED

# Player just started pressing the button
func is_pressed() -> bool:
	return _state == InputState.PRESSED
	
# Player is holding button
func is_held() -> bool:
	# We don't discriminate on the pressed state, i.e. first frame pressed.
	# That should also count as pressed
	return _state == InputState.HELD || _state == InputState.PRESSED

# Player just released the button
func is_released() -> bool:
	return _state == InputState.RELEASED

# How long has this input been held?	
func time_held() -> float:
	return _timeHeld
