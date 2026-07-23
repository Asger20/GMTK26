class_name MonsterData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var species: String = ""
@export var portrait_texture: Texture2D
@export var dialogue_resource: Resource # DialogueResource from dialogue_manager
@export_multiline var species_lore: Array[String] = []
@export var min_affection_for_match: int = 50
