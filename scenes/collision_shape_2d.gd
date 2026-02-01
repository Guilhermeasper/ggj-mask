extends Area2D

@export var checkpoint_marker: Marker2D


func _on_body_entered(body: Object) -> void:
	if body.has_method("set_respawn_position"):
		body.set_respawn_position(checkpoint_marker.position)
