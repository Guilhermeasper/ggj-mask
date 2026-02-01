extends CanvasLayer

@onready var background_color = $BackgroundColor
@onready var background_textures = {
	"white": $backgrounds/base,
	"yellow": $backgrounds/yellow,
	"red": $backgrounds/red,
	"blue": $backgrounds/blue,
}


func _ready() -> void:
	for texture in background_textures.values():
		texture.visible = false


func change_color(color: String) -> void:
	for texture in background_textures.values():
		texture.visible = false
	background_textures[color].visible = true
