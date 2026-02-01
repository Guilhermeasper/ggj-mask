extends Node2D

@onready var level_1_scene = preload("res://levels/level_1/level_1.tscn")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		get_tree().change_scene_to_packed(level_1_scene)
