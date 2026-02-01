extends CanvasLayer

@onready var background_color = $BackgroundColor


func change_color(color: Color) -> void:
	background_color.color = color
