extends Node

var last_safe_position: Vector2 = Vector2.ZERO


func save_player_position(pos: Vector2) -> void:
	last_safe_position = pos


func get_respawn_position() -> Vector2:
	return last_safe_position
