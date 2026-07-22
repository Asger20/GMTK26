extends Node2D


func _init() -> void:
	print("Hello")
	var resource = load("res://assets/Sample.dialogue")
	DialogueManager.show_dialogue_balloon(resource, "start")
