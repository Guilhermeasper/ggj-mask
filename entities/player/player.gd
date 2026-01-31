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

var _current_mask: MaskData = MASKS[0]
var _mask_index: int = 0
var _extra_jumps_remaining: int = 0

func _ready() -> void:
	_switch_mask(0)

func _physics_process(delta: float) -> void:
	if is_on_floor():
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
		# Flip sprite based on direction
		$Body.scale.x = abs($Body.scale.x) * direction
		# Also flip the mask position? No, mask is child.
		# If mask is top_level, it ignores parent transform.
		# But when attached (top_level false), it inherits.
		# If we flip parent scale, the child position (1, -28) might flip to (-1, -28) which is correct for looking left.
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("mask_left"):
		_switch_mask(-1)
	elif Input.is_action_just_pressed("mask_right"):
		_switch_mask(1)
		
	# Throw mask input (using Z key as temporary bind)
	if Input.is_key_pressed(KEY_Z):
		# Default to whatever direction we are facing (based on scale)
		var throw_dir = Vector2.RIGHT
		
		# Allow overriding with input if moving?
		# Standard is: throw where you are facing.
		
		$Mask.throw(throw_dir)
	
	move_and_slide()

func _switch_mask(direction: int) -> void:
	_mask_index = wrapi(_mask_index + direction, 0, MASKS.size())
	_current_mask = MASKS[_mask_index]
	_extra_jumps_remaining = _current_mask.extra_jumps
	
	# TODO: Remover quando as mascaras tiverem suas proprias texturas
	var gradient = $Mask/Sprite2D.texture.gradient
	for i in range(gradient.get_point_count()):
		gradient.set_color(i, _current_mask.color)
	
	for i in range(MASKS.size()):
		set_collision_mask_value(i + 4, i == _mask_index || i == 0)
