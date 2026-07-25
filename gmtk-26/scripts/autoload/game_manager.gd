extends Node

signal day_changed(new_day: int)
signal affection_changed(candidate_id: String, new_score: int)
signal clue_recorded(candidate_id: String, clue_id: String, text: String)
signal date_completed(candidate_id: String)
signal dev_mode_toggled(is_enabled: bool)
signal expression_changed(expression_name: String)

func set_expression(expression_name: String) -> void:
	MusicManager.set_mood_effect_enabled(
		expression_name.to_lower() == "scary"
	)
	expression_changed.emit(expression_name)
	print("[GameManager] Expression set to: ", expression_name)


enum EndingType {
	NONE,
	BAD_ENDING,       # Accuse wrong, match nobody
	MIXED_ENDING,     # Accuse wrong, match innocent monster
	GOOD_ENDING,      # Accuse Count, match nobody
	BEST_ENDING,      # Accuse Count, match innocent monster
	SECRET_ENDING_1,  # Accuse Count, match Count (Villain Romance)
	SECRET_ENDING_2   # Accuse wrong, match Count (Bonnie & Clyde Escape)
}

# Player profile
var player_name: String = "Detective"
var player_race: String = "Human"
var player_description: String = "Undercover Investigator"

# Game Flow State
var current_day: int = 1 # Days 1..4 = Dates, Day 5 = Accusation
var all_monsters: Array[MonsterData] = []
var selected_candidates: Array[MonsterData] = []
var imposter_monster_id: String = ""
var current_date_index: int = 0 # 0..3

# Dynamic State
var affection_scores: Dictionary = {} # candidate_id -> int (0..100)
var discovered_clues: Array[Dictionary] = [] # Array of {candidate_id, clue_id, text}
var dialogue_flags: Dictionary = {} # candidate_id + "_" + flag_name -> bool

func set_flag(candidate_id: String, flag_name: String, value: bool = true) -> void:
	var key = candidate_id + "_" + flag_name
	dialogue_flags[key] = value

func has_flag(candidate_id: String, flag_name: String) -> bool:
	var key = candidate_id + "_" + flag_name
	return dialogue_flags.get(key, false)

# Dev Options (Global state persistent across dates and runs)
var dev_mode_show_affection: bool = false


# Day 5 Decision Choices
var selected_accusation_id: String = ""
var selected_match_id: String = ""

# Master Species Lore Database
var species_lore_db: Dictionary = {
	"Vampire": [
		"• [b]CLASSIFICATION & HABITAT:[/b] Sanguine Nocturnal / Vampirus Aristocratis. Native to ancestral gothic manors, subterranean mausoleums, and pitch-black keeps.",
		"• [b]ANCESTRAL CULTURAL LORE:[/b] They view existence through blood nobility and sensory perfection. Blood is regarded as a delicate vintage, recording memory, emotion, and vital essence.",
		"• [b]HEMATOPHAGOUS VINTAGE & TEMPERATURE SENSITIVITY:[/b] Consumes blood exclusively. Extremely snobbish about vintage, plasma balance, and warmth. Coagulated or synthetic blood induces immediate revulsion. Sub-normal body temperature (15 to 18°C).",
		"• [b]ACTINIC PHOTOPHOBIA (Solar Degradation):[/b] Direct UV exposure triggers immediate skin necrosis, severe burning, and motor disorientation. Even 6 AM dawn glow causes involuntary eye squinting and rapid physical weakness.",
		"• [b]SUB-EPIDERMAL PULSE PERCEPTION:[/b] Hyper-sensitive sensory organs track surrounding heartbeats within a five-meter radius, subconsciously monitoring suitor nervousness.",
		"• [b]THE MIRROR ANOMALY (Involuntary Reflex Fixation):[/b] Produces zero optical reflection in silver-backed mirrors. Reflected surfaces trigger a subtle, involuntary head tilt or micro-hesitation.",
		"• [b]HEMATOTROPHIC DILATED PUPIL LOCK:[/b] The scent of fresh blood or heightened emotional intimacy causes immediate pupil dilation and involuntary fang extension.",
		"• [b]STRICT NOCTURNAL CIRCADIAN LOCK:[/b] Biological sleep cycle is hard-coded from sunrise to dusk. Claims of enjoying dawn sunrises or early morning walks are physically impossible for an authentic Vampire."
	],
	"Angel": [
		"• [b]CLASSIFICATION & HABITAT:[/b] Seraphim Geometrica / Biblical Angel. Native to high-frequency celestial spheres, pristine marble sanctuaries, and geometrically ordered sanctums.",
		"• [b]ANCESTRAL CULTURAL LORE:[/b] They view the cosmos as a flawless mathematical equation. Perfection, symmetry, and golden-ratio alignment are not personal choices, they are sacred laws governing their existence.",
		"• [b]GEOMETRIC ALIGNMENT & ASYMMETRY DISTRESS:[/b] Their nervous system is physically bound to environmental order. Crooked picture frames, asymmetrical furniture, or clutter induce physical nausea, muscle rigidity, and rapid resonance decay. Claims of enjoying chaotic or messy rooms are a critical imposter slip.",
		"• [b]HARMONIC FREQUENCY RESONANCE:[/b] Vocal cords produce overlapping, multi-harmonic chords rather than a single pitch. Resonates with metallic chime undertones when calm, shifting to sharp dissonant hums when agitated.",
		"• [b]LUMINANCE BIO-FEEDBACK & VECTOR OCULAR SCANNING:[/b] Emits a subtle ambient aura that brightens under stress or affection. Multiple ocular pupils continuously scan surrounding space, calculating 90-degree angles and vector lines in real-time.",
		"• [b]THE SYMMETRY TWITCH (Involuntary Realignment Reflex):[/b] Seeing any misaligned object (a tilted cup, stray paper, crooked collar) triggers an involuntary physical compulsion to reach out and align it to exact right angles.",
		"• [b]DISSONANT CHAOS REVULSION:[/b] Random noise, unexpected speech interruptions, or erratic movements trigger physical stiffness and involuntary vocal buzzing.",
		"• [b]GOLDEN-RATIO TACTILE TRACING:[/b] Under stress, excitement, or romantic interest, their fingers subconsciously trace perfect circles, equilateral triangles, and parallel lines across surfaces."
	],
	"Sea Monster": [
		"• [b]CLASSIFICATION & HABITAT:[/b] Pelagios Abyssalis / Abyssal Leviathan Folk. Native to submerged ocean trenches, saltwater reefs, and humid benthic caverns.",
		"• [b]ANCESTRAL CULTURAL LORE:[/b] They view life through tidal currents and deep-sea pressure dynamics. Free-spirited and fluid, they collect smooth sea-shells, beach glass, and bioluminescent stones as sacred ritual tokens.",
		"• [b]SALTWATER HYDRATION & DESICCATION VULNERABILITY:[/b] Epidermal scales require constant moisture and high salinity. Exposure to dry, arid air or hot desert sand causes rapid skin cracking, gill distress, and physical collapse. Claims of enjoying dry sand dunes are an immediate imposter slip.",
		"• [b]LATERAL LINE & ECHOLOCATION SONAR:[/b] Facial sensory pores and webbed digits detect micro-ripples in water and low-frequency acoustic vibrations in air. High-pitch screeching or dry static disrupts their equilibrium.",
		"• [b]BAROMETRIC PRESSURE FOG:[/b] Evolved for extreme abyssal depths. Rapid elevation changes cause transient atmospheric pressure adjustment, resulting in brief memory fog and spatial drifting.",
		"• [b]THE GILL FLARE REFLEX:[/b] Emotional surges (flirting, surprise, anxiety) trigger involuntary flaring of neck gill-slits and lateral ear-fins.",
		"• [b]FRESHWATER SPASM ANOMALY:[/b] Drinking pure distilled freshwater or eating unsalted food triggers immediate throat spasms and physical revulsion. They require heavy sea-salt or saline solutions.",
		"• [b]NEEDLE FANG & WEBBED DIGIT LOCK:[/b] Wide jaw structures house rows of razor-sharp needle fangs. Webbed hands subconsciously fiddle with sea-shells or water glass rim droplets when flustered."
	],
	"Spider": [
		"• [b]CLASSIFICATION & HABITAT:[/b] Arachneoid Sapiens / Spider Folk. Native to pitch-black subterranean caverns and high-altitude spires.",
		"• [b]ANCESTRAL CULTURAL LORE:[/b] They view the universe through structural geometry, governed by tension, balance, and devotion. Silk spinning is a sacred high art form.",
		"• [b]HIGH-PROTEIN HYDRATION DEPENDENCY:[/b] Silk production draws from internal spinneret organs, requiring raw meat, dense amino acids, and heavy hydration. Excessive spinning without nutrition causes severe abdominal cramping and physical fatigue.",
		"• [b]MICROSCOPIC SENSORY HAIRS (Trichobothria):[/b] Epidermal sensory hairs continuously detect subtle air currents, humidity shifts, and micro-vibrations.",
		"• [b]THERMAL SENSITIVITY & COLD BLOOD:[/b] Cold-blooded metabolism. Sudden heat sources or dry warmth dry out internal silk glands, triggering lethargy and motor sluggishness.",
		"• [b]THE VIBRATION REFLEX (Involuntary Lock-On):[/b] Sudden vibrations (table bump, chair scrape, pen click) trigger an involuntary twitch and dead-lock gaze toward the source.",
		"• [b]NERVOUS WEAVING (Subconscious Anchoring):[/b] Under stress, excitement, or attraction, fingers subconsciously spin, twist, and anchor fine silk threads onto nearby furniture.",
		"• [b]COURTSHIP & CANNIBALISTIC PRESERVATION:[/b] Insulting or failing an Arachneoid during intimacy triggers an uncontrollable biological instinct to paralyze, cocoon, and preserve the suitor for later consumption."
	]
}

func get_species_lore(species_name: String) -> Array:
	if species_lore_db.has(species_name):
		return species_lore_db[species_name]
	var lower_target = species_name.to_lower()
	for key in species_lore_db.keys():
		if key.to_lower() in lower_target or lower_target in key.to_lower():
			return species_lore_db[key]
	return []

func toggle_dev_mode_affection() -> void:
	dev_mode_show_affection = not dev_mode_show_affection
	dev_mode_toggled.emit(dev_mode_show_affection)
	print("[GameManager] Dev Mode Show Affection toggled to: ", dev_mode_show_affection)





func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F10:
			toggle_dev_mode_affection()
			get_viewport().set_input_as_handled()


func _ready() -> void:
	pass


## Call this to initialize a new game run
func start_new_game(available_monsters: Array[MonsterData]) -> void:
	MusicManager.set_mood_effect_enabled(false)
	all_monsters = available_monsters
	selected_candidates.clear()
	affection_scores.clear()
	discovered_clues.clear()
	dialogue_flags.clear()
	current_day = 1
	current_date_index = 0
	selected_accusation_id = ""
	selected_match_id = ""

	# Randomly pick 4 candidates out of the pool and shuffle their date order
	if available_monsters.size() >= 4:
		var pool = available_monsters.duplicate()
		pool.shuffle()
		for i in range(4):
			selected_candidates.append(pool[i])
		selected_candidates.shuffle()
	else:
		selected_candidates = available_monsters.duplicate()
		selected_candidates.shuffle()


	# Assign 1 of the selected candidates as The Count (Imposter)
	if selected_candidates.size() > 0:
		var rand_idx = randi() % selected_candidates.size()
		imposter_monster_id = selected_candidates[rand_idx].id
	else:
		imposter_monster_id = ""

	# Initialize affection scores
	for candidate in selected_candidates:
		affection_scores[candidate.id] = 40 # Base starting affection (40%)

	print("[GameManager] New Game Started!")
	print("[GameManager] Selected Candidates: ", selected_candidates.map(func(c): return c.id))
	print("[GameManager] Designated Imposter (The Count): ", imposter_monster_id)

## Returns true if candidate is secretly The Count
func is_imposter(candidate_id: String) -> bool:
	return candidate_id == imposter_monster_id

## Affection functions (Callable from dialogue_manager)
func get_affection(candidate_id: String) -> int:
	return affection_scores.get(candidate_id, 0)

func add_affection(candidate_id: String, amount: int) -> void:
	var current = get_affection(candidate_id)
	var new_score = clamp(current + amount, 0, 100)
	affection_scores[candidate_id] = new_score
	affection_changed.emit(candidate_id, new_score)
	print("[GameManager] Affection for ", candidate_id, " changed to: ", new_score)

func set_affection(candidate_id: String, score: int) -> void:
	var new_score = clamp(score, 0, 100)
	affection_scores[candidate_id] = new_score
	affection_changed.emit(candidate_id, new_score)

## Record clues discovered during dates (Callable from dialogue_manager)
func record_clue(candidate_id: String, clue_id: String, clue_text: String) -> void:
	if not has_clue(candidate_id, clue_id):
		var clue_data = {
			"candidate_id": candidate_id,
			"clue_id": clue_id,
			"text": clue_text,
			"day_found": current_day
		}
		discovered_clues.append(clue_data)
		clue_recorded.emit(candidate_id, clue_id, clue_text)
		print("[GameManager] Clue Discovered for ", candidate_id, ": [", clue_id, "] ", clue_text)

func has_clue(candidate_id: String, clue_id: String) -> bool:
	for clue in discovered_clues:
		if clue["candidate_id"] == candidate_id and clue["clue_id"] == clue_id:
			return true
	return false

## Active Date Management
func get_current_date_monster() -> MonsterData:
	if current_date_index >= 0 and current_date_index < selected_candidates.size():
		return selected_candidates[current_date_index]
	return null

func complete_current_date() -> void:
	MusicManager.set_mood_effect_enabled(false)
	var current_monster = get_current_date_monster()
	if current_monster:
		date_completed.emit(current_monster.id)

func advance_to_next_day() -> void:
	current_day += 1
	current_date_index += 1
	day_changed.emit(current_day)
	print("[GameManager] Advanced to Day ", current_day)

## Evaluates the 6 Endings on Day 5
func evaluate_ending() -> EndingType:
	var is_correct_accusation: bool = (selected_accusation_id == imposter_monster_id)
	var is_matching_imposter: bool = (selected_match_id == imposter_monster_id)
	var has_match: bool = (selected_match_id != "" and selected_match_id != "nobody")

	if is_correct_accusation:
		if is_matching_imposter:
			return EndingType.SECRET_ENDING_1 # Villain Romance
		elif has_match:
			return EndingType.BEST_ENDING     # Accused Count + Matched Innocent
		else:
			return EndingType.GOOD_ENDING     # Accused Count + No Match
	else:
		if is_matching_imposter:
			return EndingType.SECRET_ENDING_2 # Bonnie & Clyde Chaos Escape
		elif has_match:
			return EndingType.MIXED_ENDING    # Wrong Accusation + Matched Innocent
		else:
			return EndingType.BAD_ENDING      # Wrong Accusation + No Match
