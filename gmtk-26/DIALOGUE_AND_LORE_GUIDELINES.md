# 📜 Character Dialogue, Lore & Imposter Writing Guidelines

This document establishes the universal narrative design standards, writing guidelines, and Dialogue Manager syntax patterns for creating character date encounters, species lore, and imposter clue mechanics in **Operation: Countdown (Down with the Count)**.

---

## 📌 1. Core Narrative Principles

### 1.1 Undercover Date Identity
* **Player Identity**: You are a secret police detective undercover as a suitor. Candidates do **not** know you are a detective.
* **Tone & Framing**: Candidates address you as an eligible date (e.g., *"my sweet date"*, *"delicate suitor"*, *"cutie"*). The detective must balance genuine romantic rapport with subtle, inquisitive probing.
* **Player Speaker Tag**: Player dialogue choices are tagged with `You:` in dialogue scripts.

### 1.2 Natural Language Choices (No Meta-Clutter)
* **Pure In-Character Text**: Dialogue choices must **never** contain meta indicators, emojis, or stat clutter (e.g., avoid `(+15 Affection)`, `(-10 Affection)`, or `[Lore Check]`).
* **Subtle Intent**: The intent of a response (flattering, probing, teasing, cold) must be clear from the natural phrasing of the sentence itself.

---

## 💖 2. Affection Mechanics & Low Affection Gating

### 2.1 Affection Thresholds & Rules
* **Starting Affection**: All candidates begin dates at a baseline affection score of **40%**.
* **Match Requirement**: A minimum affection score of **80%** is required on Day 5 to successfully romance a candidate.
* **Low Affection Gating (< 35%)**:
  * If affection drops below **35%**, the candidate becomes guarded, cold, or suspicious.
  * They will **refuse to answer deep interrogation topics** (e.g., *"Why are you asking so many intrusive questions?"*, *"I don't trust where this is going"*), redirecting the player back to the main menu without yielding clues.

### 2.2 Dialogue Script Syntax for Affection Checks
```dialogue
~ deep_interrogation_topic
if GameManager.get_affection("candidate_id") < 35:
	do GameManager.set_expression("scary")
	Candidate: *Arms crossed, tone guarded* You're asking a lot of personal questions all of a sudden. I'd rather not talk about this right now.
	=> main_hub
else:
	You: What happens if your body is exposed to extreme temperatures?
	=> resolution_branch
```

---

## 🕵️‍♂️ 3. Authentic Species Lore vs. Imposter Slips

### 3.1 The Imposter (The Count) Writing Strategy
* **~90% Shared Persona**: The Count has thoroughly researched the candidate's personality and mimics their general speech patterns, warmth, and baseline hobbies.
* **The Fatal Flaw (Generic "Human" Normalcy)**:
  * **Authentic Monster**: Has mandatory biological, anatomical, environmental, or psychological constraints (e.g., rigid cold-blood metabolism, high-protein spinneret cramp risks, acoustic sonar sensitivity, UV skin necrosis).
  * **The Imposter**: Unaware of subtle, high-detail biological constraints, The Count defaults to casual, generic, surface-level "human" answers (*"I just eat whatever three meals are on the menu"*, *"I sleep 8 hours straight through until morning"*, *"I'm pretty easygoing with warm temperatures"*).

### 3.2 Recording Evidence Clues
When the imposter branch executes, always record a descriptive clue into the player's **Evidence Notebook**:
```dialogue
if GameManager.is_imposter("candidate_id"):
	do GameManager.set_expression("happy")
	Candidate: *Tilts head with a casual shrug* Oh, food? I don't bother with any strict diet! I just eat whatever three standard meals the cafeteria serves.
	do GameManager.record_clue("candidate_id", "nutrition_slip", "Defaults to a generic answer about eating 3 standard meals without mentioning raw protein or heavy hydration needs.")
	Candidate: As long as I get three regular meals, my energy is fine!
else:
	do GameManager.set_expression("normal")
	Candidate: Silk draws massive amounts of protein directly from our internal glands. If I don't eat heavy raw protein, my abdomen gets agonizing muscle cramps.
```

---

## 🎭 4. Real-Time Character Expression Swaps

Characters feature dynamic expression portrait updates triggered directly within the dialogue script using `do GameManager.set_expression("...")`.

### 4.1 Supported Expression Names
1. `"normal"` — Default neutral posture and standard conversation state.
2. `"happy"` — Excited, laughing, energetic, or enthusiastic responses.
3. `"blush"` — Flustered, embarrassed, romantically touched, or timid state.
4. `"angry"` — Offended, annoyed, defensive, or frustrated responses.
5. `"scary"` — Guarded, suspicious, intense, or baring teeth/fangs.

### 4.2 Best Practice for Expression Triggers
* Call `set_expression` at the beginning of major dialogue nodes and immediately before dramatic emotional shifts in conversation.
* Always return to `"normal"` or `"happy"` when returning to `~ main_hub`.

```dialogue
- "You look amazingly energetic tonight."
	do GameManager.add_affection("candidate_id", 15)
	do GameManager.set_expression("blush")
	Candidate: *Cheeks turn soft pink, smiling timidly* Really?! You... you don't find it overwhelming?
	=> main_hub
```

---

## 🌲 5. Dialogue Hub Structure & Flag Tracking

To prevent choice menu clutter and ensure dates feel responsive and structured, dialogues utilize a central hub (`~ main_hub`) with state flags.

### 5.1 Max 4 Options Constraint
The custom visual novel balloon engine enforces a maximum of **4 choice options visible at a time**. Use flag checks to hide completed topics.

### 5.2 Hub & Gated Unlocks Pattern
```dialogue
~ main_hub
do GameManager.set_expression("normal")

# Wrap-up check: If all topics are completed, offer exit
if GameManager.has_flag("candidate_id", "asked_topic_a") and GameManager.has_flag("candidate_id", "asked_topic_b") and GameManager.has_flag("candidate_id", "asked_topic_c"):
	Candidate: Wow... I feel like we've talked about almost everything on my mind!
	- "I had a wonderful time talking with you."
		do GameManager.add_affection("candidate_id", 10)
		=> end_date
	- "That's all the answers I need for today."
		=> end_date
else:
	Candidate: So! What else were you curious about?

	# Basic topics available initially
	- "Tell me about your creative projects." [if not GameManager.has_flag("candidate_id", "asked_topic_a")]
		=> topic_a

	- "How do you handle long days?" [if not GameManager.has_flag("candidate_id", "asked_topic_b")]
		=> topic_b

	# Gated unlock: Requires topic_a to be completed first
	- "What happens when the room gets warm?" [if GameManager.has_flag("candidate_id", "asked_topic_a") and not GameManager.has_flag("candidate_id", "asked_topic_c")]
		=> topic_c

	- "I think I've learned enough for today."
		=> end_date
```

---

## 🛠️ 6. Dialogue Manager Technical Checklist

When writing or editing any `.dialogue` file, verify:

1. **Node Headers**: Every node begins with `~ nodename`.
2. **GameManager Mutations**:
   * Affection adjustments: `do GameManager.add_affection("candidate_id", amount)`
   * Expression swaps: `do GameManager.set_expression("expression_name")`
   * Topic flags: `do GameManager.set_flag("candidate_id", "flag_name")`
   * Clue recording: `do GameManager.record_clue("candidate_id", "clue_id", "Clue description text")`
3. **Date Completion**: The `~ end_date` node must execute `do GameManager.complete_current_date()` followed by `=> END`.
