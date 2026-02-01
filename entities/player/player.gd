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

enum MaskColors {
	NONE = 0,
	YELLOW = 1,
	RED = 2,
	BLUE = 3,
}

const INITIAL_MASK_COLOR = MaskColors.NONE

@onready var background_color = %BackgroundColor
@onready var sprite: AnimatedSprite2D = $Sprite

var _mask_index: int = INITIAL_MASK_COLOR
var _current_mask: MaskData = MASKS[_mask_index]
var _extra_jumps_remaining: int = 0


func _ready() -> void:
	_switch_mask(INITIAL_MASK_COLOR)
	background_color.color = _current_mask.color

	var checkpoint_position = GameManager.get_respawn_position()

	if checkpoint_position != Vector2.ZERO:
		global_position = checkpoint_position


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_extra_jumps_remaining = _current_mask.extra_jumps
	else:
		sprite.play("jump")
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif _extra_jumps_remaining > 0:
			velocity.y = JUMP_VELOCITY
			_extra_jumps_remaining -= 1

	var direction := Input.get_axis("left", "right")
	if (direction != 0) && is_on_floor():
		sprite.play("walk")
	elif is_on_floor():
		sprite.play("idle")

	velocity.x = direction * SPEED
	if direction != 0:
		sprite.flip_h = direction < 0
		$Mask.position.x = -abs($Mask.position.x) if direction < 0 else abs($Mask.position.x)

	if Input.is_action_just_pressed("mask_left"):
		_switch_mask(-1)
	elif Input.is_action_just_pressed("mask_right"):
		_switch_mask(1)

	if Input.is_key_pressed(KEY_Z):
		var throw_dir = Vector2.RIGHT
		$Mask.throw(throw_dir)

	move_and_slide()


func die() -> void:
	FadeTransition.fade_in()
	await FadeTransition.transition_finished
	get_tree().reload_current_scene()
	FadeTransition.fade_out()


func _switch_mask(direction: int) -> void:
	_mask_index = wrapi(_mask_index + direction, 0, MASKS.size())
	_current_mask = MASKS[_mask_index]
	_extra_jumps_remaining = _current_mask.extra_jumps
	background_color.color = _current_mask.color

	var gradient = $Mask/Polygon2D
	gradient.color = _current_mask.color

	for i in range(MASKS.size()):
		var should_collide = i != _mask_index || i == 0
		set_collision_mask_value(i + 4, should_collide)
		$Mask.set_collision_mask_value(i + 4, should_collide)


func set_respawn_position(checkpoint_position: Vector2) -> void:
	GameManager.save_player_position(checkpoint_position)
