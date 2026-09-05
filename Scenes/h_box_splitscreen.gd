extends HBoxContainer

@export var level: Node
@export var svp1: SubViewport
@export var svp2: SubViewport
@export var cam1: Camera2D
@export var cam2: Camera2D
@export var player1: Node
@export var player2: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#level = $"../Level1"
	#svp1 = $SubViewportContainer/SubViewport
	#svp2 = $SubViewportContainer2/SubViewport
	#cam1 = $SubViewportContainer/SubViewport/Camera2D
	#cam2 = $SubViewportContainer2/SubViewport/Camera2D
	#player1 = $"../Player"
	#player2 = $"../Player2"
	
	#svp1.get_viewport().world_2d = level
	#svp2.get_viewport().world_2d = level
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#cam1.global_position = player1.global_position
	#cam2.global_position = player2.global_position
	pass
