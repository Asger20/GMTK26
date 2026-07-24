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

# Overlays
@onready var monsterpedia_overlay: Panel = $MonsterpediaOverlay
@onready var dev_cheat_overlay: Panel = $DevCheatOverlay
@onready var dev_cheat_btn: Button = $DevCheatBtn

# Speed Date Timer State
var time_remaining: float = 180.0
var is_date_timer_running: bool = false
var active_dialogue_balloon: Node = null

func _ready() -> void:
	# Connect Phase Buttons
	start_date_btn.pressed.connect(_on_start_date_pressed)
	debug_finish_date_btn.pressed.connect(_on_date_completed)
	next_day_btn.pressed.connect(_on_next_day_pressed)
	submit_decision_btn.pressed.connect(_on_submit_decision_pressed)
	play_again_btn.pressed.connect(_on_play_again_pressed)
	mission_briefing_btn.pressed.connect(_show_intro_phase)

	# Connect Overlay Buttons
	if monsterpedia_book_btn and monsterpedia_overlay:
		monsterpedia_book_btn.pressed.connect(func(): monsterpedia_overlay.toggle_window())
	
	if dev_cheat_btn and dev_cheat_overlay:
		dev_cheat_btn.pressed.connect(func(): dev_cheat_overlay.toggle_window())
		dev_cheat_overlay.jump_date_requested.connect(_on_cheat_jump_date)
		dev_cheat_overlay.jump_day_requested.connect(_on_cheat_jump_day)
		dev_cheat_overlay.reset_session_requested.connect(func(): _start_new_game_session(); dev_cheat_overlay.refresh_info())
		dev_cheat_overlay.unlock_clues_requested.connect(_on_cheat_unlock_clues)
		dev_cheat_overlay.finish_date_requested.connect(_on_date_completed)

	# Connect GameManager Signals
	GameManager.affection_changed.connect(_on_affection_changed)
	GameManager.date_completed.connect(func(_id): _on_date_completed())
	GameManager.dev_mode_toggled.connect(func(enabled: bool):
		if affection_container: affection_container.visible = enabled
		if dev_cheat_btn: dev_cheat_btn.visible = enabled and (intro_panel and not intro_panel.visible)
		if not enabled and dev_cheat_overlay: dev_cheat_overlay.visible = false
	)

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

	header_bar.visible = (target_panel != intro_panel and target_panel != date_panel)
	
	if monsterpedia_book_btn:
		monsterpedia_book_btn.visible = (target_panel != intro_panel and target_panel != ending_panel)
	
	if dev_cheat_btn:
		dev_cheat_btn.visible = GameManager.dev_mode_show_affection and (target_panel != intro_panel and target_panel != ending_panel)

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
	phase_label.text = "PHASE: SPEED DATE"

	var monster = GameManager.get_current_date_monster()
	if monster:
		monster_name_label.text = monster.display_name
		monster_species_label.text = "Species: " + monster.species
		if monster.portrait_texture:
			portrait_rect.texture = monster.portrait_texture
		_update_affection_ui(GameManager.get_affection(monster.id))

	time_remaining = 180.0
	is_date_timer_running = true

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
	if is_instance_valid(active_dialogue_balloon):
		active_dialogue_balloon.queue_free()
	_show_break_phase()

# --- PHASE 3: BREAK PHASE ---
func _show_break_phase() -> void:
	_show_panel(break_panel)
	day_label.text = "DAY %d OF 5" % GameManager.current_day
	phase_label.text = "PHASE: END OF DAY BREAK"

	var monster = GameManager.get_current_date_monster()
	var monster_name = monster.display_name if monster else "Candidate"
	
	break_title.text = "DAY %d COMPLETE - REFLECTION" % GameManager.current_day
	var summary = "[b]Date Reflection Summary:[/b]\n"
	summary += "You completed your date with [b]" + monster_name + "[/b].\n"
	summary += "Current Affection Score: [b]%d%%[/b]\n\n" % [GameManager.get_affection(monster.id) if monster else 0]
	summary += "Use your [color=#e6b800]Monsterpedia[/color] to review any clues recorded today before advancing."
	break_summary.text = summary

func _on_next_day_pressed() -> void:
	GameManager.advance_to_next_day()
	if GameManager.current_day > 4:
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
	match_dropdown.add_item("Nobody (Single)", 0)

	for candidate in GameManager.selected_candidates:
		accuse_dropdown.add_item("%s (%s)" % [candidate.display_name, candidate.species])
		accuse_dropdown.set_item_metadata(accuse_dropdown.get_item_count() - 1, candidate.id)

		var aff = GameManager.get_affection(candidate.id)
		if aff >= candidate.min_affection_for_match:
			match_dropdown.add_item("%s (%s) [Affection: %d%%]" % [candidate.display_name, candidate.species, aff])
			match_dropdown.set_item_metadata(match_dropdown.get_item_count() - 1, candidate.id)

func _on_submit_decision_pressed() -> void:
	var accuse_idx = accuse_dropdown.selected
	var match_idx = match_dropdown.selected

	if accuse_idx >= 0:
		GameManager.selected_accusation_id = accuse_dropdown.get_item_metadata(accuse_idx)

	if match_idx > 0:
		GameManager.selected_match_id = match_dropdown.get_item_metadata(match_idx)
	else:
		GameManager.selected_match_id = ""

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

# --- DEV CHEATS HANDLERS ---
func _on_cheat_jump_date(target_id: String) -> void:
	var monster_res: MonsterData = load("res://resources/monsters/%s.tres" % target_id)
	if not monster_res: return
	var candidate_idx = -1
	for i in range(GameManager.selected_candidates.size()):
		if GameManager.selected_candidates[i].id == target_id:
			candidate_idx = i
			break
	if candidate_idx >= 0:
		GameManager.current_date_index = candidate_idx
	else:
		GameManager.selected_candidates.append(monster_res)
		GameManager.current_date_index = GameManager.selected_candidates.size() - 1
	_show_date_phase()

func _on_cheat_jump_day(day_num: int) -> void:
	if day_num == 5:
		_show_accusation_phase()
	else:
		GameManager.current_day = day_num
		GameManager.current_date_index = day_num - 1
		_show_prep_phase()

func _on_cheat_unlock_clues() -> void:
	var current_monster = GameManager.get_current_date_monster()
	if current_monster:
		GameManager.record_clue(current_monster.id, "dev_clue_1", "Dev test clue recorded for " + current_monster.display_name)
