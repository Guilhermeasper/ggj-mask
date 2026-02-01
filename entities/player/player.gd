extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -500.0
const CROUCH_SPEED := 150.0

const MASKS: Array[MaskData] = [
	preload("res://resources/masks/white_mask.tres"),
	preload("res://resources/masks/red_mask.tres"),
	preload("res://resources/masks/yellow_mask.tres"),
	preload("res://resources/masks/blue_mask.tres"),
]

@onready var background_color = %BackgroundColor

var _current_mask: MaskData = MASKS[0]
var _mask_index: int = 0
var _extra_jumps_remaining: int = 0


func _ready() -> void:
	_switch_mask(0)
	background_color.color = _current_mask.color

	var checkpoint_position = GameManager.get_respawn_position()

	if checkpoint_position != Vector2.ZERO:
		global_position = checkpoint_position


func _physics_process(delta: float) -> void:
	if is_on_floor():
		print(global_position)
		_extra_jumps_remaining = _current_mask.extra_jumps
	else:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif _extra_jumps_remaining > 0:
			velocity.y = JUMP_VELOCITY
			_extra_jumps_remaining -= 1

	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		$Body.scale.x = abs($Body.scale.x) * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("mask_left"):
		_switch_mask(-1)
	elif Input.is_action_just_pressed("mask_right"):
		_switch_mask(1)

	if Input.is_key_pressed(KEY_Z):
		var throw_dir = Vector2.RIGHT
		$Mask.throw(throw_dir)

	move_and_slide()


func die() -> void:
	FadeTransition.transition()
	await FadeTransition.transition_finished
	get_tree().reload_current_scene()


func _switch_mask(direction: int) -> void:
	_mask_index = wrapi(_mask_index + direction, 0, MASKS.size())
	_current_mask = MASKS[_mask_index]
	_extra_jumps_remaining = _current_mask.extra_jumps
	background_color.color = _current_mask.color

	var gradient = $Mask/Sprite2D.texture.gradient
	for i in range(gradient.get_point_count()):
		gradient.set_color(i, _current_mask.color)

	for i in range(MASKS.size()):
		var should_collide = i != _mask_index || i == 0
		set_collision_mask_value(i + 4, should_collide)
		$Mask.set_collision_mask_value(i + 4, should_collide)


func set_respawn_position(checkpoint_position: Vector2) -> void:
	GameManager.save_player_position(checkpoint_position)
