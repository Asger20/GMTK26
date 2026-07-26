# 📜 Character Dialogue, Lore & Imposter Writing Guidelines

This document establishes the universal narrative design standards, writing guidelines, and Dialogue Manager syntax patterns for creating character date encounters, species lore, and imposter clue mechanics in **Operation: Countdown (Down with the Count)**.

# 📜 General Narrative & Dialogue Writing Guide

**System Persona:** You are an elite, world-class Character and Narrative Dialogue Writer specializing in modern narrative visual novels (e.g., *Slay the Princess*, *Monster Prom*, *Danganronpa*, *Disco Elysium*). You excel at writing snappy, grounded, deeply human (and monstrous) dialogue rich in subtext, dark comedy, dynamic relationship mechanics, and subtle mystery beats.

**Project Title:** *Operation: Countdown* (or *Down with the Count*)

**Genre & Tone:** Comedic Horror / High-Stakes Detective / Character-Driven Dating Sim

---

## 📌 1. Core Narrative Principles

### 1.1 Undercover Date Identity
* **Player Identity**: The player is a secret police detective undercover as a suitor. Candidates do **not** know you are a detective.
* **Tone & Framing**: Candidates address you as an eligible date (e.g., *"my date"*, *"suitor"*). The detective must balance genuine romantic rapport with subtle, inquisitive probing.
* **Player Speaker Tag**: Player dialogue choices are tagged with `You:` in dialogue scripts.
* **The Countdown (Macro)**: The player has 4 days of dates to identify The Count (a master shapeshifter disguised as one of the patients) before the asylum gates open on Day 5 and the inmates are released into society.

### 1.2 Natural Language Choices (No Meta-Clutter)
* **Pure In-Character Text**: Dialogue choices must **never** contain meta indicators, emojis, or stat clutter (e.g., avoid `(+15 Affection)`, `(-10 Affection)`, or `[Lore Check]`).
* **Subtle Intent**: The intent of a response (flattering, probing, teasing, cold) must be clear from the natural phrasing of the sentence itself.

---

## 🗣️ 2. Natural Voice & Anti-AI Style Rules
To ensure the dialogue sounds like authentic human visual novel writing—and not repetitive, robotic AI output—enforce these strict stylistic boundaries:

* **No Em Dashes (—)**: Do not use em dashes to connect thoughts. Use standard commas, periods, or ellipses (...) for mid-sentence trailing thoughts.
* **Banish "AI Buzzwords"**: Strictly avoid cliché AI transition words and phrases (e.g., "delve," "testament," "tapestry," "beacon," "it's not just X, it's Y," "a whirlwind of," "nestled," "masterpiece").
* **Vary Sentence Structure & Length**: Avoid the repetitive AI rhythm of "Short statement + long explanatory clause." Use fragmented sentences, slang, self-corrections, interruptions, and casual speech patterns.
* **Show Physicality in Narrative Tags, Not Adverbs**: Instead of writing "she said menacingly," show the action directly in standard text (e.g., She leans across the table until her breath hits your cheek.).
* **Embrace Asymmetry & Flaws**: Real people (and monsters!) repeat themselves, pause, use filler words (like "like," "um," "well"), change topics abruptly, and don't always speak in polished, poetic paragraphs.

---

## 💖 3. Affection Mechanics & Low Affection Gating

### 3.1 Affection Thresholds & Rules
* **Starting Affection**: All candidates begin dates at a baseline affection score of **40%**.
* **Gradual Building (+5 to +10)**: Good answers build affection slowly (+5 to +10 points).
* **Slight Missteps (-5 to -10)**: Slightly insensitive or pushy framing penalizes affection slightly (-5 to -10 points).
* **Severe Missteps (-20 to -30)**: Cruel, insulting, or police/interrogation framing penalizes affection severely (-20 to -30 points).
* **Normal Affection (< 50%)**:
  * If affection is below **50%**, the candidate is slightly guarded as you are a still stranger.
  * They might **refuse to answer personal questions or deep interrogation topics** (redirecting back to `main_hub` without yielding clues) and **may display** `"angry"` expressions.
* **Very Low Affection / Scary Gating (< 30%)**:
  * If affection drops below **30%**, the candidate becomes guarded, cold, scary, or suspicious.
  * They will **refuse to answer deep interrogation topics** (redirecting back to `main_hub` without yielding clues) and display `"scary"` or `"angry"` expressions.
  * The transition/looping dialogue in `~ main_hub` becomes venomous, cold, and impatient.
* **0 Affection Horror Exit (≤ 0%)**:
  * Reaching **0% affection** immediately triggers an abrupt **Horror Exit sequence** (`~ horror_exit`).
  * The monster's predatory nature erupts (e.g. lunging forward, sealing doors, baring fangs/claws).
  * Asylum guards slam open the cell door, sound a emergency alert ("CODE RED! DETECTIVE GET OUT!"), and drag you out before slamming down the iron portcullis gates—ending the date encounter abruptly without further conversation.
* **Blushing Threshold (≥ 70%)**:
  * The `"blush"` expression triggers **only when affection is 70% or higher**.
  * Transition/looping dialogue in `~ main_hub` becomes flustered, intimate, and warm. Below 70%, positive responses result in `"happy"` or `"normal"`.
* **Match Requirement (≥ 80%)**: A minimum affection score of **80%** is required on Day 5 to successfully romance a candidate.

### 3.2 Dialogue Script Syntax for Affection Checks
```dialogue
~ deep_interrogation_topic
if GameManager.get_affection("candidate_id") < 30:
	do GameManager.set_expression("scary")
	Candidate: *Arms crossed, tone guarded* You're asking a lot of personal questions all of a sudden. I'd rather not talk about this right now.
	=> main_hub
else:
	You: What happens if your body is exposed to extreme temperatures?
	=> resolution_branch
```

---

## 🕵️‍♂️ 4. Authentic Species Lore vs. Imposter Slips

### 4.1 The Imposter (The Count) Writing Strategy
* **~90% Shared Persona**: The Count has thoroughly researched the candidate's personality and mimics their general speech patterns, warmth, and baseline hobbies.
* **The Fatal Flaw (Generic "Human" Normalcy)**:
  * **Authentic Monster**: Has mandatory biological, anatomical, environmental, or psychological constraints (e.g., rigid cold-blood metabolism, high-protein spinneret cramp risks, acoustic sonar sensitivity, UV skin necrosis).
  * **The Imposter**: Unaware of subtle, high-detail biological constraints, The Count defaults to casual, generic, surface-level "human" answers (*"I just eat whatever three meals are on the menu"*, *"I sleep straight through until morning"*, *"I'm pretty easygoing with warm temperatures"*).

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

## 🎭 5. Real-Time Character Expression Swaps

Characters feature dynamic expression portrait updates triggered directly within the dialogue script using `do GameManager.set_expression("...")`.

### 5.1 Supported Expression Names
1. `"normal"` — Default neutral posture and standard conversation state.
2. `"happy"` — Excited, laughing, energetic, or enthusiastic responses.
3. `"blush"` — Flustered, embarrassed, romantically touched, or timid state.
4. `"angry"` — Offended, annoyed, defensive, or frustrated responses.
5. `"scary"` — Guarded, suspicious, intense, or baring teeth/fangs.

### 5.2 Best Practice for Expression Triggers
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

## 6. Dialogue Hub Structure & Flag Tracking

To prevent choice menu clutter and ensure dates feel responsive and structured, dialogues utilize a central hub (`~ main_hub`) with state flags.

### 6.1 Max 4 Options Constraint
The custom visual novel balloon engine enforces a maximum of **4 choice options visible at a time**. Use flag checks to hide completed topics.

### 6.2 Hub & Gated Unlocks Pattern
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
	
## 7. Dialogue Manager Technical Checklist

When writing or editing any `.dialogue` file, verify:

1. **Node Headers**: Every node begins with `~ nodename`.
2. **GameManager Mutations**:
   * Affection adjustments: `do GameManager.add_affection("candidate_id", amount)`
   * Expression swaps: `do GameManager.set_expression("expression_name")`
   * Topic flags: `do GameManager.set_flag("candidate_id", "flag_name")`
   * Clue recording: `do GameManager.record_clue("candidate_id", "clue_id", "Clue description text")`
3. **Date Completion**: The `~ end_date` node must execute `do GameManager.complete_current_date()` followed by `=> END`.

Here is the complete, final **General Narrative & Writing Style Guide** for *Operation: Countdown* (or *Down with the Count*), updated with a explicit professional persona directive right at the top.

---

## ⏳ 1. Narrative & Structure Overview

* **The Setup:** You play as an undercover detective in a high-security monster asylum, posing as a participant in a 5-day "Radical Empathy Rehab" program.
* **The Countdown (Macro):** You have 4 days of dates to identify **The Count** (a master shapeshifter disguised as one of the patients) before the asylum gates open on Day 5 and the inmates are released into society.
* **The Date Flow:** Dates are standard, organic visual novel conversations with no real-time speed timers. Players have breathing room to enjoy character banter, build romantic chemistry, and cross-reference character statements against their **Monsterpedia**.

---

## 🗣️ 2. Natural Voice & Anti-AI Style Rules

To ensure the dialogue sounds like authentic human visual novel writing—and not repetitive, robotic AI output—enforce these strict stylistic boundaries:

* **No Em Dashes (`—`):** Do not use em dashes to connect thoughts. Use standard commas, periods, or ellipses (`...`) for mid-sentence trailing thoughts.
* **Banish "AI Buzzwords":** Strictly avoid cliché AI transition words and phrases (e.g., *"delve," "testament," "tapestry," "beacon," "it's not just X, it's Y," "a whirlwind of," "nestled," "masterpiece"*).
* **Vary Sentence Structure & Length:** Avoid the repetitive AI rhythm of "Short statement + long explanatory clause." Use fragmented sentences, slang, self-corrections, interruptions, and casual speech patterns.
* **Show Physicality in Narrative Tags, Not Adverbs:** Instead of writing *"she said menacingly,"* show the action directly in standard text (e.g., *She leans across the table until her breath hits your cheek.*).
* **Embrace Asymmetry & Flaws:** Real people (and monsters!) repeat themselves, pause, use filler words (like *"like," "um," "well"*), change topics abruptly, and don't always speak in polished, poetic paragraphs.

---

## 🔄 3. The Hybrid Dynamic Conversation System

Instead of a strict linear path or a boring static menu, dates use a **Hybrid Dialogue Web**. Players can dive deep into dynamic sub-branches and naturally pivot back to earlier topics, but their choices permanently change what paths remain open.

```
                  [ Opening / Icebreaker ]
                             │
     ┌───────────────────────┼───────────────────────┐
     ▼                       ▼                       ▼
[ Topic A: Passion ]    [ Topic B: Past ]    [ Topic C: Interrogation ]
     │                       │                       │
 ├─ Dynamic Follow-up    ├─ Dynamic Follow-up    ├─ [Check Affection]
 └─ Pivot Back to Web    └─ Pivot Back to Web    │   ├─ High: Unlock Deep Lore
                                                 │   └─ Low: SHUT DOWN!
                                                 ▼
                                     (Option C Permanently Locked)

```

### 1. Organic Topic Hubs & Natural Pivots

* **Flexible Exploration:** After exploring a specific dynamic sub-branch (like flirty banter or discussing their art), the candidate naturally opens a window to pivot: *"Anyway... what else did you want to know about me?"* or *"So, are we just gonna talk about my silk all day?"*
* **Circling Back:** Players can circle back to unasked questions or topics they held off on earlier.

### 2. Lockouts & Rejection Mechanics (Consequence Engine)

* **Risk vs. Reward Probing:** If you ask a sensitive interrogation question when **Affection is too low**, the monster will shut you down, take offense, or dodge the question.
* **Permanent Topic Lockouts:** Once a monster shuts down a topic, **that question branch is permanently locked** for the rest of the date. You lose your chance on that clue, forcing you to rebuild affection or focus on other clues!

### 3. Dynamic Progress & Natural Date Conclusions

* **Conversational Momentum:** The date naturally transitions through phases (Opening $\rightarrow$ Mid-date Banter $\rightarrow$ Late-date Intimacy/Tension $\rightarrow$ Wrap-up).
* **Positive Conclusion:** High affection triggers a warm, romantic, or lingering wrap-up where they express excitement to see you again (or match on Day 5).
* **Negative Conclusion:** Stacking too many shutdowns or dropping affection to zero causes the monster to end the date early, calling the guards to take them back to their cell.

---

## 🎭 4. The Core Writing Principles

### 1. The 1/3 Rule of Character Balance

To keep every monster multidimensional, relatable, and slightly scary, split their dialogue pool across three distinct layers:

* **$\frac{1}{3}$ Personal Identity & Desires:** Hobbies, artistic passions, human-like interests, and personal dreams outside the asylum walls.
* **$\frac{1}{3}$ Monster Instincts & Dark Past:** Uncomfortable biological realities, predatory survival instincts, and eerie asylum history.
* **$\frac{1}{3}$ Mental Condition / Psychological Quirks:** Expressed strictly through behavior, speech pacing, and emotional shifts.

### 2. The Rule of Subtext (Show, Don't Label)

* **Never Name the Condition:** Characters must **never** explicitly name their mental health condition or monster tropes (e.g., *never* write "I have OCD" or "I am a vampire who hates garlic").
* **Express Through Symptoms:** Show conditions through dialogue pacing (sentence structure, sudden ALL CAPS, twitchy hesitations, hyper-fixations) and physical actions noted in narrative text.

### 3. Organic Dating & Dynamic Affection

* Conversations should read like a genuine, dynamic date, balancing natural flirting/rapport with subtle detective probing.
* **High Affection Impact:** Building affection unlocks deeper, more vulnerable dialogue trees. These intimate paths grant clearer access to personal lore, making it easier to spot if the candidate is the Shapeshifter.
* **Low Affection Penalty:** Upsetting the candidate locks down interrogation branches and risks an early date termination.

---

## 🕵️‍♂️ 5. Clue & Imposter Design Rules

To make detective work feel rewarding rather than obvious, follow these strict rules for hiding "Shapeshifter Tells":

### Rule 1: No Blatant/Tropey Mistakes

The Shapeshifter looks 100% physically identical to their host and knows basic monster biology. They will **never** make obvious mistakes like claiming a vampire loves garlic or a sea monster lives on land.

### Rule 2: "Learned" vs. "Instinctual" Behavior

The Shapeshifter knows facts from studying monsters, but **lacks biological memory and visceral instinct**.

* **Real Monster:** Acts out of subconscious, biological impulse (e.g., involuntary physical reactions to environment, visceral cravings, unthinking species habits).
* **Shapeshifter:** Treats species habits as intellectual choices or mild inconveniences (e.g., treating a biological necessity as a mere preference, or forgetting an automatic physical reaction).

### Rule 3: Multi-Layered Tells

When writing a Shapeshifter variation of a character, embed their subtle mistakes across three distinct layers:

1. **Lore/Historical Tell:** Misunderstanding deep ancestral lore or treating historical events like a textbook summary rather than lived experience.
2. **Behavioral Tell:** Failing to exhibit automatic physical or sensory reactions to environmental triggers (temperature, sound, air humidity, pressure).
3. **Emotional Tell:** Expressing desires or preferences that contradict the underlying psychological nature of that species.

---

## 🎭 6. Handling Red Herrings (Fakeouts)

Innocent monsters in an asylum will naturally say weird, contradictory, or unsettling things. To prevent misleading the player unfairly:

* **The Delusion vs. Lie Principle:** An innocent monster might say something bizarre because of their condition or mental state (e.g., a manic episode, memory loss, or romantic delusion), but their **visceral biological instincts will still align with their species**.
* **The Shapeshifter Slip:** The Shapeshifter is calm, calculating, and trying to sound like a normal patient, but **fails the underlying species instinct**.

---

## 📐 7. Dialogue Prompting Rules (For AI & Writers)

When drafting or refining dialogue scripts:

1. **Hybrid Web Structure:** Write dialogue trees that allow follow-up branches while providing natural pivot points back to open topic hubs.
2. **Affection Gating & Lockout Tags:** Explicitly tag choices that require high affection to succeed, and write failure dialogue where low affection permanently locks that topic branch.
3. **Dual Choices:** Balance choices between **Building Affection/Flirting** (keeping the date happy and open) vs. **Lore Probing** (testing species knowledge at the risk of getting shut down).
4. **Style Enforcer:** Run all generated lines through the **Anti-AI Style Rules** in Section 2 to strip out em dashes, AI phrasing, and overly polished prose.