extends Area2D

class_name Enemy

@export var speed: float = 100.0
@export var can_fly: bool = false
@export var targets: Array[Marker2D] = []

@onready var sprite: AnimatedSprite2D = $Sprite

var _targets_index := 0
var _target_position: Vector2


func _ready() -> void:
	sprite.play("default")
	if targets.size() > 0:
		position = targets[_targets_index].global_position
		change_target()


func change_target() -> void:
	_targets_index = wrapi(_targets_index + 1, 0, targets.size())
	_target_position = targets[_targets_index].global_position


func _physics_process(delta: float) -> void:
	if targets.size() == 0:
		return
	global_position = global_position.move_toward(_target_position, speed * delta)
	if _has_reached_target():
		change_target()

	var direction = _target_position - global_position
	sprite.flip_h = direction.x < 0


func flip_sprite(flip: bool) -> void:
	sprite.flip_h = flip


func _has_reached_target() -> bool:
	var reached := global_position.distance_to(_target_position) < 5
	return reached


func _on_body_entered(body: Node) -> void:
	if body.has_method("die"):
		body.die()


func die() -> void:
	queue_free()
