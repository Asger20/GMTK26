extends Node

signal day_changed(new_day: int)
signal affection_changed(candidate_id: String, new_score: int)
signal clue_recorded(candidate_id: String, clue_id: String, text: String)
signal date_completed(candidate_id: String)

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

# Day 5 Decision Choices
var selected_accusation_id: String = ""
var selected_match_id: String = ""

func _ready() -> void:
	pass

## Call this to initialize a new game run
func start_new_game(available_monsters: Array[MonsterData]) -> void:
	all_monsters = available_monsters
	selected_candidates.clear()
	affection_scores.clear()
	discovered_clues.clear()
	current_day = 1
	current_date_index = 0
	selected_accusation_id = ""
	selected_match_id = ""

	# Randomly pick 4 candidates if we have at least 4 available
	if available_monsters.size() >= 4:
		var pool = available_monsters.duplicate()
		pool.shuffle()
		for i in range(4):
			selected_candidates.append(pool[i])
	else:
		selected_candidates = available_monsters.duplicate()

	# Assign 1 of the selected candidates as The Count (Imposter)
	if selected_candidates.size() > 0:
		var rand_idx = randi() % selected_candidates.size()
		imposter_monster_id = selected_candidates[rand_idx].id
	else:
		imposter_monster_id = ""

	# Initialize affection scores
	for candidate in selected_candidates:
		affection_scores[candidate.id] = 50 # Base starting affection

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
