extends Control

@onready var accusation_option_button: OptionButton = $Panel/VBoxContainer/AccusationContainer/AccusationOptionButton
@onready var match_option_button: OptionButton = $Panel/VBoxContainer/MatchContainer/MatchOptionButton
@onready var confirm_button: Button = $Panel/VBoxContainer/ConfirmButton
@onready var ending_result_panel: Panel = $EndingResultPanel
@onready var ending_title_label: Label = $EndingResultPanel/VBoxContainer/EndingTitleLabel
@onready var ending_description_label: RichTextLabel = $EndingResultPanel/VBoxContainer/EndingDescriptionLabel

var candidate_id_map: Array[String] = []

func _ready() -> void:
	ending_result_panel.visible = false
	_populate_candidate_dropdowns()
	confirm_button.pressed.connect(_on_confirm_pressed)

func _populate_candidate_dropdowns() -> void:
	accusation_option_button.clear()
	match_option_button.clear()
	candidate_id_map.clear()

	# Add "Nobody" option for match
	match_option_button.add_item("Nobody (Single)")

	for candidate in GameManager.selected_candidates:
		var display = "%s (%s)" % [candidate.display_name, candidate.species]
		accusation_option_button.add_item(display)

		# Check affection threshold for match eligibility
		var affection = GameManager.get_affection(candidate.id)
		var match_display = "%s - Affection %d%% (Req: %d%%)" % [candidate.display_name, affection, candidate.min_affection_for_match]
		if affection < candidate.min_affection_for_match:
			match_display += " [LOCKED]"
		match_option_button.add_item(match_display)
		candidate_id_map.append(candidate.id)

func _on_confirm_pressed() -> void:
	var accusation_idx = accusation_option_button.selected
	if accusation_idx >= 0 and accusation_idx < candidate_id_map.size():
		GameManager.selected_accusation_id = candidate_id_map[accusation_idx]

	var match_idx = match_option_button.selected
	if match_idx == 0:
		GameManager.selected_match_id = "nobody"
	elif match_idx > 0 and (match_idx - 1) < candidate_id_map.size():
		GameManager.selected_match_id = candidate_id_map[match_idx - 1]

	var ending = GameManager.evaluate_ending()
	_show_ending_screen(ending)

func _show_ending_screen(ending: GameManager.EndingType) -> void:
	ending_result_panel.visible = true
	var title = ""
	var desc = ""

	match ending:
		GameManager.EndingType.BAD_ENDING:
			title = "❌ BAD ENDING: THE COUNT ESCAPES"
			desc = "You accused an innocent monster! The Count slipped through the asylum gates undetected and vanished into society. You remain alone and empty-handed."

		GameManager.EndingType.MIXED_ENDING:
			title = "💔 MIXED ENDING: BLIND LOVE"
			desc = "You accused the wrong suspect and The Count escaped! However, you built a strong bond with your monster date and left together to start a new life."

		GameManager.EndingType.GOOD_ENDING:
			title = "🔎 GOOD ENDING: JUSTICE SERVED"
			desc = "Spotting the subtle lore inconsistencies, you correctly identified and arrested The Count! The asylum is safe, and your detective career reaches new heights."

		GameManager.EndingType.BEST_ENDING:
			title = "💖 BEST ENDING: LOVE & JUSTICE"
			desc = "You caught the shapeshifter imposter and saved the world, PLUS you won the heart of your monster date! True love and detective glory!"

		GameManager.EndingType.SECRET_ENDING_1:
			title = "🤫 SECRET ENDING 1: VILLAIN ROMANCE"
			desc = "You exposed The Count as the shapeshifter... and then confessed your love! The Count fell for your charm, agreed to hand themselves in, and promises to wait for you."

		GameManager.EndingType.SECRET_ENDING_2:
			title = "😈 SECRET ENDING 2: BONNIE & CLYDE"
			desc = "You deliberately framed an innocent monster so you could escape WITH The Count! Together, you slip into the night as the most notorious monster power-couple in history!"

	ending_title_label.text = title
	ending_description_label.text = desc
