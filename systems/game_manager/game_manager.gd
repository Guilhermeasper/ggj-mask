extends Node

var last_safe_position: Vector2 = Vector2.ZERO
var current_level: int = 1
var levels: Dictionary = {
	1: "res://levels/level_1/level_1.tscn",
	2: "res://levels/level_2/level_2.tscn",
	3: "res://levels/level_3/level_3.tscn",
}

var masks: Dictionary = {
	"white": preload("res://resources/masks/white_mask.tres"),
	"yellow": preload("res://resources/masks/yellow_mask.tres"),
	"red": preload("res://resources/masks/red_mask.tres"),
	"blue": preload("res://resources/masks/blue_mask.tres"),
}

var current_mask: MaskData = masks["white"]
var current_mask_id = 0

var available_masks: Array[MaskData] = [masks["white"]]


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
