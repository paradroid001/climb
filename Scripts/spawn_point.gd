extends Node2D
class_name SpawnPoint

const PLAYER_SPAWN_GROUP: String = "PlayerSpawn"
const POWERUP_SPAWN_GROUP: String = "PowerupSpawn"


@export var reusable: bool = false
@export var spawn_group: String = PLAYER_SPAWN_GROUP
var _used: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(spawn_group) #group for all spawn points
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Assign an entity to this spawnpoint
# Assume used status has been checked.
func assign() -> Vector2:
	if reusable or !_used:
		_used = true
	return global_position

func used() -> bool:
	if reusable or !_used:
		return false
	return true
