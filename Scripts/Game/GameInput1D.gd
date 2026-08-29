class_name GameInput1D # 1D inputs like buttons
extends IGameInput
 
var _input_code: int

func _init(type: IGameInput.ControllerType, device_id: int, input_id: int) -> void:
	_device_id = device_id
	_type = type
	_input_code = input_id
	_input_type = InputType.ONE_D
	_parent_action = null
	_id = str(_type).right(2) + str(_device_id).right(3)+ str(input_id).right(3)

func tick(delta: float) -> void:
	if _parent_action == null:
			return
	match _type:
		ControllerType.GAMEPAD:
			if Input.is_joy_button_pressed(_device_id, _input_code):
				_parent_action.on_pressed(_id, delta)
			else:
				_parent_action.on_released(_id, delta)
		ControllerType.WIIMOTE:
			pass
		ControllerType.KEYBOARD:
			#check for pressed:
			if Input.is_physical_key_pressed(_input_code):
				_parent_action.on_pressed(_id, delta)
			else:
				_parent_action.on_released(_id, delta)
					
#func just_pressed() -> bool:
	#return false
	#
#func is_pressed() -> bool:
	#return false
	#
#func not_pressed() -> bool:
	#return false
	#
#func just_released() -> bool:
	#return false	
