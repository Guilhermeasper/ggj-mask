extends Resource

class_name MaskData

@export_group("Identidade")
@export var mask_name: String = "Mascara Branca"
@export var color: Color = Color.WHITE
@export var icon: Texture2D

@export_group("Player Modifiers")
@export var move_speed_multiplier: float = 1.0
@export var jump_force_multiplier: float = 1.0
@export var can_double_jump: bool = false
@export var can_attack: bool = false
@export var can_parry: bool = false

@export_group("Physics")
@export var target_collision_layer: int = 0

@export_group("World & Enemy Modifiers")
@export var enemy_aggro_range_multiplier: float = 1.0
@export var enemy_damage_multiplier: float = 1.0
@export var enemies_are_aggressive: bool = false
