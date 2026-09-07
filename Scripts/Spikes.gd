extends AnimatableBody2D
class_name Spikes

@export var _area_2d: Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_area_2d.connect(ClimbGameManager.ON_COLLISION_SIGNAL, on_area2d_body_enter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_area2d_body_enter(body) -> void:
	if body is PlayerMovement:
		var pm = body as PlayerMovement
		pm.hit_by_spikes(self)
