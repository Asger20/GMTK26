class_name MonsterData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var species: String = ""
@export var portrait_texture: Texture2D
@export var portrait_scale: Vector2 = Vector2(1.0, 1.0)
@export var portrait_y_offset: float = 0.0
@export var expression_y_offsets: Dictionary = {} # e.g. "scary": 45.0 (relative Y offset)
@export var expressions: Dictionary = {} # e.g. "normal", "happy", "blush", "angry", "scary" -> Texture2D
@export var dialogue_resource: Resource # DialogueResource from dialogue_manager
@export var dialogue_voice: Resource
@export_multiline var species_lore: Array[String] = []
@export var min_affection_for_match: int = 80

func get_expression_texture(expr_name: String) -> Texture2D:
	if expressions.has(expr_name) and expressions[expr_name] is Texture2D:
		return expressions[expr_name]
	return portrait_texture

func get_expression_y_offset(expr_name: String) -> float:
	if expression_y_offsets.has(expr_name):
		return portrait_y_offset + float(expression_y_offsets[expr_name])
	return portrait_y_offset
