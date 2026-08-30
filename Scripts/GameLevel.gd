extends Node2D
class_name GameLevel

enum LevelState {SETTING_UP, PLAYING, WIN}

signal all_players_joined
signal player_has_won(player: ClimbPlayer)

const _powerup_scene = preload("res://Scenes/Actor/powerup.tscn")
@export var powerup_impulse: Vector2
var _state: LevelState = LevelState.SETTING_UP
var spawns: Dictionary[String, Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn points add themselves to the various groups
	# Copy them into our spawn points dict
	spawns[SpawnPoint.PLAYER_SPAWN_GROUP] = []
	for item:SpawnPoint in get_tree().get_nodes_in_group(SpawnPoint.PLAYER_SPAWN_GROUP):
		#spawn_points.push_back(item)
		spawns[SpawnPoint.PLAYER_SPAWN_GROUP].push_back(item)
		#print("Created Player Spawn")
	
	spawns[SpawnPoint.POWERUP_SPAWN_GROUP] = []
	for item:SpawnPoint in get_tree().get_nodes_in_group(SpawnPoint.POWERUP_SPAWN_GROUP):
		#spawn_points.push_back(item)
		spawns[SpawnPoint.POWERUP_SPAWN_GROUP].push_back(item)

	#TODO for now we spawn a powerup for every spawn point
	# in future we could spawn only a certain number,
	# and spawnpoints could have weightings
	for item:SpawnPoint in  spawns[SpawnPoint.POWERUP_SPAWN_GROUP]:
		spawn_powerup(item.global_position)
	
	#Detect when children enter thr tree
	child_entered_tree.connect(on_child_enter_tree)
	
	# Supporting debug - players already in the level
	var entire_tree_nodes: Array[Node] = get_tree().root.find_children("*", "PlayerMovement", true, false)
	for item in entire_tree_nodes:
		on_child_enter_tree(item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_child_enter_tree(node: Node) -> void:
	if node is PlayerMovement:
		#print ("We have a player! " + node.name)
		node.connect("collided_with_player", players_collided)
	
func get_state() -> LevelState:
	return _state
	
func set_state(new_state: LevelState) -> void:
	pass

func players_collided(p1: PlayerMovement, p2: PlayerMovement) -> void:
	print("Players Collided! " + p1.name + ", " + p2.name)
	
	for colliding_player: PlayerMovement in [p1, p2]:
		var p_powerups = colliding_player.get_num_powerups()
		colliding_player.gain_powerups(-p_powerups)
		for i in range(p_powerups):
			print(colliding_player.name + " Ejecting powerups: " + str(p_powerups))
			#var pos: SpawnPoint = SpawnPoint.new()
			var pos: Vector2 = colliding_player.get_eject_point()
			#pos.reusable = true
			var powerup: Powerup = spawn_powerup(pos)
			powerup.time_to_enable = 1.5
			powerup.initial_impulse = Vector2.UP * powerup_impulse.y + Vector2.RIGHT * (powerup_impulse.x * randf() - (powerup_impulse.y/2))
			if powerup == null:
				print("Error: Spawned powerup was null!")
	
#if you don't give a spawnpoint, it picks a random one.
func spawn_powerup(spawn_position: Vector2) -> Powerup:
	if spawn_position == null:
		var spawnpoint:SpawnPoint = get_random_spawn_point(SpawnPoint.POWERUP_SPAWN_GROUP)
		if spawnpoint == null:
			print("No available powerup spawn point")
			return null
		else:
			spawn_position = spawnpoint.assign()
	
	var powerup = _powerup_scene.instantiate()
	powerup.global_position = spawn_position
	# Call deferred because we are often calling this
	# in the middle of the physics loop
	call_deferred("add_child", powerup)
	return powerup

func get_random_spawn_point(spawn_group: String) -> SpawnPoint:
	var spawn_points: Array = spawns[spawn_group]
	if spawn_points == null:
		return null
		 
	var available_spawn_points: Array[SpawnPoint]
	for sp:SpawnPoint in spawn_points:
		if !sp.used():
			available_spawn_points.push_back(sp)

	var num_spawn_points = available_spawn_points.size()
	if num_spawn_points == 0:
		print("No available spawn points in level")
		return null
	print("Choosing from " + str(num_spawn_points) + " spawn points")
	var index = randi_range(0, num_spawn_points-1)
	return available_spawn_points[index]
