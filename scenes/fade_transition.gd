extends CanvasLayer

signal transition_finished


func _ready() -> void:
	$ColorRect.visible = false
	$AnimationPlayer.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "fade_in":
		$AnimationPlayer.play("fade_out")

	elif animation_name == "fade_out":
		$ColorRect.visible = false
		transition_finished.emit()


func transition() -> void:
	$ColorRect.visible = true
	$AnimationPlayer.play("fade_in")
