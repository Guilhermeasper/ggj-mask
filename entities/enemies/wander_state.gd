extends State

class_name WanderState

var _enemy: Enemy
var _target: Vector2
var _direction: Vector2


func _ready() -> void:
	_enemy = get_parent().get_parent() as Enemy
	if _enemy.target_1 == Vector2.ZERO and _enemy:
		_enemy.target_1 = _enemy.global_position


func enter() -> void:
	_target = _enemy.target_2
	_update_direction()


func update(delta: float) -> void:
	if not _enemy:
		return

	if not _enemy.is_on_floor() and not _enemy.can_fly:
		_enemy.velocity += _enemy.get_gravity() * delta

	_enemy.velocity.x = _direction.x * _enemy.speed

	if _has_reached_target():
		_target = _enemy.target_1 if _target == _enemy.target_2 else _enemy.target_2
		_update_direction()

	_enemy.move_and_slide()


func _has_reached_target() -> bool:
	var to_target := _target - _enemy.global_position
	return to_target.dot(_direction) <= 0


func _update_direction() -> void:
	_direction = (_target - _enemy.global_position).normalized()
	_enemy.flip_sprite(_direction.x < 0)
