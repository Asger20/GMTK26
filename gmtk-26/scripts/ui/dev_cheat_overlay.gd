extends Panel

signal jump_date_requested(monster_id: String)
signal jump_day_requested(day_num: int)
signal reset_session_requested()
signal unlock_clues_requested()
signal finish_date_requested()

@onready var close_btn: Button = $VBox/Header/CloseButton
@onready var info_text: RichTextLabel = $VBox/SessionInfoText
@onready var monster_dropdown: OptionButton = $VBox/JumpDateContainer/MonsterDropdown
@onready var jump_date_btn: Button = $VBox/JumpDateContainer/JumpDateBtn
@onready var add25_btn: Button = $VBox/AffectionContainer/Add25Btn
@onready var sub25_btn: Button = $VBox/AffectionContainer/Sub25Btn
@onready var max_btn: Button = $VBox/AffectionContainer/MaxBtn
@onready var min_btn: Button = $VBox/AffectionContainer/MinBtn
@onready var day1_btn: Button = $VBox/DayJumpContainer/Day1Btn
@onready var day2_btn: Button = $VBox/DayJumpContainer/Day2Btn
@onready var day3_btn: Button = $VBox/DayJumpContainer/Day3Btn
@onready var day4_btn: Button = $VBox/DayJumpContainer/Day4Btn
@onready var accuse_btn: Button = $VBox/DayJumpContainer/AccusationBtn
@onready var reset_btn: Button = $VBox/ActionContainer/ResetSessionBtn
@onready var unlock_clues_btn: Button = $VBox/ActionContainer/UnlockCluesBtn
@onready var skip_timer_btn: Button = $VBox/ActionContainer/SkipTimerBtn

func _ready() -> void:
	close_btn.pressed.connect(func(): visible = false)
	jump_date_btn.pressed.connect(_on_jump_date_pressed)
	add25_btn.pressed.connect(func(): _modify_active_affection(25))
	sub25_btn.pressed.connect(func(): _modify_active_affection(-25))
	max_btn.pressed.connect(func(): _set_active_affection(100))
	min_btn.pressed.connect(func(): _set_active_affection(0))
	day1_btn.pressed.connect(func(): _jump_day(1))
	day2_btn.pressed.connect(func(): _jump_day(2))
	day3_btn.pressed.connect(func(): _jump_day(3))
	day4_btn.pressed.connect(func(): _jump_day(4))
	accuse_btn.pressed.connect(func(): _jump_day(5))
	reset_btn.pressed.connect(func(): reset_session_requested.emit())
	unlock_clues_btn.pressed.connect(func(): unlock_clues_requested.emit())
	skip_timer_btn.pressed.connect(func(): finish_date_requested.emit())

func toggle_window() -> void:
	visible = not visible
	if visible:
		_setup_dropdown()
		refresh_info()

func refresh_info() -> void:
	if not info_text: return
	var text = "[b]CURRENT SESSION LINEUP (4 PATIENTS):[/b]\n"
	for i in range(GameManager.selected_candidates.size()):
		var m = GameManager.selected_candidates[i]
		var is_imp = GameManager.is_imposter(m.id)
		var imp_tag = " [color=#ff4444][THE COUNT / IMPOSTER][/color]" if is_imp else ""
		text += "Day %d: [b]%s[/b] (%s)%s - Affection: %d%%\n" % [i + 1, m.display_name, m.species, imp_tag, GameManager.get_affection(m.id)]
	
	text += "\n[b]DESIGNATED IMPOSTER:[/b] [color=#ff4444]%s[/color]" % [GameManager.imposter_monster_id.to_upper()]
	info_text.text = text

func _setup_dropdown() -> void:
	if not monster_dropdown: return
	monster_dropdown.clear()
	var all_ids = ["zombie", "vampire", "slime", "angel", "sea_monster", "bug_monster"]
	for id in all_ids:
		var monster_res = load("res://resources/monsters/%s.tres" % id)
		if monster_res:
			monster_dropdown.add_item("%s (%s)" % [monster_res.display_name, monster_res.species], -1)
			monster_dropdown.set_item_metadata(monster_dropdown.get_item_count() - 1, id)

func _on_jump_date_pressed() -> void:
	var selected_idx = monster_dropdown.selected
	if selected_idx < 0: return
	var target_id = monster_dropdown.get_item_metadata(selected_idx)
	visible = false
	jump_date_requested.emit(target_id)

func _modify_active_affection(amount: int) -> void:
	var current_monster = GameManager.get_current_date_monster()
	if current_monster:
		GameManager.add_affection(current_monster.id, amount)
		refresh_info()

func _set_active_affection(val: int) -> void:
	var current_monster = GameManager.get_current_date_monster()
	if current_monster:
		GameManager.set_affection(current_monster.id, val)
		refresh_info()

func _jump_day(day_num: int) -> void:
	visible = false
	jump_day_requested.emit(day_num)
