# 🕵️‍♂️ Operation: Countdown (Down with the Count)
*Game Design & Architecture Document*

---

## 📌 High Concept

A comedic horror speed-dating detective visual novel built for GMTK Game Jam 2026 in Godot 4.

You play as a secret police detective sent undercover into Blackwood Monster Asylum. Four rehabilitated monsters were scheduled to be released into society in five days. However, the asylum discovered that the dangerous inmate shapeshifter **"The Count"** killed one candidate and took their place in order to break out on release day!

To catch the killer before release day without causing a public panic, the police and asylum set up a fake speed-dating experiment (claiming monsters integrate better into society with a partner). You go undercover as an eligible date, armed with your trusty Monsterpedia book, to probe candidates for species lore slips, catch The Count before the five days are up... and perhaps even find true love along the way!

---

## 🎬 Opening Cutscene & Narrative Dossier

* **Animated Parchment Panel**: The game opens with an animated dossier on an aged yellowish paper scroll (`PaperPanel`), sliding smoothly into view with a custom Godot 4 `Tween`.
* **Case Briefing Structure**: Structured into scannable sections (`LOCATION`, `SITUATION`, `THE COVER-UP`, `YOUR MISSION`).
* **Keyboard-Only Skip**: Pressing any key on the keyboard skips the cutscene immediately and proceeds to Day 1. Mouse clicks are excluded to prevent accidental skips.

---

## 🛠️ Global Dev Mode (F10 Hotkey)

* **Toggle Hotkey**: Pressing **`F10`** at any point in the game toggles Dev Mode globally via high-priority input handling in `GameManager`.
* **Default State**: Disabled (`dev_mode_show_affection = false`) by default for an un-hinted, immersive visual novel experience.
* **Global Persistence**: The Dev Mode setting persists continuously across date transitions, break phases, and fresh game runs until `F10` is pressed again.
* **Dev Mode Effects**:
  * **Dev Mode OFF**: Choice affection delta indicators (e.g. `+15 Affection`) AND the top HUD Affection Bar (%) are completely hidden.
  * **Dev Mode ON**: Choice affection delta indicators AND top HUD Affection Bar (%) are visible in real-time.

---

## ⏳ Game Structure & Timers

* **Macro Loop (5 Days)**:
  * **Phase 0 (Intro)**: Animated Case Dossier cutscene.
  * **Days 1-4**: 4 monster candidates randomly selected out of the 6 total designed pool (1 date per day, 3-minute timer).
  * **Break Phases**: End-of-date reflection summary & Monsterpedia study time.
  * **Day 5**: Final Accusation & Romance Match Phase.
* **Micro Loop (3-Minute Speed Dates)**:
  * Strict 180-second real-time countdown timer per date.
  * Player balances asking interrogation questions vs. building romantic rapport.

---

## 💖 Affection & Interrogation Mechanics

1. **Low Affection Penalty**:
   * If affection drops below 35%, candidate becomes annoyed/cold and **refuses to answer interrogation questions** (locks clue options).
2. **High Affection Reward**:
   * Unlocks deep, vulnerable dialogue choices exposing personal details needed to test against species lore.
3. **Match Eligibility**:
   * On Day 5, you can only match/romance candidates if you have reached their required affection threshold (e.g. 50%).

---

## 🗣️ Undercover Narrative & Dialogue Design

* **Undercover Identity**: Dates do NOT know you are a detective. They address you as a fellow candidate / date (e.g., "my sweet date", "delicate date", "cutie"). Speaker tag for player choices is `You:`.
* **Natural Phrasing**: All dialogue options use pure natural language phrasing (no emojis or meta tags like `(Lore Check)`).
* **Smart Imposter Dialogue Workflow**:
  * ~90% of a monster's dialogue lines are shared whether they are real or The Count.
  * ~5 specific key dialogue branches check `if GameManager.is_imposter(candidate_id):` to swap in subtle "lore slip" responses.

### Dialogue Example (`dialogue_manager` syntax):
```dialogue
~ food_interrogation
if GameManager.get_affection("zombie") < 35:
    Zombie: I'm not really in the mood to answer your questions right now.
    => main_menu
else:
    You: What's your absolute comfort meal after a long day?
    if GameManager.is_imposter("zombie"):
        Zombie: Oh, easy! A piping hot bowl of fresh vegetable soup eaten outside on a sunny porch!
        do GameManager.record_clue("zombie", "hot_food_slip", "Claims to love piping hot soup outdoors in the sun.")
    else:
        Zombie: Cold, decaying leftovers... eaten in a dark room. Hot food makes my stomach rot.
    => main_menu
```

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

## 👹 Candidate Pool & Dialogue Resources

| Monster ID | Species | Personality Trait | True Lore (Monsterpedia Rule) | Imposter Slip | Dialogue File |
|---|---|---|---|---|---|
| `zombie` | Zombie | Depression / Melancholy | Loves cold/rotting food; hates warmth & bright sun. | Enjoys hot food / basking in afternoon sunlight. | `res://assets/dialogues/zombie.dialogue` |
| `vampire` | Vampire | Theatrical / Stalker | Snobbish about vintage blood; strictly nocturnal. | Confuses blood flavors / boasts about 6 AM sunrises. | `res://assets/dialogues/vampire.dialogue` |
| `slime` | Slime | Social Anxiety | Craves damp mud; stores items inside body cavity. | Disgusted by mud / finds internal item storage weird. | `res://assets/dialogues/slime.dialogue` |
| `angel` | Angel | OCD / Order | Obsessed with divine geometry, symmetry, & strict order. | Comfortable in messy or chaotic spaces. | `res://assets/dialogues/sample_monster.dialogue` |
| `sea_monster` | Sea Monster | TBD | Deep knowledge of ocean depth pressure & saltwater. | Confuses ocean biology / prefers dry desert climates. | `res://assets/dialogues/sample_monster.dialogue` |

---

## 🛠️ Code Architecture Overview

* `res://scripts/autoload/game_manager.gd`: Autoload singleton tracking Days 1-5, selected candidate pool, imposter assignment, affection levels, clues, dev mode state (`F10`), and ending evaluator.
* `res://scripts/resources/monster_data.gd`: Custom Resource script for candidate data.
* `res://scripts/main_game.gd` & `res://scenes/main_game.tscn`: Main game scene managing opening dossier cutscene, prep screens, 3-minute date timers, HUD, break phases, and Day 5 accusation/endings.
* `res://scripts/ui/monsterpedia_ui.gd`: In-game field guide & evidence notebook UI.
