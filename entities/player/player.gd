extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -550.0
const CROUCH_SPEED := 150.0

@onready var background_color = %CanvasLayer
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var mask_node = $Mask
@onready var hud = $Camera2D/HUD

var _extra_jumps_remaining: int = 0
var mask_default_position: Vector2
var mask_offset: int = 12


func _ready() -> void:
	set_collision_layers()
	mask_default_position = mask_node.position
	background_color.change_color(GameManager.current_mask.mask_name)

	var checkpoint_position = GameManager.get_respawn_position()
	for mask in GameManager.available_masks:
		hud.show_mask(mask.mask_name)
	GameManager.current_mask = GameManager.masks["white"]
	hud.select_mask(GameManager.current_mask.mask_name)

	if checkpoint_position != Vector2.ZERO:
		global_position = checkpoint_position


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_extra_jumps_remaining = GameManager.current_mask.extra_jumps
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
	GameManager.available_masks.append(mask)
	hud.show_mask(mask.mask_name)


func set_collision_layers() -> void:
	for collision_mask_index in range(5, 8):
		var should_collide = collision_mask_index != GameManager.current_mask.target_collision_layer
		set_collision_mask_value(collision_mask_index, should_collide)
		mask_node.set_collision_mask_value(collision_mask_index, should_collide)


func _switch_mask(direction: int) -> void:
	# update mask
	GameManager.current_mask_id = wrapi(GameManager.current_mask_id + direction, 0, GameManager.available_masks.size())
	GameManager.current_mask = GameManager.available_masks[GameManager.current_mask_id]

	_extra_jumps_remaining = GameManager.current_mask.extra_jumps
	background_color.change_color(GameManager.current_mask.mask_name)
	mask_node.set_mask_color(GameManager.current_mask.mask_name)
	hud.select_mask(GameManager.current_mask.mask_name)

	set_collision_layers()


func set_respawn_position(checkpoint_position: Vector2) -> void:
	GameManager.save_player_position(checkpoint_position)
