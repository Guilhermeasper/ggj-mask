extends CharacterBody2D

enum MaskState { IDLE, THROWN, RETURNING }

@export var speed: float = 1200.0
@export var max_distance: float = 600.0
@export var return_speed: float = 800.0
@export var curve_power: float = 1500.0 # Upward force

@onready var yellow_sprite = $Yellow
@onready var red_sprite = $Red
@onready var blue_sprite = $Blue

var _mask_color = "none"

var _state: MaskState = MaskState.IDLE
var _start_position: Vector2
var _direction: Vector2

# Target position relative to parent when equipped
var _equip_position: Vector2 = Vector2(1, -28)


func throw(dir: Vector2) -> void:
	if _state != MaskState.IDLE:
		return

	_state = MaskState.THROWN
	_direction = dir.normalized()
	# If direction is zero (shouldn't happen), default to right
	if _direction == Vector2.ZERO:
		_direction = Vector2.RIGHT

	_start_position = global_position

	velocity = _direction * speed


func _ready() -> void:
	yellow_sprite.visible = false
	red_sprite.visible = false
	blue_sprite.visible = false


func set_mask_color(color: String) -> void:
	_mask_color = color


func flip_masks(flip: bool) -> void:
	yellow_sprite.flip_h = flip
	red_sprite.flip_h = flip
	blue_sprite.flip_h = flip


func _physics_process(delta: float) -> void:
	match _state:
		MaskState.IDLE:
			yellow_sprite.visible = _mask_color == "yellow"
			red_sprite.visible = _mask_color == "red"
			blue_sprite.visible = _mask_color == "blue"
		MaskState.THROWN:
			# Decelerate along the throw direction
			position.x += _direction.x * 20
			var forward_speed = velocity.dot(_direction)
			velocity -= _direction * speed * delta

			# Move
			move_and_slide()

			# Check transition conditions
			var dist = global_position.distance_to(_start_position)

			# If we stopped moving forward or went too far
			if forward_speed <= 0 or dist > max_distance:
				_state = MaskState.RETURNING
		MaskState.RETURNING:
			# Target the equip position on the player
			var target = get_parent().to_global(_equip_position)
			var to_target = global_position.direction_to(target)
			var dist = global_position.distance_to(target)

			# Homing behavior
			# Smoothly steer towards player or just accelerate?
			# Simple acceleration is more reliable for return
			velocity = velocity.move_toward(to_target * return_speed, return_speed * 4 * delta)

			move_and_slide()

			# Catch condition
			if dist < 50.0:
				_catch()


func _catch() -> void:
	_state = MaskState.IDLE
	top_level = true
	position = _equip_position
	velocity = Vector2.ZERO
	top_level = false
	rotation = 0
