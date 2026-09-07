@tool # 1. Allows the script to run live inside the editor
extends AnimatableBody2D
class_name Platform
enum PlatformMovementMode {HORIZONTAL, VERTICAL}

@export var _movement_mode: PlatformMovementMode = PlatformMovementMode.HORIZONTAL:
	set(value):
		_movement_mode = value
		recalc_offsets()
		queue_redraw()
		
@export var _movement_speed: float = 200

@export var _extents: Vector2:
	set(value):
		_extents = value
		recalc_offsets()
		queue_redraw()

var _original_position: Vector2
var _offset_start: Vector2
var _offset_end: Vector2
var _forward_journey: bool
var _timer: float
var _journey_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		_original_position = global_position
		_forward_journey = true
		recalc_offsets()
		var total_distance = _extents.x + _extents.y
		# total distance divided by speed
		_journey_time = total_distance / _movement_speed
		# how far is our start position into the entire journey
		var weight = _extents.x / total_distance
		# Start the 'timer' that far in
		_timer = _journey_time * weight
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Only process in game.
	if not Engine.is_editor_hint():
		if _forward_journey:
			_timer += delta
		else:
			_timer -= delta
			
		if _timer > _journey_time:
			_forward_journey = false
			_timer = _journey_time
		if _timer < 0:
			_forward_journey = true
			_timer = 0
		
		global_position = (_original_position + _offset_start).lerp((_original_position + _offset_end), _timer/_journey_time)
	
func recalc_offsets() -> void:
	print("recalc")
	if _movement_mode == PlatformMovementMode.HORIZONTAL:
		_offset_start = Vector2.LEFT * _extents.x
		_offset_end = Vector2.RIGHT * _extents.y
	else:
		_offset_start = Vector2.DOWN * _extents.x
		_offset_end = Vector2.UP * _extents.y	

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, _offset_start, Color.RED, 5.0, false)
		draw_line(Vector2.ZERO, _offset_end, Color.GREEN, 5.0, false)
		
