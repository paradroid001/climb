extends Resource
class_name ClimbSettings

const MAX_PLAYERS: int = 8 # this doesn't actually get exposed as it is const.
@export var characters: Array[ClimbCharacter]
