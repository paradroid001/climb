extends Object
class_name ClimbInput
enum InputState {NOT_PRESSED, PRESSED, HELD, RELEASED}

# A single input type for the Climb Game.

# Some internal state
var state_: InputState
var timeHeld_: float
var floatVal_: float
var vec2Val_: Vector2

func _init() -> void:
	state_ = InputState.NOT_PRESSED
	timeHeld_ = 0
	floatVal_ = 0
	vec2Val_ = Vector2.ZERO
	#print("ClimbInput inited")

func press(dt: float) -> void:
	if not_pressed():
		state_ = InputState.PRESSED
		timeHeld_ = 0
		print("Pressed")
	else:
		state_ = InputState.HELD
		timeHeld_ += dt
		#print("Held")
		
func release() -> void:
	if is_held():
		state_ = InputState.RELEASED
		timeHeld_ = 0
		print("Released")
	else:
		state_ = InputState.NOT_PRESSED
		timeHeld_ = 0

# Player is not pressing the button, includes 'just released' state
func not_pressed() -> bool:
	return state_ == InputState.NOT_PRESSED || state_ == InputState.RELEASED

# Player just started pressing the button
func is_pressed() -> bool:
	return state_ == InputState.PRESSED
	
# Player is holding button
func is_held() -> bool:
	# We don't discriminate on the pressed state, i.e. first frame pressed.
	# That should also count as pressed
	return state_ == InputState.HELD || state_ == InputState.PRESSED

# Player just released the button
func is_released() -> bool:
	return state_ == InputState.RELEASED

# How long has this input been held?	
func time_held() -> float:
	return timeHeld_
