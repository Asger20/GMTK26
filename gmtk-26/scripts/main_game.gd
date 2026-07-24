extends Control

# UI Panels
@onready var background_rect: ColorRect = $Background
@onready var header_bar: Panel = $HeaderBar
@onready var day_label: Label = $HeaderBar/HBox/DayLabel
@onready var phase_label: Label = $HeaderBar/HBox/PhaseLabel
@onready var mission_briefing_btn: Button = $HeaderBar/HBox/MissionBriefingButton
@onready var monsterpedia_book_btn: Button = $MonsterpediaBookBtn


# Phase 0: Intro Cutscene Panel
@onready var intro_panel: Panel = $IntroPanel
@onready var paper_panel: Panel = $IntroPanel/PaperPanel
@onready var intro_story_text: RichTextLabel = $IntroPanel/PaperPanel/StoryContainer/StoryText
@onready var intro_skip_prompt: Label = $IntroPanel/SkipPrompt

var intro_tween: Tween


# Phase 1: Prep Panel
@onready var prep_panel: Panel = $PrepPanel
@onready var prep_title_label: Label = $PrepPanel/VBox/TitleLabel
@onready var candidate_card_name: Label = $PrepPanel/VBox/CandidateCard/CandidateName
@onready var candidate_card_species: Label = $PrepPanel/VBox/CandidateCard/CandidateSpecies
@onready var candidate_card_desc: RichTextLabel = $PrepPanel/VBox/CandidateCard/CandidateDesc
@onready var start_date_btn: Button = $PrepPanel/VBox/StartDateButton


# Phase 2: Date Panel
@onready var date_panel: Panel = $DatePanel
@onready var timer_label: Label = $DatePanel/TopHUD/TimerContainer/TimerLabel
@onready var monster_name_label: Label = $DatePanel/TopHUD/MonsterInfo/MonsterName
@onready var monster_species_label: Label = $DatePanel/TopHUD/MonsterInfo/MonsterSpecies
@onready var affection_container: VBoxContainer = $DatePanel/TopHUD/AffectionContainer
@onready var affection_bar: ProgressBar = $DatePanel/TopHUD/AffectionContainer/AffectionBar
@onready var affection_val_label: Label = $DatePanel/TopHUD/AffectionContainer/AffectionVal

@onready var portrait_rect: TextureRect = $DatePanel/MonsterPortrait
@onready var debug_finish_date_btn: Button = $DatePanel/TopHUD/DebugFinishButton

# Phase 3: Break Panel
@onready var break_panel: Panel = $BreakPanel
@onready var break_title: Label = $BreakPanel/VBox/TitleLabel
@onready var break_summary: RichTextLabel = $BreakPanel/VBox/SummaryText
@onready var next_day_btn: Button = $BreakPanel/VBox/NextDayButton

# Phase 4: Accusation Panel
@onready var accusation_panel: Panel = $AccusationPanel
@onready var accuse_dropdown: OptionButton = $AccusationPanel/VBox/AccuseContainer/AccuseDropdown
@onready var match_dropdown: OptionButton = $AccusationPanel/VBox/MatchContainer/MatchDropdown
@onready var submit_decision_btn: Button = $AccusationPanel/VBox/SubmitButton

# Phase 5: Ending Panel
@onready var ending_panel: Panel = $EndingPanel
@onready var ending_title: Label = $EndingPanel/VBox/EndingTitle
@onready var ending_desc: RichTextLabel = $EndingPanel/VBox/EndingDesc
@onready var play_again_btn: Button = $EndingPanel/VBox/PlayAgainButton

# Overlay: Monsterpedia Window
@onready var monsterpedia_window: Panel = $MonsterpediaOverlay
@onready var monsterpedia_species_dropdown: OptionButton = $MonsterpediaOverlay/VBox/TabContainer/SpeciesLore/SpeciesDropdown
@onready var monsterpedia_lore_label: RichTextLabel = $MonsterpediaOverlay/VBox/TabContainer/SpeciesLore/LoreLabel
@onready var monsterpedia_clue_container: VBoxContainer = $MonsterpediaOverlay/VBox/TabContainer/EvidenceNotebook/Scroll/ClueContainer
@onready var monsterpedia_close_btn: Button = $MonsterpediaOverlay/VBox/Header/CloseButton

# Speed Date Timer State
var time_remaining: float = 180.0
var is_date_timer_running: bool = false
var active_dialogue_balloon: Node = null

var species_lore_db: Dictionary = {
	"Zombie": [
		"• Prefers cold, rotting food and decaying meals.",
		"• Severe sunlight aversion: UV rays degrade flesh instantly.",
		"• Thrives in dark, underground, or freezing environments."
	],
	"Vampire": [
		"• Extremely particular about blood vintage and temperature.",
		"• Strictly nocturnal; sleep phase spans sunrise to sunset.",
		"• Cannot tolerate silver, garlic, or sacred geometry."
	],
	"Slime": [
		"• Requires high humidity, damp mud, or swamp environments.",
		"• Naturally stores personal items, keys, and snacks inside body cavity.",
		"• Absorbs liquids to alter coloration and density."
	],
	"Angel": [
		"• Driven by absolute symmetry, mathematical order, and divine geometry.",
		"• Finds chaos, messiness, or asymmetrical rooms deeply uncomfortable.",
		"• Communicates in resonant multi-harmonic frequencies."
	],
	"Sea Monster": [
		"• Deeply knowledgeable about oceanic pressure, abyssal trenches, and saltwater.",
		"• Cannot remain in dry, arid, or desert climates without desiccating.",
		"• Communicates via low-frequency echolocation sonar."
	],
	"Bug Monster": [
		"• Nocturnal weaver; calculates web tension vectors and light source angles.",
		"• Stays awake multi-day stretches with hyper-vigilant nervous system.",
		"• Extremely sensitive to air vibration and water droplet weight on silk."
	]
}

func _ready() -> void:
	# Connect Button Signals
	start_date_btn.pressed.connect(_on_start_date_pressed)
	debug_finish_date_btn.pressed.connect(_on_date_completed)
	next_day_btn.pressed.connect(_on_next_day_pressed)
	submit_decision_btn.pressed.connect(_on_submit_decision_pressed)
	play_again_btn.pressed.connect(_on_play_again_pressed)
	mission_briefing_btn.pressed.connect(_show_intro_phase)
	monsterpedia_book_btn.pressed.connect(_toggle_monsterpedia)
	monsterpedia_close_btn.pressed.connect(_toggle_monsterpedia)
	monsterpedia_species_dropdown.item_selected.connect(_on_monsterpedia_species_selected)


	# Connect GameManager Signals
	GameManager.affection_changed.connect(_on_affection_changed)
	GameManager.clue_recorded.connect(_on_clue_recorded)
	GameManager.date_completed.connect(func(_id): _on_date_completed())
	GameManager.dev_mode_toggled.connect(func(enabled: bool):
		if affection_container:
			affection_container.visible = enabled
	)

	_setup_monsterpedia_dropdown()
	_start_new_game_session()


func _process(delta: float) -> void:
	if is_date_timer_running:
		time_remaining -= delta
		if time_remaining <= 0.0:
			time_remaining = 0.0
			is_date_timer_running = false
			_on_date_completed()
		_update_timer_display()

func _input(event: InputEvent) -> void:
	if intro_panel and intro_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode != KEY_F10:
				_skip_intro()


func _start_new_game_session() -> void:
	# Load candidate resources for all 6 monsters
	var m_zombie = load("res://resources/monsters/zombie.tres")
	var m_vampire = load("res://resources/monsters/vampire.tres")
	var m_slime = load("res://resources/monsters/slime.tres")
	var m_angel = load("res://resources/monsters/angel.tres")
	var m_sea_monster = load("res://resources/monsters/sea_monster.tres")
	var m_bug_monster = load("res://resources/monsters/bug_monster.tres")

	var pool: Array[MonsterData] = []
	if m_zombie: pool.append(m_zombie)
	if m_vampire: pool.append(m_vampire)
	if m_slime: pool.append(m_slime)
	if m_angel: pool.append(m_angel)
	if m_sea_monster: pool.append(m_sea_monster)
	if m_bug_monster: pool.append(m_bug_monster)

	GameManager.start_new_game(pool)
	_show_intro_phase()


func _show_panel(target_panel: Panel) -> void:
	intro_panel.visible = (target_panel == intro_panel)
	prep_panel.visible = (target_panel == prep_panel)
	date_panel.visible = (target_panel == date_panel)
	break_panel.visible = (target_panel == break_panel)
	accusation_panel.visible = (target_panel == accusation_panel)
	ending_panel.visible = (target_panel == ending_panel)

	# Hide header bar during intro cutscene and during active speed dates
	header_bar.visible = (target_panel != intro_panel and target_panel != date_panel)

	# Hide monsterpedia book button during intro cutscene and final ending
	if monsterpedia_book_btn:
		monsterpedia_book_btn.visible = (target_panel != intro_panel and target_panel != ending_panel)


# --- PHASE 0: INTRO CUTSCENE ---
func _show_intro_phase() -> void:
	_show_panel(intro_panel)

	var b_text = "[center][b][font_size=20][color=#7a1c1c]CASE FILE: OPERATION COUNTDOWN[/color][/font_size][/b]\n"
	b_text += "[font_size=13][color=#4a3b2c]BLACKWOOD HIGH-SECURITY MONSTER ASYLUM[/color][/font_size][/center]\n\n"
	b_text += "[b][color=#2c2214]SITUATION:[/color][/b] Four rehabilitated monsters were scheduled to be released into society in [color=#7a1c1c]five days[/color]. But last night, the asylum discovered a nightmare: the dangerous shapeshifter known as [color=#aa1818]'The Count'[/color] killed one of the patients and took their place in order to break out.\n\n"
	b_text += "[b][color=#2c2214]THE COVER-UP:[/color][/b] To catch the killer before release day without causing a public panic, the police and asylum set up a fake [color=#7a5800]speed-dating experiment[/color] to test if candidates would integrate better into society with a romantic partner.\n\n"
	b_text += "[b][color=#2c2214]YOUR MISSION:[/color][/b] Go undercover as an eligible date candidate. Armed with your trusty [color=#7a5800]Monsterpedia[/color] book, talk to each candidate, check their answers against true monster lore, and catch The Count before the [color=#7a1c1c]five days[/color] are up.\n\n"
	b_text += "[color=#5c4933](Hey, and who knows? Amidst the detective work, you might just find true love along the way.)[/color]"


	intro_story_text.text = b_text

	if intro_tween and intro_tween.is_running():
		intro_tween.kill()

	var target_y = paper_panel.position.y
	paper_panel.position.y = target_y - 250.0
	paper_panel.modulate.a = 0.0

	intro_tween = create_tween()
	intro_tween.tween_property(paper_panel, "position:y", target_y, 2.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro_tween.parallel().tween_property(paper_panel, "modulate:a", 1.0, 1.5)


func _skip_intro() -> void:
	if intro_tween and intro_tween.is_running():
		intro_tween.kill()
	_show_prep_phase()


# --- PHASE 1: PREP PHASE ---
func _show_prep_phase() -> void:
	_show_panel(prep_panel)
	day_label.text = "DAY %d OF 5" % GameManager.current_day
	phase_label.text = "PHASE: PREPARATION"

	var current_monster = GameManager.get_current_date_monster()
	if current_monster:
		candidate_card_name.text = "Candidate: " + current_monster.display_name
		candidate_card_species.text = "Species: " + current_monster.species

		var txt = "[b]Rehab Profile:[/b]\n"
		txt += "Cleared for speed dating trial. Click your [color=#e6b800]📖 MONSTERPEDIA BOOK[/color] at the bottom-left to review species lore before entering your date!"
		candidate_card_desc.text = txt
	else:
		candidate_card_name.text = "No Candidate"
		candidate_card_species.text = ""
		candidate_card_desc.text = ""


func _on_start_date_pressed() -> void:
	_show_date_phase()

# --- PHASE 2: SPEED DATE PHASE ---
func _show_date_phase() -> void:
	_show_panel(date_panel)
	day_label.text = "DAY %d OF 5" % GameManager.current_day
	phase_label.text = "PHASE: 3-MIN SPEED DATE"

	var monster = GameManager.get_current_date_monster()
	if monster:
		monster_name_label.text = monster.display_name
		monster_species_label.text = "Species: " + monster.species
		if monster.portrait_texture:
			portrait_rect.texture = monster.portrait_texture
		_update_affection_ui(GameManager.get_affection(monster.id))

	time_remaining = 180.0
	is_date_timer_running = true

	# Start Dialogue Manager Balloon
	if monster and monster.dialogue_resource:
		active_dialogue_balloon = DialogueManager.show_dialogue_balloon(monster.dialogue_resource, "start")
	else:
		var fallback_res = load("res://assets/dialogues/sample_monster.dialogue")
		if fallback_res:
			active_dialogue_balloon = DialogueManager.show_dialogue_balloon(fallback_res, "start")

func _update_timer_display() -> void:
	var mins = int(time_remaining) / 60
	var secs = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

func _update_affection_ui(score: int) -> void:
	affection_bar.value = score
	affection_val_label.text = str(score) + "%"
	if affection_container:
		affection_container.visible = GameManager.dev_mode_show_affection


func _on_affection_changed(candidate_id: String, new_score: int) -> void:
	var current_monster = GameManager.get_current_date_monster()
	if current_monster and current_monster.id == candidate_id:
		_update_affection_ui(new_score)

func _on_date_completed() -> void:
	is_date_timer_running = false
	print("[MainGame] Date Completed for Day ", GameManager.current_day)

	# Close active dialogue balloon if present
	if active_dialogue_balloon and is_instance_valid(active_dialogue_balloon):
		active_dialogue_balloon.queue_free()

	_show_break_phase()

# --- PHASE 3: BREAK PHASE ---
func _show_break_phase() -> void:
	_show_panel(break_panel)
	day_label.text = "DAY %d COMPLETED" % GameManager.current_day
	phase_label.text = "PHASE: BREAK / REFLECTION"

	var monster = GameManager.get_current_date_monster()
	var monster_name = monster.display_name if monster else "Candidate"
	var aff = GameManager.get_affection(monster.id) if monster else 0

	var summary = "[b]Date Summary - Day %d[/b]\n\n" % GameManager.current_day
	summary += "• Candidate: %s\n" % monster_name
	summary += "• Final Affection: %d%%\n" % aff
	summary += "• Total Evidence Clues Discovered: %d\n\n" % GameManager.discovered_clues.size()
	summary += "Take a moment to check your Monsterpedia and Evidence Notebook before continuing."
	break_summary.text = summary

func _on_next_day_pressed() -> void:
	GameManager.advance_to_next_day()
	if GameManager.current_day > 4 or GameManager.current_date_index >= GameManager.selected_candidates.size():
		_show_accusation_phase()
	else:
		_show_prep_phase()

# --- PHASE 4: ACCUSATION & MATCHING PHASE ---
func _show_accusation_phase() -> void:
	_show_panel(accusation_panel)
	day_label.text = "DAY 5 OF 5"
	phase_label.text = "PHASE: ACCUSATION & MATCHING"

	accuse_dropdown.clear()
	match_dropdown.clear()

	match_dropdown.add_item("Nobody (Remain Single)")

	for candidate in GameManager.selected_candidates:
		var display = "%s (%s)" % [candidate.display_name, candidate.species]
		accuse_dropdown.add_item(display)

		var aff = GameManager.get_affection(candidate.id)
		var match_txt = "%s - Affection %d%% (Req: %d%%)" % [candidate.display_name, aff, candidate.min_affection_for_match]
		if aff < candidate.min_affection_for_match:
			match_txt += " [LOCKED]"
		match_dropdown.add_item(match_txt)

func _on_submit_decision_pressed() -> void:
	var acc_idx = accuse_dropdown.selected
	if acc_idx >= 0 and acc_idx < GameManager.selected_candidates.size():
		GameManager.selected_accusation_id = GameManager.selected_candidates[acc_idx].id

	var match_idx = match_dropdown.selected
	if match_idx == 0:
		GameManager.selected_match_id = "nobody"
	elif match_idx > 0 and (match_idx - 1) < GameManager.selected_candidates.size():
		GameManager.selected_match_id = GameManager.selected_candidates[match_idx - 1].id

	var ending = GameManager.evaluate_ending()
	_show_ending_phase(ending)

# --- PHASE 5: ENDING PHASE ---
func _show_ending_phase(ending: GameManager.EndingType) -> void:
	_show_panel(ending_panel)
	day_label.text = "GAME OVER"
	phase_label.text = "PHASE: FINAL ENDING"

	var title = ""
	var desc = ""

	match ending:
		GameManager.EndingType.BAD_ENDING:
			title = "❌ BAD ENDING: THE COUNT ESCAPES"
			desc = "You accused an innocent monster! The Count slipped through the asylum gates undetected on Day 5 and vanished into society. You remain alone and empty-handed."
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

	ending_title.text = title
	ending_desc.text = desc

func _on_play_again_pressed() -> void:
	_start_new_game_session()

# --- OVERLAY: MONSTERPEDIA & EVIDENCE NOTEBOOK ---
func _toggle_monsterpedia() -> void:
	monsterpedia_window.visible = not monsterpedia_window.visible
	if monsterpedia_window.visible:
		_update_clue_notebook_display()

func _setup_monsterpedia_dropdown() -> void:
	monsterpedia_species_dropdown.clear()
	for s_name in species_lore_db.keys():
		monsterpedia_species_dropdown.add_item(s_name)
	_on_monsterpedia_species_selected(0)

func _on_monsterpedia_species_selected(index: int) -> void:
	var s_name = monsterpedia_species_dropdown.get_item_text(index)
	var lines = species_lore_db.get(s_name, [])
	var txt = "[b]" + s_name.to_upper() + " SPECIES LORE[/b]\n\n"
	for line in lines:
		txt += line + "\n"
	monsterpedia_lore_label.text = txt

func _update_clue_notebook_display() -> void:
	for child in monsterpedia_clue_container.get_children():
		child.queue_free()

	if GameManager.discovered_clues.size() == 0:
		var lbl = Label.new()
		lbl.text = "No evidence clues recorded yet."
		monsterpedia_clue_container.add_child(lbl)
		return

	for clue in GameManager.discovered_clues:
		var lbl = Label.new()
		lbl.text = "[Day %d] Candidate '%s': %s" % [clue.get("day_found", 1), clue.get("candidate_id", ""), clue.get("text", "")]
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		monsterpedia_clue_container.add_child(lbl)

func _on_clue_recorded(_c_id, _clue_id, _text) -> void:
	_update_clue_notebook_display()
