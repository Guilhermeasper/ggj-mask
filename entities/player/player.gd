extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -550.0
const CROUCH_SPEED := 150.0

const WHITE_MASK = preload("res://resources/masks/white_mask.tres")
const YELLOW_MASK = preload("res://resources/masks/yellow_mask.tres")
const RED_MASK = preload("res://resources/masks/red_mask.tres")
const BLUE_MASK = preload("res://resources/masks/blue_mask.tres")

const ALL_MASKS: Array[MaskData] = [
	WHITE_MASK,
	YELLOW_MASK,
	RED_MASK,
	BLUE_MASK,
]

enum MaskColors {
	NONE = 0,
	YELLOW = 1,
	RED = 2,
	BLUE = 3,
}

const INITIAL_MASK_COLOR = MaskColors.NONE

@onready var background_color = %CanvasLayer
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var mask_node = $Mask

var _mask_index: int = INITIAL_MASK_COLOR
var _current_mask: MaskData = ALL_MASKS[INITIAL_MASK_COLOR]
var _extra_jumps_remaining: int = 0
var _available_masks: Array[MaskData] = ALL_MASKS
var mask_default_position: Vector2
var mask_offset: int = 12


func _ready() -> void:
	set_collision_layers()
	mask_default_position = mask_node.position
	background_color.change_color(_current_mask.color)

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
		mask_node.flip_masks(direction < 0)
		if direction < 0:
			mask_node.position.x = mask_default_position.x - mask_offset
		else:
			mask_node.position.x = mask_default_position.x

	if Input.is_action_just_pressed("mask_left"):
		_switch_mask(-1)
	elif Input.is_action_just_pressed("mask_right"):
		_switch_mask(1)

	if Input.is_key_pressed(KEY_Z):
		var throw_dir = Vector2.RIGHT
		mask_node.throw(throw_dir)

	move_and_slide()


func die() -> void:
	FadeTransition.fade_in()
	await FadeTransition.transition_finished
	get_tree().reload_current_scene()
	FadeTransition.fade_out()


func collect_mask(mask: MaskData) -> void:
	_available_masks.append(mask)


func set_collision_layers() -> void:
	for collision_mask_index in range(5, 8):
		var should_collide = collision_mask_index != _current_mask.target_collision_layer
		set_collision_mask_value(collision_mask_index, should_collide)
		mask_node.set_collision_mask_value(collision_mask_index, should_collide)


func _switch_mask(direction: int) -> void:
	# update mask
	_mask_index = wrapi(_mask_index + direction, 0, _available_masks.size())
	_current_mask = _available_masks[_mask_index]

	_extra_jumps_remaining = _current_mask.extra_jumps
	background_color.change_color(_current_mask.color)
	mask_node.set_mask_color(_current_mask.mask_name)

	set_collision_layers()


func set_respawn_position(checkpoint_position: Vector2) -> void:
	GameManager.save_player_position(checkpoint_position)
