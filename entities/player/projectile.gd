extends Area2D

const INITIAL_SPEED := 200.0
const MAX_SPEED := 800.0
const ACCELERATION := 600.0
const LIFETIME := 3.0

var direction := Vector2.RIGHT
var current_speed := INITIAL_SPEED


func _ready() -> void:
	$AnimatedSprite2D.play("default")
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	current_speed = min(current_speed + ACCELERATION * delta, MAX_SPEED)
	position += direction * current_speed * delta


func _on_body_entered(_body: Node2D) -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("die"):
		area.die()
	queue_free()
