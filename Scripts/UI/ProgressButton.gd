extends Button
class_name ProgressButton

@export var _progress: TextureProgressBar
@export var _button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func init(prog_max: float, step: float = 0) -> void:
	_progress.max_value = prog_max
	_progress.step = step
	toggle_mode = true

func reset() -> void:
	_progress.value = 0
	_button.button_pressed = false

func set_value(value: float) -> float:
	_progress.value = value
	if is_full():
		_button.button_pressed = true
	else:
		_button.button_pressed = false
	#print(str(_progress.value))
	return _progress.value

func get_value() -> float:
	return _progress.value
	
func is_full() -> bool:
	return _progress.value >= _progress.max_value
