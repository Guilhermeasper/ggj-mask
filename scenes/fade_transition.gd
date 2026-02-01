extends CanvasLayer

signal transition_finished


func _ready() -> void:
	print("FadeTransition ready")
	$ColorRect.visible = false
	$AnimationPlayer.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(_animation_name: String) -> void:
	transition_finished.emit()


func fade_in() -> void:
	$ColorRect.visible = true
	$AnimationPlayer.play("fade_in")


func fade_out() -> void:
	$ColorRect.visible = false
	$AnimationPlayer.play("fade_out")
