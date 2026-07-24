extends Panel

@onready var species_dropdown: OptionButton = $VBox/TabContainer/SpeciesLore/SpeciesDropdown
@onready var lore_label: RichTextLabel = $VBox/TabContainer/SpeciesLore/LoreLabel
@onready var clue_container: VBoxContainer = $VBox/TabContainer/EvidenceNotebook/Scroll/ClueContainer
@onready var close_btn: Button = $VBox/Header/CloseButton

func _ready() -> void:
	close_btn.pressed.connect(func(): visible = false)
	species_dropdown.item_selected.connect(_on_species_selected)
	GameManager.clue_recorded.connect(_on_clue_recorded)
	_setup_dropdown()

func toggle_window() -> void:
	visible = not visible
	if visible:
		_update_clue_notebook()

func _setup_dropdown() -> void:
	species_dropdown.clear()
	for s_name in GameManager.species_lore_db.keys():
		species_dropdown.add_item(s_name)
	_on_species_selected(0)

func _on_species_selected(index: int) -> void:
	var s_name = species_dropdown.get_item_text(index)
	var lines = GameManager.get_species_lore(s_name)
	var txt = "[b]" + s_name.to_upper() + " SPECIES LORE[/b]\n\n"
	for line in lines:
		txt += line + "\n"
	lore_label.text = txt

func _update_clue_notebook() -> void:
	for child in clue_container.get_children():
		child.queue_free()

	if GameManager.discovered_clues.size() == 0:
		var lbl = Label.new()
		lbl.text = "No evidence clues recorded yet."
		clue_container.add_child(lbl)
		return

	for clue in GameManager.discovered_clues:
		var lbl = Label.new()
		lbl.text = "[Day %d] Candidate '%s': %s" % [clue.get("day_found", 1), clue.get("candidate_id", ""), clue.get("text", "")]
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clue_container.add_child(lbl)

func _on_clue_recorded(_c_id, _clue_id, _text) -> void:
	_update_clue_notebook()
