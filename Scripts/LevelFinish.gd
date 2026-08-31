extends Node2D
class_name LevelFinish

#Emit when a player touches this.
signal player_has_won(player: PlayerMovement)

@export var _area2d: Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_area2d.connect(ClimbGameManager.ON_COLLISION_SIGNAL, on_area2d_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func on_area2d_entered(body) -> void:
	if body is PlayerMovement:
		player_has_won.emit(body)
