extends Resource
class_name ClimbCharacter

# Represents all the attributes of each Climb Character.
# i.e. Name, animations, etc.

@export var character_name: String
@export var animation_frames: SpriteFrames
@export var animation_map: Dictionary

func play_animation(name: String) -> void:
	if name in animation_map.keys():
		pass
