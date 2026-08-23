extends Node2D
class_name GameLevel

var spawn_points: Array[SpawnPoint]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn points add themselves to the "spawn" group
	# Copy them into our spawn points group
	for item:SpawnPoint in get_tree().get_nodes_in_group("spawn"):
		spawn_points.push_back(item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_random_spawn_point() -> SpawnPoint:
	var available_spawn_points: Array[SpawnPoint]
	for sp in spawn_points:
		if !sp.used():
			available_spawn_points.push_back(sp)

	var num_spawn_points = available_spawn_points.size()
	if num_spawn_points == 0:
		print("No available spawn points in level")
		return null
	print("Choosing from " + str(num_spawn_points) + " spawn points")
	var index = randi_range(0, num_spawn_points-1)
	return available_spawn_points[index]
