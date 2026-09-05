extends Camera2D
class_name PlayerCamera

@export var _player_target: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player_target != null:
		global_position = _player_target.global_position

func set_target(target: Node2D) -> void:
	_player_target = target
