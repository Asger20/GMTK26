# 🕵️‍♂️ Operation: Countdown (Down with the Count)
*Game Design & Architecture Document*

---

## 📌 High Concept

A comedic horror dating detective visual novel built for GMTK Game Jam 2026 in Godot 4.

You play as a secret police detective sent undercover into Blackwood Monster Asylum. Four rehabilitated monsters are scheduled to be released into society in five days. However, the asylum discovered that the dangerous inmate shapeshifter **"The Count"** killed one candidate and took their place in order to break out on release day!

To catch the killer before release day without causing a public panic, the police and asylum set up a fake dating experiment (claiming monsters integrate better into society with a partner). You go undercover as an eligible date, armed with your trusty Monsterpedia book, to probe candidates for species lore slips, catch The Count before the five days are up... and perhaps even find true love along the way!

---

## 🎬 Opening Cutscene & Narrative Dossier

* **Animated Parchment Panel**: The game opens with an animated dossier on an aged yellowish paper scroll (`PaperPanel`), sliding smoothly into view with a custom Godot 4 `Tween`.
* **Case Briefing Structure**: Structured into scannable sections (`LOCATION`, `SITUATION`, `THE COVER-UP`, `YOUR MISSION`).
* **Keyboard-Only Skip**: Pressing any key on the keyboard skips the cutscene immediately and proceeds to Day 1. Mouse clicks are excluded to prevent accidental skips.

---

## 🕵️‍♂️ Preparation Phase (Rehab Case Dossier)

* **Asylum Dossier Folder**: Styled as a physical Blackwood Asylum rehabilitation case folder with warm parchment paper (`#e4d9b7`) and asylum crimson borders (`#5c1f1f`).
* **Candidate Dossier Layout**:
  * **Header**: `BLACKWOOD ASYLUM - CANDIDATE DOSSIER`
  * **`Candidate Name:`**: Candidate's display name.
  * **`Species:`**: Candidate's species.
  * **`Description (Self-Written Bio):`**: Personal self-description written by the candidate in quotes and italics.
  * **`NOTE TO DETECTIVE:`**: Prompts the player to use their **📖 Monsterpedia** book at the bottom-left to cross-reference species traits during dates.
* **Action Button**: Leather/gold asylum action button `[ ENTER DATE ]`.

---

## 🎭 Visual Novel Date UI, Art & Expressions

* **Enlarged Character Portrait & Hip-Up Framing**:
  * Character portrait (`MonsterPortrait`) is enlarged to **540×540 pixels** and anchored from the hips upwards, presenting a prominent, detailed view of candidates.
  * Features a continuous floating/breathing idle animation (`Tween` vertical bobbing).
* **Real-Time Expression Swapping**:
  * Dialogue lines trigger real-time expression shifts on character portraits via `do GameManager.set_expression("...")` (supporting `normal`, `happy`, `blush`, `angry`, and `scary` states).
* **Unified Dialogue Box & Dynamic State Switching**:
  * Both speech lines and choice options share a single bottom dialogue panel (`DialogueBox` styled with solid dark leather `#120f0c` and gold trim `#c99738`).
  * **State 1 (Monster Speaking)**: Monster's spoken line types out in warm parchment (`#f0e2b8`) with choice menu hidden.
  * **State 2 (Player Reading Pacing)**: Speech text remains visible after typing with `[ CLICK TO CONTINUE ▶ ]`.
  * **State 3 (Player Choice Menu)**: Clicking switches the box to display response options, strictly capped at **maximum 4 choices** at a time.
  * **Interactive Text**: Clicking directly on spoken text skips typing or advances lines.
* **Player-Paced Dates & Early Exit**:
  * Dates proceed at player pace.
  * Dedicated **`🛑 END DATE EARLY`** button positioned at the bottom-right corner to finish a date at any time (automatically hidden during screen transitions).

---

## 🎬 Cinematic Transitions & Room Shuffle

* **Pitch-Black Day Countdown Transition**:
  * Transitions between days feature a pitch-black screen with two dead-centered text lines:
    ```text
    5 Days
    till release
    ```
  * Uses a large 88px bold day font with a light-grey 26px subtitle below.
  * Mid-game day changes feature a slow, heavy vertical scroll animation between old and new day numbers.
* **Date Entrance & Exit Transitions**:
  * Uses the same dark transition style when entering a date (`"Date Start"` / `"[Candidate Name] ([Species])"`) and exiting a date (`"Date Complete"`).
  * Complete input blocking prevents UI or game interaction while transition animations play.
* **No-Repeat Random Date Room Backgrounds**:
  * Preloaded with four asylum date room variations (`asylum_room_1.jpg` through `asylum_room_4.jpg`).
  * Uses a non-repeating shuffled deck so no date room background is repeated within a game run.

---

## 🛠️ Global Dev Mode (F10 Hotkey) & Cheat Control Panel

* **Toggle Hotkey**: Pressing **`F10`** at any point in the game toggles Dev Mode globally via high-priority input handling in `GameManager`.
* **Default State**: Disabled (`dev_mode_show_affection = false`) by default for an un-hinted, immersive visual novel experience.
* **Global Persistence**: Persists continuously across date transitions, break phases, and fresh game runs.
* **Dev Features**:
  * **Dev Mode OFF**: Affection indicators and top HUD Affection Bar text are hidden.
  * **Dev Mode ON**: Affection score displays as a single clean percentage number on the HUD.
  * **Bottom-Right Button Stacking**: Clicking **`🛠️ DEV CHEATS`** opens a solid slate inspector panel (`DevCheatOverlay`) listing the active candidate lineup, designated imposter identity, date/day jump triggers, affection adjusters, and session reset button. Stacked directly above `🛑 END DATE EARLY`.

---

## 📖 Monsterpedia Field Guide & Evidence Notebook

* **Custom Visual Book Icon**: Anchored at the bottom-left of the screen using `assets/monsters/monsterpedia.png` with a gold **`Monsterpedia`** label underneath.
* **Solid Non-Transparent Overlay**: Opens a solid dark leather field book (`MonsterpediaOverlay`) with tabs for:
  * **Species Lore**: Master database rules and ancestral lore for all monster species.
  * **Evidence Notebook**: Log of all discovered clues and lore slips recorded during dates.
* **Auto-Select Active Candidate**: Opening the Monsterpedia during a date automatically selects the active candidate's species lore tab.

---

## ⏳ Game Structure (5 Days & 4 Candidates)

* **Candidate Roster (4 Patients)**: Each game run features 4 candidate patients (**Percival**, **Isaac**, **Sienna**, **Lily**). One candidate is randomly assigned as **The Count**.
* **Macro Loop (5 Days)**:
  * **Phase 0 (Intro)**: Animated Case Dossier cutscene.
  * **Days 1-4**: Date with Candidate 1..4 (player-paced).
  * **Break Phases**: End-of-date reflection summary & Monsterpedia study time.
  * **Day 5**: Final Accusation & Romance Match Phase.

---

## 💖 Affection & Interrogation Mechanics

1. **Starting Affection**: All candidates begin with a default starting affection score of **40%**.
2. **Low Affection Penalty**:
   * If affection drops below 35%, candidate becomes annoyed/cold and **refuses to answer interrogation questions** (locks clue options).
3. **High Affection Reward**:
   * Unlocks deep, vulnerable dialogue choices exposing personal details needed to test against species lore.
4. **Match Threshold**:
   * On Day 5, a minimum affection score of **80%** is required to successfully match/romance a candidate.

---

## 🗣️ Undercover Narrative & Dialogue Design

* **Undercover Identity**: Dates do NOT know you are a detective. They address you as a fellow candidate / date (e.g., "my sweet date", "delicate date"). Speaker tag for player choices is `You:`.
* **Clean Dialogue Options**: All dialogue choices use clean natural language phrasing without hardcoded modifier clutters like `(+15 Affection)`.
* **Smart Imposter Dialogue Workflow**:
  * ~90% of a monster's dialogue lines are shared whether they are real or The Count.
  * ~5 specific key dialogue branches check `if GameManager.is_imposter(candidate_id):` to swap in subtle "lore slip" responses.

---

## 🏆 6 Endings Matrix

| # | Ending Name | Accusation Target | Dating Match Target | Outcome Description |
|---|---|---|---|---|
| 1 | **Bad Ending** | Wrong Candidate | Nobody | The Count escapes into society. |
| 2 | **Mixed Ending** | Wrong Candidate | Innocent Monster | The Count escapes, but you found love with an innocent monster. |
| 3 | **Good Ending** | The Count | Nobody | You successfully arrest The Count. |
| 4 | **Best Ending** | The Count | Innocent Monster | You arrest The Count AND match with your monster date! |
| 5 | **Secret Ending 1** | The Count | The Count | **Villain Romance**: You arrest/rizz up The Count directly. |
| 6 | **Secret Ending 2** | Wrong Candidate | The Count | **Bonnie & Clyde Escape**: You frame an innocent, and escape WITH The Count as partner-in-crime! |

---

## 👹 Candidate Roster & Dialogue Resources (4 Monsters)

| Monster ID | Display Name | Species | Personality & Vulnerable Bio Trait | True Lore (Monsterpedia Rule) | Imposter Slip | Dialogue File |
|---|---|---|---|---|---|---|
| `vampire` | **Percival** | Vampire | Snobbish, theatrical, gothic sonnets & vintage red drinks | Hematophagous diet; strictly nocturnal; silver/garlic vulnerability. | Boasts about 6 AM sunrises / loves garlic bread. | `res://assets/dialogues/vampire.dialogue` |
| `angel` | **Isaac** | Biblical Angel | Perfectionist, OCD, 90° order & harmonic frequency | Bound to absolute geometry & symmetry; multi-harmonic chords. | Claims to love messy, asymmetrical, chaotic rooms. | `res://assets/dialogues/angel.dialogue` |
| `sea_monster` | **Sienna** | Sea Monster | Free-spirited, forgetful, shell collector, ocean lover | Abyssal pressure adaptation; saltwater hydration dependency. | Claims to love baking hot dry desert sand dunes. | `res://assets/dialogues/sea_monster.dialogue` |
| `bug_monster` | **Lily** | Spider | Insomniac night owl, hyper-focused weaver, loyal protector | Arachneoid geometry; silk hydration needs; vibration reflex. | Claims to sleep 10 uninterrupted hours every night. | `res://assets/dialogues/bug_monster.dialogue` |

---

## 🛠️ Code Architecture Overview

* `res://scripts/autoload/game_manager.gd`: Autoload singleton tracking Days 1-5, selected candidate pool, imposter assignment, affection levels, clues, dev mode state (`F10`), master species lore DB, dynamic expression signals, and ending evaluator.
* `res://scripts/main_game.gd` & `res://scenes/main_game.tscn`: Main game scene and Phase Coordinator managing opening cutscene, prep screens, date phases, HUD, dark transition overlays, room background shuffling, and Day 5 accusation/endings.
* `res://scripts/resources/monster_data.gd`: Custom Resource data model storing monster metadata, lore, dialogue resources, and expression texture dictionaries.
* `res://scripts/ui/monsterpedia_overlay.gd`: Sub-component UI controller for Monsterpedia field guide & evidence notebook with auto-selection of active candidates.
* `res://scripts/ui/dev_cheat_overlay.gd`: Sub-component UI controller for F10 Dev Cheat control panel, dynamically listing active candidate lineups.
* `res://scripts/custom_balloon.gd` & `res://scenes/custom_balloon.tscn`: Custom Visual Novel speech balloon & choice menu with max 4 options constraint and dynamic in-and-out switching.
