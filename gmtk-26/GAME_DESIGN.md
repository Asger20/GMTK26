# 🕵️‍♂️ Operation: Countdown (Down with the Count)
*Game Design & Architecture Document*

---

## 📌 High Concept

A high-stakes, comedic horror speed-dating detective visual novel built for GMTK Game Jam 2026 in Godot 4.

You play as a secret police detective sent undercover into Blackwood Monster Asylum. Four rehabilitated monsters were scheduled to be released into society in five days. However, the asylum discovered that the dangerous inmate shapeshifter **"The Count"** killed one candidate and stole their identity in order to break out on release day!

To catch the killer before release day without causing a public panic, the police and asylum set up a fake speed-dating experiment (claiming monsters integrate better into society with a partner). You go undercover as an eligible date, armed with your trusty Monsterpedia book, to probe candidates for species lore slips, catch The Count before the five days are up... and perhaps even find true love along the way!




---

## ⏳ Game Structure & Timers

* **Macro Loop (5 Days)**:
  * **Days 1–4**: 4 monster candidates randomly selected out of the 6 total designed pool. 1 candidate per day.
  * **Day 5**: Accusation & Dating Match Phase.
* **Micro Loop (3-Minute Speed Dates)**:
  * Strict 180-second real-time countdown timer per date.
  * Player balances asking interrogation questions vs. building romantic rapport ("rizz").

---

## 💖 Affection & Interrogation Mechanics

1. **Low Affection Penalty**:
   * If affection is too low, candidate becomes annoyed/cold and **refuses to answer interrogation questions** (locks clue options).
2. **High Affection Reward**:
   * Unlocks deep, vulnerable dialogue choices exposing personal details needed to test against species lore.
3. **Match Eligibility**:
   * On Day 5, you can only match/romance candidates if you have reached their required affection threshold.

---

## 🎭 Imposter Mechanics ("The Count") & Efficient Dialogue Design

* **Appearance**: The Count physically mirrors the copied monster 100%.
* **The Flaw**: The Count does not know species instincts, dietary habits, or biological lore (e.g. Zombie craving hot sunlight).
* **Dialogue Workflow**:
  * ~90% of a monster's dialogue lines are shared and identical whether they are real or The Count.
  * ~5 specific key dialogue branches check `if GameManager.is_imposter(candidate_id):` to swap in the subtle "lore slip" responses.

### Dialogue Example (`dialogue_manager` syntax):
```dialogue
~ food_interrogation
Detective: What's your comfort food after a stressful day?
if GameManager.is_imposter("zombie"):
	Zombie: Oh, a piping hot bowl of soup eaten on a sunny balcony!
	do GameManager.record_clue("zombie_sunlight_slip")
else:
	Zombie: Cold, decaying leftovers in a dark basement. Bright light makes my skin peel.
```

---

## 🏆 6 Endings Matrix

| # | Ending Name | Accusation Target | Dating Match Target | Outcome Description |
|---|---|---|---|---|
| 1 | **Bad Ending** | Wrong Candidate | Nobody | The Count escapes into society. |
| 2 | **Mixed Ending** | Wrong Candidate | Innocent Monster | The Count escapes, but you found love with an innocent monster. |
| 3 | **Good Ending** | The Count | Nobody | You successfully arrest The Count. |
| 4 | **Best Ending** | The Count | Innocent Monster | You arrest The Count AND match with your monster date! |
| 5 | **Secret Ending 1** | The Count | The Count | You arrest/rizz up The Count directly. |
| 6 | **Secret Ending 2** | Wrong Candidate | The Count | **Chaos / Bonnie & Clyde**: The Count frames an innocent, escapes, and takes you along as partner-in-crime! |

---

## 👹 Candidate Pool (Monster Species & IDs)

* Candidate IDs in code strictly use species names (e.g., `zombie`, `vampire`, `slime`, `angel`, `sea_monster`).

| Monster ID | Species | Personality / Disorder Trait | True Lore (Monsterpedia Rule) | Imposter Slip |
|---|---|---|---|---|
| `zombie` | Zombie | Depression | Loves cold/rotting food; hates warmth & bright sun. | Enjoys hot food / basking in sunlight. |
| `vampire` | Vampire | Obsessive / Stalker | Snobbish about vintage blood types; strictly nocturnal. | Confuses blood flavor notes / likes early morning sun. |
| `slime` | Slime / Swamp | Social Anxiety | Craves damp/muddy spaces; stores items inside body. | Disgusted by mud / finds internal item storage weird. |
| `angel` | Biblical Angel | OCD | Obsessed with divine geometry, symmetry, & strict order. | Comfortable in messy or chaotic spaces. |
| `sea_monster` | Sea Monster | TBD | Deep knowledge of ocean depth pressure & saltwater. | Confuses ocean biology / prefers dry desert climates. |
| `monster_6` | TBD | TBD | TBD | TBD |

---

## 🛠️ Code Architecture Overview

* `res://scripts/autoload/game_manager.gd`: Autoload singleton tracking Days 1–5, selected candidate pool, imposter assignment, affection levels, clues, and ending router.
* `res://scripts/resources/monster_data.gd`: Custom Resource script for candidate data.
* `res://scripts/ui/monsterpedia_ui.gd`: In-game field guide UI.
* `res://scenes/date_scene.tscn`: 3-minute countdown clock & dialogue interface.
* `res://scenes/accusation_scene.tscn`: Day 5 final decision & endings screen.
