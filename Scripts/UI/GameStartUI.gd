extends PanelContainer
class_name GameStartUI

# emit this signal when we are done.
signal game_start_countdown_timeout

@export var _countdown_label: Label
var _active: bool
var _total_time:float
var _countdown_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_active = false
	visible = false

func countdown(time: float) -> void:
	_total_time = time
	_countdown_timer = 0
	visible = true
	_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _active:
		_countdown_timer += delta
		var _timeleft_int: int = ceil(_total_time - _countdown_timer)
		_countdown_label.text = str(_timeleft_int)
		
		if _countdown_timer >= _total_time:
			_active = false
			visible = false
			game_start_countdown_timeout.emit()					
