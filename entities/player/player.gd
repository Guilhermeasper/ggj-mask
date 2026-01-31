extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const CROUCH_SPEED = 150.0

enum MaskType {
	WHITE = 0,
	BLUE = 1,
	RED = 2,
	YELLOW = 3
}

var mask_modifier: MaskType = MaskType.WHITE

const MASK_COLORS = {
	MaskType.WHITE: Color(1, 1, 1, 1),
	MaskType.BLUE: Color(0.27999997, 0.13999999, 0.7, 1),
	MaskType.RED: Color(0.7, 0.070000015, 0.070000015, 1),
	MaskType.YELLOW: Color(0.82500005, 0.9, 0, 1)
}

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("mask_left"):
		_switch_mask(-1)
	elif Input.is_action_just_pressed("mask_right"):
		_switch_mask(1)
	
	move_and_slide()

func _switch_mask(direction: int) -> void:
	mask_modifier = calc_new_modifier(mask_modifier, direction)
	
	$Polygon2D.color = MASK_COLORS[mask_modifier]
	
	for i in range(4):
		set_collision_mask_value(i + 3, i == mask_modifier || i == MaskType.WHITE)


func calc_new_modifier(current: MaskType, direction: int) -> MaskType:
	var new_value = (current + direction) % 4
	if new_value < 0:
		new_value += 4
	return new_value as MaskType
