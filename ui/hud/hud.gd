extends CanvasLayer

@onready var yellow_mask = %yellow_mask_ui
@onready var red_mask = %red_mask_ui
@onready var blue_mask = %blue_mask_ui


func _ready() -> void:
	yellow_mask.hide()
	red_mask.hide()
	blue_mask.hide()
	yellow_mask.modulate = Color(1, 1, 1, 0.5)
	red_mask.modulate = Color(1, 1, 1, 0.5)
	blue_mask.modulate = Color(1, 1, 1, 0.5)


func show_mask(mask_color: String) -> void:
	match mask_color:
		"yellow":
			yellow_mask.show()
		"red":
			red_mask.show()
		"blue":
			blue_mask.show()


func select_mask(mask_color: String) -> void:
	match mask_color:
		"yellow":
			yellow_mask.modulate = Color(1, 1, 1, 1)
			red_mask.modulate = Color(1, 1, 1, 0.5)
			blue_mask.modulate = Color(1, 1, 1, 0.5)
		"red":
			yellow_mask.modulate = Color(1, 1, 1, 0.5)
			red_mask.modulate = Color(1, 1, 1, 1)
			blue_mask.modulate = Color(1, 1, 1, 0.5)
		"blue":
			yellow_mask.modulate = Color(1, 1, 1, 0.5)
			red_mask.modulate = Color(1, 1, 1, 0.5)
			blue_mask.modulate = Color(1, 1, 1, 1)
		"white":
			yellow_mask.modulate = Color(1, 1, 1, 0.5)
			red_mask.modulate = Color(1, 1, 1, 0.5)
			blue_mask.modulate = Color(1, 1, 1, 0.5)
