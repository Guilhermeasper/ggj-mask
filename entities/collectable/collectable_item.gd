extends Area2D

@export var mask_data: MaskData


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect_mask"):
		body.collect_mask(mask_data)
		queue_free()
