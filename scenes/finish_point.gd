extends Area2D

func _on_body_entered(_body: Object) -> void:
	GameManager.call_deferred("next_level")
