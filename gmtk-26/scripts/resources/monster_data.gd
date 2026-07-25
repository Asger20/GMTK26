class_name MonsterData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var species: String = ""
@export var portrait_texture: Texture2D
@export var expressions: Dictionary = {} # e.g. "normal", "happy", "blush", "angry", "scary" -> Texture2D
@export var dialogue_resource: Resource # DialogueResource from dialogue_manager
@export_multiline var species_lore: Array[String] = []
@export var min_affection_for_match: int = 80

func get_expression_texture(expr_name: String) -> Texture2D:
	if expressions.has(expr_name) and expressions[expr_name] is Texture2D:
		return expressions[expr_name]
	return portrait_texture
