extends Control

# UI Panels
@onready var background_rect: ColorRect = $Background
@onready var header_bar: Panel = $HeaderBar
@onready var day_label: Label = $HeaderBar/HBox/DayLabel
@onready var phase_label: Label = $HeaderBar/HBox/PhaseLabel
@onready var mission_briefing_btn: Button = $HeaderBar/HBox/MissionBriefingButton
@onready var monsterpedia_book_btn: TextureButton = $MonsterpediaBookBtn


# Phase 0: Intro Cutscene Panel
@onready var intro_panel: Panel = $IntroPanel
@onready var paper_panel: Panel = $IntroPanel/PaperPanel
@onready var intro_story_text: RichTextLabel = $IntroPanel/PaperPanel/StoryContainer/StoryText
@onready var intro_skip_prompt: Label = $IntroPanel/SkipPrompt

var intro_tween: Tween
var is_first_intro_transition: bool = true

# Phase 1: Prep Panel
@onready var prep_panel: Panel = $PrepPanel
@onready var prep_title_label: Label = $PrepPanel/VBox/TitleLabel
@onready var candidate_card_name: Label = $PrepPanel/VBox/CandidateCard/CandidateName
@onready var candidate_card_species: Label = $PrepPanel/VBox/CandidateCard/CandidateSpecies
@onready var candidate_card_desc: RichTextLabel = $PrepPanel/VBox/CandidateCard/CandidateDesc
@onready var start_date_btn: Button = $PrepPanel/VBox/StartDateButton

# Phase 2: Date Panel
@onready var date_panel: Panel = $DatePanel
@onready var affection_container: VBoxContainer = $DatePanel/TopHUD/AffectionContainer
@onready var affection_bar: ProgressBar = $DatePanel/TopHUD/AffectionContainer/AffectionBar
@onready var affection_val_label: Label = $DatePanel/TopHUD/AffectionContainer/AffectionVal
@onready var portrait_rect: TextureRect = $DatePanel/MonsterPortrait
@onready var scary_overlay: ColorRect = $DatePanel/ScaryOverlay
@onready var end_date_early_btn: Button = $EndDateEarlyButton

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

# Day Transition Panel
@onready var transition_panel: Panel = $DayTransitionPanel
@onready var transition_prev_box: VBoxContainer = $DayTransitionPanel/PrevDayBox
@onready var transition_prev_num: Label = $DayTransitionPanel/PrevDayBox/NumLabel
@onready var transition_prev_sub: Label = $DayTransitionPanel/PrevDayBox/SubLabel
@onready var transition_next_box: VBoxContainer = $DayTransitionPanel/NextDayBox
@onready var transition_next_num: Label = $DayTransitionPanel/NextDayBox/NumLabel
@onready var transition_next_sub: Label = $DayTransitionPanel/NextDayBox/SubLabel

var transition_tween: Tween

# Overlays
@onready var monsterpedia_overlay: Panel = $Overlays/MonsterpediaOverlay
@onready var dev_cheat_overlay: Panel = $Overlays/DevCheatOverlay
@onready var dev_cheat_btn: Button = $DevCheatBtn
@onready var background_texture: TextureRect = $BackgroundTexture

var room_textures: Array[Texture2D] = [
	preload("res://assets/backgrounds/rooms/asylum_room_1.jpg"),
	preload("res://assets/backgrounds/rooms/asylum_room_2.jpg"),
	preload("res://assets/backgrounds/rooms/asylum_room_3.jpg"),
	preload("res://assets/backgrounds/rooms/asylum_room_4.jpg")
]
var available_room_textures: Array[Texture2D] = []
var bg_room_tex: Texture2D = preload("res://assets/backgrounds/asylum_room.jpg")
var bg_hallway_tex: Texture2D = preload("res://assets/backgrounds/asylum_hallway.jpg")
var active_date_room_tex: Texture2D = null

var active_dialogue_balloon: Node = null
var portrait_tween: Tween

var scary_shader: Shader = preload("res://shaders/scary_vignette.gdshader")
var scary_material: ShaderMaterial = null
var _is_scary_mode_active: bool = false
var _scary_opacity: float = 0.0
var _scary_tween: Tween = null

func _ready() -> void:
	_init_scary_effect()
	# Connect Phase Buttons
	start_date_btn.pressed.connect(_on_start_date_pressed)
	if end_date_early_btn: end_date_early_btn.pressed.connect(_on_date_completed)
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
	GameManager.expression_changed.connect(_on_expression_changed)
	GameManager.date_completed.connect(func(_id): _on_date_completed())
	GameManager.dev_mode_toggled.connect(func(enabled: bool):
		if affection_container: affection_container.visible = enabled
		if dev_cheat_btn: dev_cheat_btn.visible = enabled and (intro_panel and not intro_panel.visible)
		if end_date_early_btn: end_date_early_btn.visible = enabled and (date_panel and date_panel.visible)
		if not enabled and dev_cheat_overlay: dev_cheat_overlay.visible = false
	)

	_start_new_game_session()

func _input(event: InputEvent) -> void:
	if transition_panel and transition_panel.visible:
		get_viewport().set_input_as_handled()
		return

	if intro_panel and intro_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode != KEY_F10:
				_skip_intro()

func _start_new_game_session() -> void:
	is_first_intro_transition = true
	available_room_textures = room_textures.duplicate()
	available_room_textures.shuffle()

	var m_vampire = load("res://resources/monsters/vampire.tres")
	var m_angel = load("res://resources/monsters/angel.tres")
	var m_sea_monster = load("res://resources/monsters/sea_monster.tres")
	var m_bug_monster = load("res://resources/monsters/bug_monster.tres")

	var pool: Array[MonsterData] = []
	if m_vampire: pool.append(m_vampire)
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
	if transition_panel:
		transition_panel.visible = (target_panel == transition_panel)

	if target_panel == date_panel:
		var current_monster := GameManager.get_current_date_monster()
		if current_monster:
			MusicManager.play_date_music(
				StringName(current_monster.id)
			)
		else:
			MusicManager.play_between_dates()
	else:
		MusicManager.play_between_dates()

	header_bar.visible = (target_panel != intro_panel and target_panel != date_panel and target_panel != transition_panel)
	
	if background_texture:
		if target_panel == date_panel:
			background_texture.texture = active_date_room_tex if active_date_room_tex else bg_room_tex
			background_texture.visible = true
		elif target_panel == prep_panel or target_panel == break_panel or target_panel == accusation_panel:
			background_texture.texture = bg_hallway_tex
			background_texture.visible = true
		else:
			background_texture.visible = false

	if monsterpedia_book_btn:
		monsterpedia_book_btn.visible = (target_panel != intro_panel and target_panel != ending_panel and target_panel != transition_panel)

	if end_date_early_btn:
		end_date_early_btn.visible = GameManager.dev_mode_show_affection and (target_panel == date_panel and target_panel != transition_panel)
	
	if dev_cheat_btn:
		dev_cheat_btn.visible = GameManager.dev_mode_show_affection and (target_panel != intro_panel and target_panel != ending_panel and target_panel != transition_panel)


# --- PHASE 0: INTRO CUTSCENE ---
func _show_intro_phase() -> void:
	_show_panel(intro_panel)

	var b_text = "[center][b][font_size=20][color=#7a1c1c]CASE FILE: OPERATION COUNTDOWN[/color][/font_size][/b]\n"
	b_text += "[font_size=13][color=#4a3b2c]BLACKWOOD HIGH-SECURITY MONSTER ASYLUM[/color][/font_size][/center]\n\n"
	b_text += "[b][color=#2c2214]SITUATION:[/color][/b] Four rehabilitated monsters were scheduled to be released into society in [color=#7a1c1c]five days[/color]. But last night, the asylum discovered a nightmare: the dangerous shapeshifter known as [color=#aa1818]'The Count'[/color] killed one of the patients and took their place in order to break out.\n\n"
	b_text += "[b][color=#2c2214]THE COVER-UP:[/color][/b] To catch the killer before release day without causing a public panic, the police and asylum set up a fake [color=#7a5800]dating experiment[/color] to test if candidates would integrate better into society with a romantic partner.\n\n"
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
	if is_first_intro_transition:
		is_first_intro_transition = false
		_show_day_transition_phase(0, GameManager.current_day, func(): _show_prep_phase())
	else:
		_show_prep_phase()

var candidate_self_bios: Dictionary = {
	"vampire": "I'm Percival. Behind the long coat and my taste for vintage red drinks, I'm just looking for a genuine connection. I like midnight walks, playing classical piano, and talking late into the night. I might be a little dramatic sometimes, but I just want someone who accepts me for who I am.",
	"angel": "Greetings, I am Isaac. I like neatness and symmetry. Messy desks and crooked picture frames stress me out, so I work hard to keep everything clean and organized. I'm looking for a date who appreciates quiet, well-ordered spaces and a calm schedule.",
	"sea_monster": "Hey! I'm Sienna. I love deep sea swimming, but I tend to be pretty forgetful. My thoughts drift around like ocean foam! I collect smooth sea shells and love listening to ambient wave sounds. I might lose my train of thought mid-sentence, but I'm easy to get along with.",
	"bug_monster": "Hi! I'm Lily. I'm a huge night owl and I overthink things at 3 AM. I weave string patterns when I get stressed and I love cozy desk lamps. I can be a bit jittery when excited, but if we get along, I'll always stand up for you."
}

func _get_day_num_text(day_num: int) -> String:
	var left = 6 - day_num
	if left == 1:
		return "1 Day"
	else:
		return "%d Days" % left

func _get_hud_day_text(day_num: int) -> String:
	var left = 6 - day_num
	if left == 1:
		return "1 DAY TILL RELEASE"
	else:
		return "%d DAYS TILL RELEASE" % left

# --- PHASE 1: PREP PHASE ---
func _show_prep_phase() -> void:
	_show_panel(prep_panel)
	day_label.text = _get_hud_day_text(GameManager.current_day)
	phase_label.text = "PHASE: PREPARATION"

	var current_monster = GameManager.get_current_date_monster()
	if current_monster:
		candidate_card_name.text = "Candidate Name: " + current_monster.display_name
		candidate_card_species.text = "Species: " + current_monster.species

		var bio = candidate_self_bios.get(current_monster.id, "A candidate undergoing social rehabilitation.")

		var txt = "[b][color=#2c2214]Description (Self-Written Bio):[/color][/b]\n"
		txt += "[i][color=#3d2b18]\"" + bio + "\"[/color][/i]\n\n"
		txt += "[color=#7a1c1c][b]NOTE TO DETECTIVE:[/b][/color]\n"
		txt += "[color=#4a3b2c]Use your [color=#7a5800]📖 Monsterpedia[/color] book at the bottom-left to cross-reference species traits and see if their answers match up during your date.[/color]"
		candidate_card_desc.text = txt
	else:
		candidate_card_name.text = "No Candidate"
		candidate_card_species.text = ""
		candidate_card_desc.text = ""


func _on_start_date_pressed() -> void:
	if available_room_textures.is_empty():
		available_room_textures = room_textures.duplicate()
		available_room_textures.shuffle()

	if not available_room_textures.is_empty():
		active_date_room_tex = available_room_textures.pop_back()

	var monster = GameManager.get_current_date_monster()
	var m_name = monster.display_name if monster else "Candidate"
	var m_species = monster.species if monster else ""
	var sub_text = "%s (%s)" % [m_name, m_species] if monster else "entering date room..."
	_show_simple_transition("Date Start", sub_text, true, func(): _show_date_phase())

func _animate_portrait_idle() -> void:
	if portrait_tween and portrait_tween.is_running():
		portrait_tween.kill()

	var base_y = portrait_rect.position.y
	portrait_tween = create_tween().set_loops()
	portrait_tween.tween_property(portrait_rect, "position:y", base_y - 8.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	portrait_tween.tween_property(portrait_rect, "position:y", base_y + 8.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_expression_changed(expression_name: String) -> void:
	var monster = GameManager.get_current_date_monster()
	if monster and portrait_rect:
		var tex = monster.get_expression_texture(expression_name)
		if tex:
			portrait_rect.texture = tex

		var default_top = -190.0
		var default_bottom = 350.0
		var y_off = monster.get_expression_y_offset(expression_name)
		portrait_rect.offset_top = default_top + y_off
		portrait_rect.offset_bottom = default_bottom + y_off

		if monster.portrait_scale != Vector2.ZERO:
			portrait_rect.pivot_offset = Vector2(270.0, 270.0)
			portrait_rect.scale = monster.portrait_scale
		else:
			portrait_rect.scale = Vector2.ONE
			portrait_rect.pivot_offset = Vector2.ZERO

		# Only the Vampire takes top layer priority in front of UI elements on angry/scary expressions
		if monster.id == "vampire" and (expression_name == "angry" or expression_name == "scary"):
			portrait_rect.z_index = 100
			portrait_rect.z_as_relative = false
		else:
			portrait_rect.z_index = 0
			portrait_rect.z_as_relative = true

		_animate_portrait_idle()

	var expr = expression_name.to_lower()
	if expr == "scary" or expr == "angry" or expr == "blush":
		_set_expression_effect(expr)
	else:
		_set_expression_effect("")

# --- PHASE 2: DATE PHASE ---
func _show_date_phase() -> void:
	_set_expression_effect("")
	_show_panel(date_panel)
	day_label.text = _get_hud_day_text(GameManager.current_day)
	phase_label.text = "PHASE: DATE"

	var default_top = -190.0
	var default_bottom = 350.0
	var monster = GameManager.get_current_date_monster()
	if monster:
		var y_off = monster.get_expression_y_offset("normal")
		portrait_rect.offset_top = default_top + y_off
		portrait_rect.offset_bottom = default_bottom + y_off

		if monster.portrait_scale != Vector2.ZERO:
			portrait_rect.pivot_offset = Vector2(270.0, 270.0)
			portrait_rect.scale = monster.portrait_scale
		else:
			portrait_rect.scale = Vector2.ONE
			portrait_rect.pivot_offset = Vector2.ZERO

		portrait_rect.z_index = 0
		portrait_rect.z_as_relative = true

		var tex = monster.get_expression_texture("normal")
		if tex:
			portrait_rect.texture = tex
		elif monster.portrait_texture:
			portrait_rect.texture = monster.portrait_texture
		else:
			portrait_rect.texture = load("res://assets/monsters/monster_placeholder.png")
		_update_affection_ui(GameManager.get_affection(monster.id))
	else:
		portrait_rect.offset_top = default_top
		portrait_rect.offset_bottom = default_bottom
		portrait_rect.scale = Vector2.ONE
		portrait_rect.pivot_offset = Vector2.ZERO
		portrait_rect.z_index = 0
		portrait_rect.z_as_relative = true
		portrait_rect.texture = load("res://assets/monsters/monster_placeholder.png")

	_animate_portrait_idle()

	var custom_balloon_scene = load("res://scenes/custom_balloon.tscn")
	if monster and monster.dialogue_resource:
		active_dialogue_balloon = DialogueManager.show_dialogue_balloon_scene(custom_balloon_scene, monster.dialogue_resource, "start")
	else:
		var fallback_res = load("res://assets/dialogues/sample_monster.dialogue")
		if fallback_res:
			active_dialogue_balloon = DialogueManager.show_dialogue_balloon_scene(custom_balloon_scene, fallback_res, "start")

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
	_set_expression_effect("")
	if is_instance_valid(active_dialogue_balloon):
		active_dialogue_balloon.queue_free()
	_show_simple_transition("Date Complete", "returning to case reflection...", true, func(): _show_break_phase())


# --- PHASE 3: BREAK PHASE ---
func _show_break_phase() -> void:
	_show_panel(break_panel)
	day_label.text = _get_hud_day_text(GameManager.current_day)
	phase_label.text = "PHASE: END OF DAY BREAK"

	var monster = GameManager.get_current_date_monster()
	var monster_name = monster.display_name if monster else "Candidate"
	var species_name = monster.species if monster else ""

	break_title.text = "BLACKWOOD ASYLUM - END OF DAY REFLECTION"
	
	var summary = "[b][color=#2c2214]Date Reflection & Case Briefing:[/color][/b]\n"
	summary += "You completed your date with [b][color=#7a1c1c]" + monster_name + "[/color][/b] (" + species_name + ").\n\n"
	summary += "[b][color=#2c2214]Detective's Log:[/color][/b]\n"
	summary += "[color=#3d2b18]Take a moment to note down your findings and thoughts from today's conversation. Open your [color=#7a5800]📖 Monsterpedia[/color] book at the bottom-left to cross-reference any suspicious answers against true species lore.[/color]\n\n"
	summary += "[color=#7a1c1c][b]NEXT STEPS:[/b][/color]\n"
	summary += "[color=#4a3b2c]When you are ready, advance to continue your investigation tomorrow.[/color]"
	break_summary.text = summary

func _on_next_day_pressed() -> void:
	var prev_day = GameManager.current_day
	GameManager.advance_to_next_day()
	var next_day = GameManager.current_day

	if next_day > 4:
		_show_day_transition_phase(prev_day, 5, func(): _show_accusation_phase())
	else:
		_show_day_transition_phase(prev_day, next_day, func(): _show_prep_phase())

func _show_simple_transition(main_text: String, sub_text: String, fast_speed: bool, on_complete: Callable) -> void:
	if transition_tween and transition_tween.is_running():
		transition_tween.kill()

	transition_panel.visible = true
	transition_panel.modulate.a = 0.0

	header_bar.visible = false
	monsterpedia_book_btn.visible = false
	if dev_cheat_btn: dev_cheat_btn.visible = false
	if end_date_early_btn: end_date_early_btn.visible = false

	transition_prev_num.text = main_text
	transition_prev_sub.text = sub_text
	transition_prev_box.modulate.a = 1.0
	transition_prev_box.position = Vector2(0, 0)
	transition_next_box.modulate.a = 0.0

	transition_tween = create_tween()

	var fade_in_t = 1.5 if fast_speed else 2.0
	var hold_t = 2.0 if fast_speed else 2.5
	var fade_out_t = 2.5 if fast_speed else 2.0

	# 1. Fade in dark transition panel over current UI
	transition_tween.tween_property(transition_panel, "modulate:a", 1.0, fade_in_t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# 2. Hold centered text beat
	transition_tween.tween_interval(hold_t)

	# 3. Load target phase UI behind dark screen
	transition_tween.tween_callback(func():
		if on_complete.is_valid():
			on_complete.call()
		transition_panel.visible = true
		if end_date_early_btn: end_date_early_btn.visible = false
	)

	# 4. Fade out revealing target phase UI
	transition_tween.tween_property(transition_panel, "modulate:a", 0.0, fade_out_t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# 5. Hide transition panel
	transition_tween.tween_callback(func():
		transition_panel.visible = false
		if end_date_early_btn:
			end_date_early_btn.visible = date_panel.visible
		if monsterpedia_book_btn:
			monsterpedia_book_btn.visible = (not intro_panel.visible and not ending_panel.visible)
		if dev_cheat_btn:
			dev_cheat_btn.visible = GameManager.dev_mode_show_affection and (not intro_panel.visible and not ending_panel.visible)
	)

func _show_day_transition_phase(prev_day: int, next_day: int, on_complete: Callable) -> void:
	if transition_tween and transition_tween.is_running():
		transition_tween.kill()

	transition_panel.visible = true
	transition_panel.modulate.a = 0.0

	header_bar.visible = false
	monsterpedia_book_btn.visible = false
	if dev_cheat_btn: dev_cheat_btn.visible = false
	if end_date_early_btn: end_date_early_btn.visible = false

	transition_tween = create_tween()

	if prev_day == 0 or prev_day == next_day:
		# --- Initial Start Day Transition (e.g. Day 1 at game start) ---
		transition_prev_num.text = _get_day_num_text(next_day)
		transition_prev_sub.text = "till release"
		transition_prev_box.modulate.a = 1.0
		transition_prev_box.position = Vector2(0, 0)
		transition_next_box.modulate.a = 0.0

		# 1. Subtle, slow cubic fade in OVER top of the Intro Case File UI (2.4s)
		transition_tween.tween_property(transition_panel, "modulate:a", 1.0, 2.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		# Hide intro panel after screen is fully dark
		transition_tween.tween_callback(func():
			intro_panel.visible = false
		)

		# 2. Dramatic hold on 5 Days Remaining in center of darkness (2.5s)
		transition_tween.tween_interval(2.5)

		# 3. Load Prep Scene behind dark screen BEFORE fading out
		transition_tween.tween_callback(func():
			if on_complete.is_valid():
				on_complete.call()
			transition_panel.visible = true
		)

		# 4. Subtle, slow cubic fade out revealing Prep Scene UI (2.4s)
		transition_tween.tween_property(transition_panel, "modulate:a", 0.0, 2.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		# 5. Hide transition panel after fade out completes
		transition_tween.tween_callback(func():
			transition_panel.visible = false
			if end_date_early_btn:
				end_date_early_btn.visible = date_panel.visible
			if monsterpedia_book_btn:
				monsterpedia_book_btn.visible = (not intro_panel.visible and not ending_panel.visible)
			if dev_cheat_btn:
				dev_cheat_btn.visible = GameManager.dev_mode_show_affection and (not intro_panel.visible and not ending_panel.visible)
		)
	else:
		# --- Mid-Game Day Transition (e.g. Day 1 -> Day 2) ---
		transition_prev_num.text = _get_day_num_text(prev_day)
		transition_prev_sub.text = "till release"
		transition_prev_box.modulate.a = 1.0
		transition_prev_box.position = Vector2(0, 0)

		transition_next_num.text = _get_day_num_text(next_day)
		transition_next_sub.text = "till release"
		transition_next_box.modulate.a = 0.0
		transition_next_box.position = Vector2(0, -540)

		# 1. Subtle, slow cubic fade in OVER top of the current Break Scene UI (2.4s)
		transition_tween.tween_property(transition_panel, "modulate:a", 1.0, 2.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		# Hide previous break panel after screen is fully dark
		transition_tween.tween_callback(func():
			break_panel.visible = false
		)

		# 2. Hold on Previous Day in center (1.5s)
		transition_tween.tween_interval(1.5)

		# 3. Slow, heavy scroll animation (3.2s)
		# Prev box slowly scrolls DOWN offscreen and fades out
		transition_tween.parallel().tween_property(transition_prev_box, "position:y", 540.0, 3.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		transition_tween.parallel().tween_property(transition_prev_box, "modulate:a", 0.0, 2.2)

		# Next box slowly drops DOWN into dead-center stage and fades in
		transition_tween.parallel().tween_property(transition_next_box, "position:y", 0.0, 3.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		transition_tween.parallel().tween_property(transition_next_box, "modulate:a", 1.0, 2.5)

		# 4. Long dramatic hold on New Day in center (2.5s)
		transition_tween.tween_interval(2.5)

		# 5. Load the new target scene UI behind the dark screen BEFORE fading out
		transition_tween.tween_callback(func():
			if on_complete.is_valid():
				on_complete.call()
			transition_panel.visible = true
		)

		# 6. Subtle, slow cubic fade out revealing the newly loaded scene UI (2.4s)
		transition_tween.tween_property(transition_panel, "modulate:a", 0.0, 2.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		# 7. Hide transition panel after fade out completes
		transition_tween.tween_callback(func():
			transition_panel.visible = false
			if end_date_early_btn:
				end_date_early_btn.visible = date_panel.visible
			if monsterpedia_book_btn:
				monsterpedia_book_btn.visible = (not intro_panel.visible and not ending_panel.visible)
			if dev_cheat_btn:
				dev_cheat_btn.visible = GameManager.dev_mode_show_affection and (not intro_panel.visible and not ending_panel.visible)
		)

# --- PHASE 4: ACCUSATION & MATCHING PHASE ---
func _show_accusation_phase() -> void:
	_show_panel(accusation_panel)
	day_label.text = "1 DAY TILL RELEASE (ACCUSATION)"
	phase_label.text = "PHASE: ACCUSATION & MATCHING"

	if monsterpedia_overlay:
		monsterpedia_overlay.style_option_button(accuse_dropdown)
		monsterpedia_overlay.style_option_button(match_dropdown)

	accuse_dropdown.clear()
	match_dropdown.clear()
	match_dropdown.add_item("Nobody (Single)", 0)

	for candidate in GameManager.selected_candidates:
		accuse_dropdown.add_item("%s (%s)" % [candidate.display_name, candidate.species])
		accuse_dropdown.set_item_metadata(accuse_dropdown.get_item_count() - 1, candidate.id)

		var aff = GameManager.get_affection(candidate.id)
		if aff >= candidate.min_affection_for_match:
			match_dropdown.add_item("%s (%s)" % [candidate.display_name, candidate.species])
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
func _on_cheat_jump_date(target_id: String, force_imposter: bool = false) -> void:
	var monster_res: MonsterData = load("res://resources/monsters/%s.tres" % target_id)
	if not monster_res: return

	if force_imposter:
		GameManager.imposter_monster_id = target_id
	elif GameManager.imposter_monster_id == target_id:
		for c in GameManager.selected_candidates:
			if c.id != target_id:
				GameManager.imposter_monster_id = c.id
				break

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

	if dev_cheat_overlay:
		dev_cheat_overlay.refresh_info()

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


# --- EXPRESSION MOOD SHADER & VIBRATION EFFECT ---
var _current_effect_mode: String = ""

func _init_scary_effect() -> void:
	scary_material = ShaderMaterial.new()
	scary_material.shader = scary_shader
	scary_material.set_shader_parameter("vignette_opacity", 0.0)
	scary_material.set_shader_parameter("vignette_intensity", 1.25)
	scary_material.set_shader_parameter("vignette_color", Color(0.12, 0.0, 0.03, 0.95))
	scary_material.set_shader_parameter("pulse_speed", 8.0)
	scary_material.set_shader_parameter("pulse_amount", 0.08)
	scary_material.set_shader_parameter("aberration_amount", 0.008)

	if scary_overlay:
		scary_overlay.material = scary_material

func _set_expression_effect(mode_name: String) -> void:
	if _current_effect_mode == mode_name:
		return
	_current_effect_mode = mode_name

	if _scary_tween and _scary_tween.is_running():
		_scary_tween.kill()

	_scary_tween = create_tween()

	if mode_name == "scary":
		if scary_material:
			scary_material.set_shader_parameter("vignette_color", Color(0.12, 0.0, 0.03, 0.95))
			scary_material.set_shader_parameter("pulse_speed", 8.0)
			scary_material.set_shader_parameter("pulse_amount", 0.08)
			scary_material.set_shader_parameter("aberration_amount", 0.008)
		_scary_tween.tween_property(self, "_scary_opacity", 0.85, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	elif mode_name == "angry":
		if scary_material:
			scary_material.set_shader_parameter("vignette_color", Color(0.0, 0.0, 0.0, 1.0))
			scary_material.set_shader_parameter("pulse_speed", 3.0)
			scary_material.set_shader_parameter("pulse_amount", 0.02)
			scary_material.set_shader_parameter("aberration_amount", 0.0)
		_scary_tween.tween_property(self, "_scary_opacity", 0.55, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	elif mode_name == "blush":
		_scary_tween.tween_property(self, "_scary_opacity", 0.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		if portrait_rect:
			portrait_rect.z_index = 0
			portrait_rect.z_as_relative = true
			var monster = GameManager.get_current_date_monster()
			var base_scale = monster.portrait_scale if (monster and monster.portrait_scale != Vector2.ZERO) else Vector2.ONE
			portrait_rect.pivot_offset = Vector2(270.0, 270.0)
			var shy_tween = create_tween()
			shy_tween.tween_property(portrait_rect, "scale", base_scale * Vector2(0.95, 0.95), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		if portrait_rect:
			portrait_rect.z_index = 0
			portrait_rect.z_as_relative = true
			var monster = GameManager.get_current_date_monster()
			var base_scale = monster.portrait_scale if (monster and monster.portrait_scale != Vector2.ZERO) else Vector2.ONE
			portrait_rect.pivot_offset = Vector2(270.0, 270.0)
			var reset_tween = create_tween()
			reset_tween.tween_property(portrait_rect, "scale", base_scale, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_scary_tween.tween_property(self, "_scary_opacity", 0.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	if scary_material:
		scary_material.set_shader_parameter("vignette_opacity", _scary_opacity)

	if portrait_rect:
		if _current_effect_mode == "blush" or _scary_opacity > 0.001:
			var time = Time.get_ticks_msec() * 0.001
			var intensity = _scary_opacity
			var shake_x = 0.0
			var rot_deg = 0.0

			if _current_effect_mode == "scary":
				shake_x = (sin(time * 50.0) * 5.0 + sin(time * 22.0) * 2.5) * intensity
				rot_deg = sin(time * 42.0) * 1.5 * intensity
			elif _current_effect_mode == "angry":
				shake_x = (sin(time * 22.0) * 1.2) * (intensity / 0.55)
				rot_deg = (sin(time * 18.0) * 0.2) * (intensity / 0.55)
			elif _current_effect_mode == "blush":
				# Tiny, subtle bashful sway (2px) and gentle head tilt (0.8 deg) without zoom/scaling
				shake_x = sin(time * 2.0) * 2.0
				rot_deg = sin(time * 2.0) * 0.8
			else:
				shake_x = 0.0
				rot_deg = 0.0

			portrait_rect.pivot_offset = Vector2(270.0, 270.0)
			portrait_rect.rotation_degrees = rot_deg
			portrait_rect.offset_left = -270.0 + shake_x
			portrait_rect.offset_right = 270.0 + shake_x
		else:
			portrait_rect.rotation_degrees = 0.0
			portrait_rect.offset_left = -270.0
			portrait_rect.offset_right = 270.0
