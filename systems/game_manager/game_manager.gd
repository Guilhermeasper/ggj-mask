extends Node

var last_safe_position: Vector2 = Vector2.ZERO
var current_level: int = 1
var levels: Dictionary = {
	1: "res://levels/level_1/level_1.tscn",
	2: "res://levels/level_2/level_2.tscn",
}


func load_level(level: int) -> void:
	last_safe_position = Vector2.ZERO
	current_level = level
	FadeTransition.fade_in()
	await FadeTransition.transition_finished
	get_tree().change_scene_to_file(levels[level])
	FadeTransition.fade_out()
	await FadeTransition.transition_finished


func next_level() -> void:
	current_level += 1
	load_level(current_level)


func save_player_position(pos: Vector2) -> void:
	last_safe_position = pos


func get_respawn_position() -> Vector2:
	return last_safe_position
