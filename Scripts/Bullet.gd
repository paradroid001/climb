extends RigidBody2D
class_name Bullet

@export var _sprite: AnimatedSprite2D
@export var _area2d: Area2D

var _owner: ClimbPlayer
var _owner_level: GameLevel
var _bounces: int = 3
var _direction: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect(ClimbGameManager.ON_COLLISION_SIGNAL, rb2d_on_body_enter)
	_area2d.connect(ClimbGameManager.ON_COLLISION_SIGNAL, area2d_on_body_enter)
	apply_impulse(_direction * 1000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func init_bullet(direction: Vector2, player: ClimbPlayer, level: GameLevel) -> void:
	_sprite.sprite_frames = player.get_character().animation_frames
	_sprite.scale = Vector2.ONE * 0.5
	_owner = player
	_owner_level = level
	_direction = direction
	
func rb2d_on_body_enter(body: Node2D) -> void:
	print("Bullet hit solid something")
	_bounces -= 1
	if _bounces == 0:
		print("Bullet was destroyed, we lost a powerup")
		queue_free()

func area2d_on_body_enter(body: Node2D) -> void:
	print ("Bullet hit player or another buller or a powerup?")
	if body is PlayerMovement:
		var other: PlayerMovement = body
		if other._player_id != _owner._player_index:
			_owner_level.players_collided(body, null)
