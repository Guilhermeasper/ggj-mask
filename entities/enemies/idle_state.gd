extends State
class_name EnemyIdleState

@export var enemy: Enemy
@export var target_list: Array[Vector2] = []

var index := 0

func enter():
	pass

func exit():
	pass

func update(delta):
	if enemy.position == target_list[index]:
		index = index + 1 % target_list.size()
	
	var direction = target_list[index] - enemy.position
	var move_direction = direction.normalized()
	
	if enemy:
		enemy.velocity = move_direction * enemy.SPEED * delta
