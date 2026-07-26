class_name MonsterpediaOverlay extends Panel

const BRUSH_COLORS: Array[Color] = [
	Color("#3b2416"),
	Color("#8a2f2f"),
	Color("#234d70"),
]

@onready var species_dropdown: OptionButton = $VBox/TabContainer/SpeciesLore/SpeciesDropdown
@onready var lore_label: RichTextLabel = $VBox/TabContainer/SpeciesLore/LoreLabel
@onready var clue_container: VBoxContainer = $VBox/TabContainer/EvidenceNotebook/Scroll/ClueContainer
@onready var close_btn: Button = $VBox/Header/CloseButton
@onready var notes_edit: TextEdit = $VBox/TabContainer/EvidenceNotebook/Workspace/NotesPanel/NotesEdit
@onready var drawing_canvas = $VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingCanvas
@onready var brush_color_buttons: Array[Button] = [
	$VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/BrownBrush,
	$VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/RedBrush,
	$VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/BlueBrush,
]
@onready var brush_width_slider: HSlider = $VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/BrushWidth
@onready var brush_width_value: Label = $VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/BrushWidthValue
@onready var undo_drawing_button: Button = $VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/UndoButton
@onready var clear_drawing_button: Button = $VBox/TabContainer/EvidenceNotebook/Workspace/DrawingPanel/DrawingToolbar/ClearButton
@onready var evidence_title: Label = $VBox/TabContainer/EvidenceNotebook/EvidenceTitle
@onready var evidence_scroll: ScrollContainer = $VBox/TabContainer/EvidenceNotebook/Scroll

var _loading_notebook := false

func _ready() -> void:
	var tab_container = get_node_or_null("VBox/TabContainer")
	if tab_container:
		tab_container.set_tab_title(0, "Species Lore")
		tab_container.set_tab_title(1, "Evidence Notebook")

	close_btn.pressed.connect(func(): visible = false)
	species_dropdown.item_selected.connect(_on_species_selected)
	notes_edit.text_changed.connect(_on_notes_text_changed)
	drawing_canvas.strokes_changed.connect(_on_drawing_changed)
	for index in brush_color_buttons.size():
		brush_color_buttons[index].pressed.connect(
			_on_brush_color_selected.bind(index)
		)
	brush_width_slider.value_changed.connect(
		_on_brush_width_changed
	)
	undo_drawing_button.pressed.connect(
		drawing_canvas.undo_last_stroke
	)
	clear_drawing_button.pressed.connect(
		drawing_canvas.clear_drawing
	)
	GameManager.clue_recorded.connect(_on_clue_recorded)
	GameManager.notebook_reset.connect(_on_notebook_reset)
	GameManager.dev_mode_toggled.connect(_update_evidence_visibility)
	style_option_button(species_dropdown)
	_setup_color_picker_buttons()
	_setup_dropdown()
	_load_notebook_state()
	_update_evidence_visibility(GameManager.dev_mode_show_affection)
	brush_color_buttons[0].button_pressed = true
	_on_brush_color_selected(0)
	_on_brush_width_changed(brush_width_slider.value)

func _setup_color_picker_buttons() -> void:
	for i in range(brush_color_buttons.size()):
		var btn = brush_color_buttons[i]
		if not btn: continue
		btn.text = ""
		btn.custom_minimum_size = Vector2(24, 24)
		btn.pivot_offset = Vector2(12, 12)
		_update_brush_button_style(i, i == 0)

func _update_brush_button_style(i: int, is_selected: bool) -> void:
	var btn = brush_color_buttons[i]
	if not btn: return
	var col = BRUSH_COLORS[i]

	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = col
	sb_normal.set_corner_radius_all(100)
	sb_normal.content_margin_left = 0
	sb_normal.content_margin_top = 0
	sb_normal.content_margin_right = 0
	sb_normal.content_margin_bottom = 0

	if is_selected:
		sb_normal.border_width_left = 3
		sb_normal.border_width_top = 3
		sb_normal.border_width_right = 3
		sb_normal.border_width_bottom = 3
		sb_normal.border_color = Color(0.98, 0.82, 0.25, 1.0)
		btn.scale = Vector2(1.15, 1.15)
	else:
		sb_normal.border_width_left = 2
		sb_normal.border_width_top = 2
		sb_normal.border_width_right = 2
		sb_normal.border_width_bottom = 2
		sb_normal.border_color = Color(0.25, 0.18, 0.12, 0.8)
		btn.scale = Vector2(1.0, 1.0)

	var sb_hover = sb_normal.duplicate()
	sb_hover.border_color = Color(1.0, 0.92, 0.7, 1.0)

	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_normal)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func toggle_window() -> void:
	visible = not visible
	if visible:
		_load_notebook_state()
		_update_clue_notebook()
		_update_evidence_visibility(GameManager.dev_mode_show_affection)
		_auto_select_current_candidate()

func _update_evidence_visibility(enabled: bool) -> void:
	if evidence_title:
		evidence_title.visible = enabled
	if evidence_scroll:
		evidence_scroll.visible = enabled


func _load_notebook_state() -> void:
	_loading_notebook = true
	notes_edit.text = GameManager.notebook_text
	drawing_canvas.set_strokes(
		GameManager.notebook_strokes
	)
	_loading_notebook = false


func _on_notes_text_changed() -> void:
	if _loading_notebook:
		return

	GameManager.set_notebook_text(notes_edit.text)


func _on_drawing_changed(strokes: Array) -> void:
	if _loading_notebook:
		return

	GameManager.set_notebook_strokes(strokes)


func _on_brush_color_selected(index: int) -> void:
	drawing_canvas.set_brush_color(BRUSH_COLORS[index])
	for i in range(brush_color_buttons.size()):
		_update_brush_button_style(i, i == index)


func _on_brush_width_changed(width: float) -> void:
	drawing_canvas.set_brush_width(width)
	brush_width_value.text = "%d px" % int(width)


func _on_notebook_reset() -> void:
	_load_notebook_state()
	_update_clue_notebook()

func _auto_select_current_candidate() -> void:
	var current_monster = GameManager.get_current_date_monster()
	if current_monster and current_monster.species != "":
		for i in range(species_dropdown.item_count):
			var item_text = species_dropdown.get_item_text(i)
			if item_text.to_lower() in current_monster.species.to_lower() or current_monster.species.to_lower() in item_text.to_lower():
				species_dropdown.select(i)
				_on_species_selected(i)
				return

func _setup_dropdown() -> void:
	species_dropdown.clear()
	for s_name in GameManager.species_lore_db.keys():
		species_dropdown.add_item(s_name)
	_auto_select_current_candidate()

func _on_species_selected(index: int) -> void:
	var s_name = species_dropdown.get_item_text(index)
	var lines = GameManager.get_species_lore(s_name)
	var txt = "[b][font_size=18][color=#7a1c1c]" + s_name.to_upper() + " SPECIES LORE & TRAITS[/color][/font_size][/b]\n\n"
	for line in lines:
		txt += "[font_size=15][color=#2c2214]" + line + "[/color][/font_size]\n\n"
	lore_label.text = txt


func _update_clue_notebook() -> void:
	for child in clue_container.get_children():
		child.queue_free()

	if GameManager.discovered_clues.size() == 0:
		var empty_lbl = RichTextLabel.new()
		empty_lbl.bbcode_enabled = true
		empty_lbl.fit_content = true
		empty_lbl.text = "[i][color=#5c4933]No evidence clues recorded yet. Interrogate candidates during dates to uncover lore slips![/color][/i]"
		clue_container.add_child(empty_lbl)
		return

	for clue in GameManager.discovered_clues:
		var clue_lbl = RichTextLabel.new()
		clue_lbl.bbcode_enabled = true
		clue_lbl.fit_content = true
		var day_num = clue.get("day_found", 1)
		var c_id = clue.get("candidate_id", "").capitalize()
		var clue_text = clue.get("text", "")
		clue_lbl.text = "[b][color=#7a1c1c][Day %d - %s]:[/color][/b] [color=#2c2214]%s[/color]" % [day_num, c_id, clue_text]
		clue_container.add_child(clue_lbl)

func _on_clue_recorded(_c_id, _clue_id, _text) -> void:
	_update_clue_notebook()

static func style_option_button(opt_btn: OptionButton) -> void:
	if not opt_btn: return

	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.88, 0.81, 0.67, 1)
	normal_sb.border_width_left = 2
	normal_sb.border_width_top = 2
	normal_sb.border_width_right = 2
	normal_sb.border_width_bottom = 2
	normal_sb.border_color = Color(0.36, 0.12, 0.12, 1)
	normal_sb.corner_radius_top_left = 4
	normal_sb.corner_radius_top_right = 4
	normal_sb.corner_radius_bottom_right = 4
	normal_sb.corner_radius_bottom_left = 4
	normal_sb.content_margin_left = 12
	normal_sb.content_margin_top = 6
	normal_sb.content_margin_right = 12
	normal_sb.content_margin_bottom = 6

	var hover_sb = normal_sb.duplicate()
	hover_sb.bg_color = Color(0.93, 0.87, 0.73, 1)

	var pressed_sb = normal_sb.duplicate()
	pressed_sb.bg_color = Color(0.36, 0.12, 0.12, 1)
	pressed_sb.border_color = Color(0.8, 0.62, 0.22, 1)

	var empty_sb = StyleBoxEmpty.new()

	opt_btn.add_theme_stylebox_override("normal", normal_sb)
	opt_btn.add_theme_stylebox_override("hover", hover_sb)
	opt_btn.add_theme_stylebox_override("pressed", pressed_sb)
	opt_btn.add_theme_stylebox_override("focus", empty_sb)

	opt_btn.add_theme_color_override("font_color", Color(0.2, 0.14, 0.08, 1))
	opt_btn.add_theme_color_override("font_hover_color", Color(0.36, 0.12, 0.12, 1))
	opt_btn.add_theme_color_override("font_pressed_color", Color(0.95, 0.88, 0.72, 1))

	var popup: PopupMenu = opt_btn.get_popup()
	if popup:
		var popup_sb = StyleBoxFlat.new()
		popup_sb.bg_color = Color(0.91, 0.85, 0.72, 1)
		popup_sb.border_width_left = 2
		popup_sb.border_width_top = 2
		popup_sb.border_width_right = 2
		popup_sb.border_width_bottom = 2
		popup_sb.border_color = Color(0.36, 0.12, 0.12, 1)
		popup_sb.corner_radius_top_left = 6
		popup_sb.corner_radius_top_right = 6
		popup_sb.corner_radius_bottom_right = 6
		popup_sb.corner_radius_bottom_left = 6
		popup_sb.shadow_color = Color(0, 0, 0, 0.5)
		popup_sb.shadow_size = 10
		popup_sb.content_margin_left = 8
		popup_sb.content_margin_top = 8
		popup_sb.content_margin_right = 8
		popup_sb.content_margin_bottom = 8

		var item_hover_sb = StyleBoxFlat.new()
		item_hover_sb.bg_color = Color(0.36, 0.12, 0.12, 1)
		item_hover_sb.corner_radius_top_left = 4
		item_hover_sb.corner_radius_top_right = 4
		item_hover_sb.corner_radius_bottom_right = 4
		item_hover_sb.corner_radius_bottom_left = 4
		item_hover_sb.content_margin_left = 8
		item_hover_sb.content_margin_top = 4
		item_hover_sb.content_margin_right = 8
		item_hover_sb.content_margin_bottom = 4

		popup.add_theme_stylebox_override("panel", popup_sb)
		popup.add_theme_stylebox_override("hover", item_hover_sb)

		popup.add_theme_color_override("font_color", Color(0.2, 0.14, 0.08, 1))
		popup.add_theme_color_override("font_hover_color", Color(0.95, 0.88, 0.72, 1))
		popup.add_theme_color_override("font_accelerator_color", Color(0.48, 0.11, 0.11, 1))
		popup.add_theme_color_override("font_disabled_color", Color(0.5, 0.4, 0.3, 1))
