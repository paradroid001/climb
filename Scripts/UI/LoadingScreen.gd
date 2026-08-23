extends CanvasLayer
class_name LoadingScreen

signal loading_screen_ready

@export var animation_player : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Loading Screen created")
	await animation_player.animation_finished
	loading_screen_ready.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_progress_changed(new_value: float) -> void:
	print("Loading progress changed: " + str(new_value))
	
func _on_load_finished() -> void:
	animation_player.play_backwards("fade_out")
	await animation_player.animation_finished
	print("Loading Screen destroyed")
	queue_free()
	
