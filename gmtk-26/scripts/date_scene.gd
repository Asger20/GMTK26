extends Node2D

@export var date_time_limit: float = 180.0 # 3 minutes (180s)
@export var current_monster_data: MonsterData

@onready var timer_label: Label = $CanvasLayer/HUD/TimerContainer/TimerLabel
@onready var name_label: Label = $CanvasLayer/HUD/MonsterInfo/NameLabel
@onready var species_label: Label = $CanvasLayer/HUD/MonsterInfo/SpeciesLabel
@onready var affection_bar: ProgressBar = $CanvasLayer/HUD/AffectionContainer/AffectionBar
@onready var affection_value_label: Label = $CanvasLayer/HUD/AffectionContainer/AffectionValueLabel
@onready var monster_portrait: TextureRect = $CanvasLayer/MonsterPortrait
@onready var monsterpedia_panel: Control = $CanvasLayer/MonsterpediaUI

var time_remaining: float = 180.0
var is_timer_running: bool = false

func _ready() -> void:
	# If no monster_data provided, load current date monster from GameManager
	if not current_monster_data:
		current_monster_data = GameManager.get_current_date_monster()

	time_remaining = date_time_limit
	is_timer_running = true

	# Connect GameManager signals
	GameManager.affection_changed.connect(_on_affection_changed)

	_setup_ui()
	_start_dialogue()

func _process(delta: float) -> void:
	if is_timer_running:
		time_remaining -= delta
		if time_remaining <= 0.0:
			time_remaining = 0.0
			is_timer_running = false
			_on_timer_expired()
		_update_timer_display()

func _setup_ui() -> void:
	if current_monster_data:
		name_label.text = current_monster_data.display_name
		species_label.text = "Species: " + current_monster_data.species
		if current_monster_data.portrait_texture:
			monster_portrait.texture = current_monster_data.portrait_texture

		var affection = GameManager.get_affection(current_monster_data.id)
		_update_affection_display(affection)
	else:
		name_label.text = "Unknown Monster"
		species_label.text = "Species: Unknown"

func _update_timer_display() -> void:
	var minutes: int = int(time_remaining) / 60
	var seconds: int = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _update_affection_display(score: int) -> void:
	affection_bar.value = score
	affection_value_label.text = str(score) + "%"

func _on_affection_changed(candidate_id: String, new_score: int) -> void:
	if current_monster_data and candidate_id == current_monster_data.id:
		_update_affection_display(new_score)

func _start_dialogue() -> void:
	if current_monster_data and current_monster_data.dialogue_resource:
		DialogueManager.show_dialogue_balloon(current_monster_data.dialogue_resource, "start")
	else:
		# Fallback if no specific dialogue resource set
		var sample_res = load("res://assets/dialogues/sample_monster.dialogue")
		if sample_res:
			DialogueManager.show_dialogue_balloon(sample_res, "start")

func _on_timer_expired() -> void:
	print("[DateScene] 3-Minute Date Timer Expired!")
	# Trigger date completion in GameManager
	if current_monster_data:
		GameManager.complete_current_date()

func _on_toggle_monsterpedia_pressed() -> void:
	monsterpedia_panel.visible = not monsterpedia_panel.visible
