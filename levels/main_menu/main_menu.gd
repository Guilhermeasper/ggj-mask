extends Node2D

@onready var button = $Button
@onready var level_1_scene = preload("res://levels/level_1/level_1.tscn")

func _ready():
	button.pressed.connect(_button_pressed)

func _button_pressed():
	get_tree().change_scene_to_packed(level_1_scene)
