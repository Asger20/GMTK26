extends Control

@onready var lore_text_label: RichTextLabel = $Panel/TabContainer/SpeciesLore/LoreTextLabel
@onready var clue_list_container: VBoxContainer = $Panel/TabContainer/EvidenceNotebook/ScrollContainer/ClueListContainer
@onready var species_option_button: OptionButton = $Panel/TabContainer/SpeciesLore/SpeciesOptionButton

# Pre-defined Monsterpedia Lore database
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
	]
}

func _ready() -> void:
	# Connect signals
	GameManager.clue_recorded.connect(_on_clue_recorded)
	
	_populate_species_options()
	_update_clue_list()
	
	if species_option_button and species_option_button.item_count > 0:
		_on_species_selected(0)

func _populate_species_options() -> void:
	if not species_option_button:
		return
	species_option_button.clear()
	for species_name in species_lore_db.keys():
		species_option_button.add_item(species_name)
	species_option_button.item_selected.connect(_on_species_selected)

func _on_species_selected(index: int) -> void:
	var species_name = species_option_button.get_item_text(index)
	var lore_lines = species_lore_db.get(species_name, ["No lore recorded."])
	
	var bbcode = "[b]" + species_name.to_upper() + " SPECIES LORE[/b]\n\n"
	for line in lore_lines:
		bbcode += line + "\n"
	
	lore_text_label.text = bbcode

func _update_clue_list() -> void:
	if not clue_list_container:
		return
		
	# Clear existing children
	for child in clue_list_container.get_children():
		child.queue_free()
		
	if GameManager.discovered_clues.size() == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "No clues or lore inconsistencies recorded yet."
		clue_list_container.add_child(empty_lbl)
		return
		
	for clue in GameManager.discovered_clues:
		var clue_lbl = Label.new()
		clue_lbl.text = "[Day %d] Candidate '%s': %s" % [clue.get("day_found", 1), clue.get("candidate_id", "Unknown"), clue.get("text", "")]
		clue_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clue_list_container.add_child(clue_lbl)

func _on_clue_recorded(_candidate_id: String, _clue_id: String, _text: String) -> void:
	_update_clue_list()
