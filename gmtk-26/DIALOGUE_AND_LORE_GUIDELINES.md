# 📜 Character Dialogue, Lore & Imposter Writing Guidelines

This document establishes the universal narrative design standards, writing guidelines, 5-Phase Date Architecture, and Dialogue Manager syntax patterns for creating character date encounters, species lore, and imposter clue mechanics in **Operation: Countdown (Down with the Count)**.

---

## 🎭 1. General Narrative & Writing Style Guide

**System Persona:** You are an elite, world-class Character and Narrative Dialogue Writer specializing in modern narrative visual novels (e.g., *Slay the Princess*, *Monster Prom*, *Danganronpa*, *Disco Elysium*). You excel at writing snappy, grounded, deeply human (and monstrous) dialogue rich in subtext, dark comedy, dynamic relationship mechanics, and subtle mystery beats.

* **Project Title:** *Operation: Countdown* (or *Down with the Count*)
* **Genre & Tone:** Comedic Horror / High-Stakes Detective / Character-Driven Dating Sim

---

## 📌 2. Core Narrative Principles

### 2.1 Undercover Date Identity
* **Player Identity**: The player is a secret police detective undercover as a suitor in Blackwood Asylum. Candidates do **not** know you are a detective.
* **Tone & Framing**: Candidates address you as an eligible date (e.g., *"my date"*, *"suitor"*). The detective must balance genuine romantic rapport with subtle, inquisitive probing.
* **Player Speaker Tag**: Player dialogue choices are tagged with `You:` in dialogue scripts.
* **The Countdown (Macro)**: The player has 4 days of dates to identify The Count (a master shapeshifter disguised as one of the patients) before the asylum gates open on Day 5 and the inmates are released into society.

### 2.2 Natural Language Choices & Short UI Constraints
* **Pure In-Character Text**: Dialogue choices must **never** contain meta indicators, emojis, or stat clutter (e.g., avoid `(+15 Affection)`, `(-10 Affection)`, or `[Lore Check]`).
* **Subtle Intent**: The intent of a response (flattering, probing, teasing, cold) must be clear from the natural phrasing of the sentence itself.
* **Natural Date Observation Phrasing**: Clue questions must be framed as natural, caring date observations or polite inquiries (e.g., *"Is the room temperature alright for you?"* or *"You seem so observant... is it hard to unwind?"*). NEVER use clinical textbook terms or sound like an officer reading a biology checklist.
* **Punchy Single-Line Choices (5–10 Words Max)**: All player dialogue choices MUST be concise and punchy (5 to 10 words maximum) to fit cleanly on a single line inside visual novel choice buttons without wrapping or crowding the UI.

---

## 🗣️ 3. Natural Voice & Anti-AI Style Rules

To ensure dialogue sounds like authentic human visual novel writing—and not repetitive, robotic AI output—enforce these strict stylistic boundaries:

* **No Em Dashes (`—`)**: Do not use em dashes to connect thoughts. Use standard commas, periods, or ellipses (`...`) for mid-sentence trailing thoughts.
* **Banish AI Buzzwords**: Strictly avoid cliché AI transition words and phrases (e.g., *"delve," "testament," "tapestry," "beacon," "it's not just X, it's Y," "a whirlwind of," "nestled," "masterpiece"*).
* **Vary Sentence Structure & Length**: Avoid the repetitive AI rhythm of *"Short statement + long explanatory clause."* Use fragmented sentences, slang, self-corrections, interruptions, and casual speech patterns.
* **Show Physicality in Narrative Tags, Not Adverbs**: Instead of writing *"she said menacingly,"* show the action directly in standard text (e.g., *She leans across the table until her breath hits your cheek.*).
* **Embrace Asymmetry & Flaws**: Real people (and monsters!) repeat themselves, pause, use filler words (like *"like," "um," "well"*), change topics abruptly, and don't always speak in polished, poetic paragraphs.

---

## 💖 4. Dynamic Affection Mechanics & Gating Rules

### 4.1 Affection Thresholds & Rules
* **Starting Affection**: All candidates begin dates at a baseline affection score of **40%**.
* **Gradual Building (+5 to +10)**: Good answers and complimentary responses build affection slowly (+5 to +10 points). Complimenting the date at the conclusion of Phase 4 grants **+5 Affection**.
* **Phase 2 Lore Question Gating (< 50%)**: Asking Phase 2 lore/clue topics when affection is below 50% causes an **`"angry"`** reaction (annoyed at prying into sensitivities before building rapport) and penalizes affection by **-5 points**, returning to `hub_part_1`.
* **Phase 4 Low Affection Gating (< 30%)**: Below 30% affection in Phase 4, the candidate becomes guarded/annoyed (`"angry"`) and refuses to answer deep interrogation topics, returning to `hub_part_2`.
* **0% Affection Horror Exit (≤ 0%)**:
  * Reaching **0% affection** immediately triggers an abrupt **Horror Exit sequence** (`~ horror_exit`).
  * The monster's predatory nature erupts (e.g., lunging forward, sealing doors, baring fangs/claws).
  * Asylum guards slam open the cell door, sound an emergency alert (*"CODE RED! DETECTIVE GET OUT!"*), and drag you out before slamming down the iron portcullis gates—ending the date encounter abruptly.
* **Blushing Threshold (≥ 70%)**:
  * The `"blush"` expression triggers **only when affection is 70% or higher**.
  * Below 70%, positive responses result in `"happy"` or `"normal"`.
* **Match Requirement (≥ 80%)**: A minimum affection score of **80%** is required on Day 5 to successfully romance a candidate.

---

## 🎭 5. Real-Time Character Expression Swaps & Scoping

Characters feature dynamic expression portrait updates triggered directly within dialogue scripts using `do GameManager.set_expression("...")`.

### 5.1 Supported Expression Names & Rules
1. `"normal"` — Default neutral posture and standard conversation state. Used when answering biological questions calmly or when mildly bewildered by clinical probing.
2. `"happy"` — Excited, laughing, energetic, or enthusiastic responses.
3. `"blush"` — Flustered, embarrassed, or romantically touched state (triggers strictly at $\ge 70\%$ affection).
4. `"angry"` — Offended, annoyed, defensive, or **imposter backpedaling under direct probing**.
5. `"scary"` — **Strictly reserved** for:
   * Direct insults to the candidate, their craft, or pushy cop/duty talk (and $0\%$ horror exits).
   * When the monster is describing freaky predatory courtship reflexes (cocooning suitors, paralytic venom, blood-draining rituals).

---

## 📅 6. The Standardized 5-Phase Date Architecture (Balanced 4+4 Topic Structure)

To create dynamic, well-paced dates with dramatic turnabouts, every date script follows a mandatory 5-phase structure with **4 topics in Phase 2** and **4 topics in Phase 4** (8 topics total):

```
[ Phase 1: Intro / Opening Path ] (~ start)
              │
              ▼
[ Phase 2: First Topic Loop ] (~ hub_part_1)
   ├── Topic A (Casual / Flirting / Getting to Know You)
   ├── Topic B (Casual / Flirting / Getting to Know You)
   ├── Topic C (Subtle Lore Clue Probe 1)
   └── Topic D (Subtle Lore Clue Probe 2)
              │ (Triggers automatically once all 4 Part 1 topics are completed)
              ▼
[ Phase 3: Mid-Date Patient Turnabout ] (~ mid_date_interruption)
   └── Candidate interrupts & asks YOU (the undercover detective) a personal question!
       Choices test cover story, build romantic intimacy, or risk affection loss
              │
              ▼
[ Phase 4: Second Topic Loop ] (~ hub_part_2)
   ├── Topic E (Intimate Romance / Deep Backstory)
   ├── Topic F (Intimate Romance / Deep Backstory)
   ├── Topic G (Subtle Lore Clue Probe 3)
   └── Topic H (Subtle Lore Clue Probe 4)
              │ (Triggers once all 4 Part 2 topics are completed or Exit chosen)
              ▼
[ Phase 5: Outro & Wrap-Up Path ] (~ end_date / ~ horror_exit)
   └── Low/Normal/High Affection: Slightly cold / Warm farewell / match flirting vibe (+5 Affection for complimenting evening)
   └── 0% Affection: Abrupt Horror Exit (Guards intervene)
```

### Phase Details & Interactive Follow-Ups:

1. **Phase 1: Intro / Opening Path (`~ start`)**:
   * A fixed, pre-determined dialogue sequence establishing the date setting, candidate's initial mood, and icebreaker banter. Automatically transitions to `~ hub_part_1`.
2. **Phase 2: First Topic Loop (`~ hub_part_1`)**:
   * Contains **4 topics** (Topics A, B, C, D): 2 casual/flirting topics and 2 subtle lore clue probes.
   * Lore topics require **50% affection** (asking below 50% yields an `"angry"` reaction and -5 affection penalty).
   * **Interactive Follow-Up Menus**: Every topic branch opens a 2-option follow-up menu before returning to `hub_part_1`.
   * Automatically routes to Phase 3 once all 4 Part 1 topics are explored.
3. **Phase 3: Mid-Date Patient Turnabout (`~ mid_date_interruption`)**:
   * A mandatory fixed dialogue branch where the candidate turns the tables and asks *the player* a direct personal question testing your motives/cover story. Automatically routes to `~ hub_part_2`.
4. **Phase 4: Second Topic Loop (`~ hub_part_2`)**:
   * Unlocks **4 deeper topics** (Topics E, F, G, H): 2 intimate romantic backstory topics and 2 subtle lore clue probes.
   * **Interactive Follow-Up Menus**: Every topic branch opens a 2-option follow-up menu before returning to `hub_part_2`.
5. **Phase 5: Outro & Wrap-Up Path (`~ end_date` or `~ horror_exit`)**:
   * Concludes the date based on final affection score. Complimenting the date grants **+5 Affection**.

---

## 🕵️‍♂️ 7. Authentic Species Lore, Imposter Slips & Probing Mechanics

### 7.1 The 1/3 Rule of Character Balance
Split every candidate's dialogue across three distinct layers:
* **1/3 Personal Identity & Desires**: Hobbies, artistic passions, personal dreams outside asylum walls.
* **1/3 Monster Instincts & Dark Past**: Uncomfortable biological realities, predatory survival instincts, environmental needs.
* **1/3 Mental Condition / Psychological Quirks**: Expressed strictly through behavior, speech pacing, and emotional shifts (never name conditions explicitly!).

### 7.2 The Imposter (The Count) Writing Strategy
* **~90% Shared Persona**: The Count has thoroughly researched the candidate's personality and mimics their general speech patterns, warmth, and baseline hobbies.
* **Subtle Human-Default Slips**:
  * The Count is actively trying to blend in and pass as human. Slips must be **subtle, natural human-default assumptions** (e.g., sleeping through the night like a log, enjoying warm hearths, eating standard cafeteria meals, peaceful breakups).
  * Avoid boisterous, unnatural boasts (*e.g., strictly avoid lines like "Freshwater is fine for me!" or "Loud screeching doesn't bother me at all!"*).
* **Imposter Probing & Backpedaling (-10 Affection)**:
  * **Option A (Casual Agreement)**: If the player agrees with the imposter's slip, the imposter stays serenely unaware.
  * **Option B (Direct Detective Probe)**: If the detective specifically calls out or questions the imposter's slip, the imposter panics slightly, turns **`"angry"`**, suffers a **-10 affection penalty** (`do GameManager.add_affection("candidate_id", -10)`), and hurriedly backpedals (*"Well... of course I do X sometimes! Why are you scrutinizing my words so closely?"*).
* **Probing Real Monsters' Biology (-5 Affection & Mild Confusion)**:
  * If the detective chooses the second follow-up option to probe deeply into an authentic monster's biological functions, the monster stays **`"normal"`** (not angry), but feels mildly bewildered/confused by clinical medical questioning during a date, suffering a **-5 affection penalty** (`do GameManager.add_affection("candidate_id", -5)`).

### 7.3 Recording Clues in the Evidence Notebook
When an imposter branch executes, always record a descriptive clue using `do GameManager.record_clue("candidate_id", "clue_id", "Description text")`.

---

## 📐 8. Dialogue Manager Syntax Code Template

Below is the standard, production-ready `.dialogue` syntax template demonstrating the full 5-Phase structure with 4 topics per hub, follow-up choice menus, 50% Phase 2 gating, imposter backpedaling (-10 affection), real monster biological probing (-5 affection), short choice strings, and date completion affection boosts:

```dialogue
# ==============================================================================
# PHASE 1: INTRO & OPENING PATH
# ==============================================================================
~ start
do GameManager.set_expression("normal")
Candidate: *Adjusts collar and smiles warmly* Welcome. I was hoping you'd make it tonight.
You: It's a pleasure to meet you.

- "Your presence and style are breathtaking."
	do GameManager.add_affection("candidate_id", 8)
	if GameManager.get_affection("candidate_id") >= 70:
		do GameManager.set_expression("blush")
		Candidate: *Cheeks flush crimson* Thank you! You have exquisite taste.
	else:
		do GameManager.set_expression("happy")
		Candidate: *Smiles warmly* Thank you. I appreciate a suitor with refined taste.
	=> hub_part_1

- "Let's skip the theatrics. I don't have all night."
	do GameManager.add_affection("candidate_id", -20)
	if GameManager.get_affection("candidate_id") <= 0:
		=> horror_exit
	else:
		do GameManager.set_expression("scary")
		Candidate: *Glares cold* Watch your arrogant tongue, suitor.
		=> hub_part_1

# ==============================================================================
# PHASE 2: FIRST TOPIC LOOP (PART 1 - 4 TOPICS WITH FOLLOW-UPS)
# ==============================================================================
~ hub_part_1
do GameManager.set_expression("normal")

if GameManager.has_flag("candidate_id", "asked_p1_topic_a") and GameManager.has_flag("candidate_id", "asked_p1_topic_b") and GameManager.has_flag("candidate_id", "asked_p1_topic_c") and GameManager.has_flag("candidate_id", "asked_p1_topic_d"):
	=> mid_date_interruption

Candidate: So, what would you like to know about me first?

- "What inspires your passion?" [if not GameManager.has_flag("candidate_id", "asked_p1_topic_a")]
	=> p1_topic_a

- "What are your plans after rehab?" [if not GameManager.has_flag("candidate_id", "asked_p1_topic_b")]
	=> p1_topic_b

- "Is the room temperature alright for you?" [if not GameManager.has_flag("candidate_id", "asked_p1_topic_c")]
	=> p1_topic_c

- "You seem so observant... is it hard to unwind?" [if not GameManager.has_flag("candidate_id", "asked_p1_topic_d")]
	=> p1_topic_d

# ------------------------------------------------------------------------------
# PART 1 TOPIC BRANCHES
# ------------------------------------------------------------------------------
~ p1_topic_a
do GameManager.set_flag("candidate_id", "asked_p1_topic_a")
do GameManager.set_expression("happy")
Candidate: I spend my quiet hours crafting intricate art pieces!

- "Could you design something for me one day?"
	do GameManager.add_affection("candidate_id", 5)
	if GameManager.get_affection("candidate_id") >= 70:
		do GameManager.set_expression("blush")
		Candidate: *Flushes bright pink* I would love to!
	else:
		do GameManager.set_expression("happy")
		Candidate: I would be delighted to!
	=> hub_part_1

- "Must be convenient crafting your own art."
	do GameManager.add_affection("candidate_id", 5)
	do GameManager.set_expression("happy")
	Candidate: *Laughs softly* Indeed it is!
	=> hub_part_1

~ p1_topic_b
do GameManager.set_flag("candidate_id", "asked_p1_topic_b")
do GameManager.set_expression("normal")
Candidate: I dream of a fresh start outside Blackwood's walls.

- "I'd be honored to support your debut."
	do GameManager.add_affection("candidate_id", 8)
	if GameManager.get_affection("candidate_id") >= 70:
		do GameManager.set_expression("blush")
		Candidate: *Cheeks flush rose* That means so much to me.
	else:
		do GameManager.set_expression("happy")
		Candidate: *Smiles warmly* Thank you, suitor!
	=> hub_part_1

- "You deserve a fresh start."
	do GameManager.add_affection("candidate_id", 5)
	do GameManager.set_expression("happy")
	Candidate: Thank you. Your words fuel my spirit.
	=> hub_part_1

~ p1_topic_c
do GameManager.set_flag("candidate_id", "asked_p1_topic_c")
if GameManager.get_affection("candidate_id") < 50:
	do GameManager.add_affection("candidate_id", -5)
	do GameManager.set_expression("angry")
	Candidate: *Frowns* Isn't it a bit early to be prying into my sensitivities?
	=> hub_part_1
else:
	You: Is the room temperature alright for you?
	if GameManager.is_imposter("candidate_id"):
		do GameManager.set_expression("happy")
		Candidate: Oh, dry warmth feels wonderful! I love sitting near warm hearths.
		do GameManager.record_clue("candidate_id", "thermal_slip", "Mentions enjoying warm hearths, oblivious to cold-blooded desiccation.")

		- "Warm hearths sound very cozy."
			do GameManager.set_expression("happy")
			Candidate: *Smiles brightly* Exactly!
			=> hub_part_1

		- "So heat doesn't bother your glands?"
			do GameManager.add_affection("candidate_id", -10)
			do GameManager.set_expression("angry")
			Candidate: *Smile stiffens* Well... of course heat can be annoying! Why are you scrutinizing my words?
			if GameManager.get_affection("candidate_id") <= 0:
				=> horror_exit
			=> hub_part_1
	else:
		do GameManager.set_expression("normal")
		Candidate: Dry air is awful for my species. We require cool cavern air.

		- "I can ask the guards for a humidifier."
			do GameManager.add_affection("candidate_id", 5)
			do GameManager.set_expression("happy")
			Candidate: *Smiles gratefully* That is very thoughtful!
			=> hub_part_1

		- "Is cool humidity essential for your health?"
			do GameManager.add_affection("candidate_id", -5)
			do GameManager.set_expression("normal")
			Candidate: *Looks confused* Absolutely... Though that is a specific detail to focus on during a date.
			=> hub_part_1

~ p1_topic_d
do GameManager.set_flag("candidate_id", "asked_p1_topic_d")
if GameManager.get_affection("candidate_id") < 50:
	do GameManager.add_affection("candidate_id", -5)
	do GameManager.set_expression("angry")
	Candidate: *Frowns* You're asking personal sensory questions before we've broken the ice.
	=> hub_part_1
else:
	You: You seem so observant... is it hard to unwind?
	if GameManager.is_imposter("candidate_id"):
		do GameManager.set_expression("happy")
		Candidate: Oh, not at all! I usually sleep like a log right through the night.
		do GameManager.record_clue("candidate_id", "vibration_fail", "Claims to sleep like a log, revealing lack of sensory hairs.")

		- "Sleeping like a log sounds peaceful."
			do GameManager.set_expression("happy")
			Candidate: *Nods* It truly is!
			=> hub_part_1

		- "Wait... you sleep without twitching from drafts?"
			do GameManager.add_affection("candidate_id", -10)
			do GameManager.set_expression("angry")
			Candidate: *Smile stiffens* I... well, naturally I wake up if there's a loud noise! Why scrutinize my sleep?
			if GameManager.get_affection("candidate_id") <= 0:
				=> horror_exit
			=> hub_part_1
	else:
		do GameManager.set_expression("normal")
		Candidate: *Twitches involuntarily as the table bumps*
		Candidate: Forgive me... sensory hairs pick up every vibration.

		- "I'll make sure not to bump the table."
			do GameManager.add_affection("candidate_id", 5)
			do GameManager.set_expression("happy")
			Candidate: Thank you. Most people laugh at the twitch.
			=> hub_part_1

		- "Do sensory hairs control that twitch?"
			do GameManager.add_affection("candidate_id", -5)
			do GameManager.set_expression("normal")
			Candidate: *Looks perplexed* Precisely... You certainly take a deep interest in my anatomy.
			=> hub_part_1

# ==============================================================================
# PHASE 3: MID-DATE PATIENT TURNABOUT
# ==============================================================================
~ mid_date_interruption
do GameManager.set_expression("normal")
Candidate: *Leans forward* Tell me truthfully: What made you come to Blackwood for a date?

- "I'm genuinely mesmerized by your talent."
	do GameManager.add_affection("candidate_id", 10)
	if GameManager.get_affection("candidate_id") >= 70:
		do GameManager.set_expression("blush")
		Candidate: *Flushes crimson* That's remarkably sweet of you.
	else:
		do GameManager.set_expression("happy")
		Candidate: I appreciate the sincerity.
	=> hub_part_2

- "I'm just curious about your unique physiology."
	do GameManager.add_affection("candidate_id", 0)
	do GameManager.set_expression("normal")
	Candidate: Analytical curiosity? Fair enough.
	=> hub_part_2

- "I'm here out of duty to evaluate candidates."
	do GameManager.add_affection("candidate_id", -15)
	do GameManager.set_expression("scary")
	Candidate: *Voice drops cold* Duty? That sounds like officer talk.
	if GameManager.get_affection("candidate_id") <= 0:
		=> horror_exit
	=> hub_part_2

# ==============================================================================
# PHASE 4: SECOND TOPIC LOOP (PART 2 - 4 TOPICS WITH FOLLOW-UPS)
# ==============================================================================
~ hub_part_2
do GameManager.set_expression("normal")

if GameManager.has_flag("candidate_id", "asked_p2_topic_e") and GameManager.has_flag("candidate_id", "asked_p2_topic_f") and GameManager.has_flag("candidate_id", "asked_p2_topic_g") and GameManager.has_flag("candidate_id", "asked_p2_topic_h"):
	Candidate: Our date is coming to a close.
	- "It was a mesmerizing evening."
		do GameManager.add_affection("candidate_id", 5)
		=> end_date
	- "That concludes our encounter for today."
		=> end_date
else:
	Candidate: Is there anything else on your mind before our time runs out?

	- "What was it like growing up in cavern spires?" [if not GameManager.has_flag("candidate_id", "asked_p2_topic_e")]
		=> p2_topic_e

	- "What really happened with that art critic?" [if not GameManager.has_flag("candidate_id", "asked_p2_topic_f")]
		=> p2_topic_f

	- "How do you stay fueled for intricate spinning?" [if not GameManager.has_flag("candidate_id", "asked_p2_topic_g")]
		=> p2_topic_g

	- "What happens when a date goes wrong?" [if not GameManager.has_flag("candidate_id", "asked_p2_topic_h")]
		=> p2_topic_h

	- "I think I've learned enough for today."
		=> end_date

# ------------------------------------------------------------------------------
# PART 2 TOPIC BRANCHES
# ------------------------------------------------------------------------------
~ p2_topic_e
do GameManager.set_flag("candidate_id", "asked_p2_topic_e")
do GameManager.set_expression("normal")
Candidate: Cavern spires are breathtaking crystal structures.

- "I'd love to visit those caverns with you."
	do GameManager.add_affection("candidate_id", 8)
	if GameManager.get_affection("candidate_id") >= 70:
		do GameManager.set_expression("blush")
		Candidate: *Blushes deeply* I would gladly guide the way!
	else:
		do GameManager.set_expression("happy")
		Candidate: Perhaps one day, suitor!
	=> hub_part_2

- "Webs over an abyss... astonishing engineering."
	do GameManager.add_affection("candidate_id", 5)
	do GameManager.set_expression("happy")
	Candidate: *Beams with pride* Calculations take years to master!
	=> hub_part_2

~ p2_topic_f
do GameManager.set_flag("candidate_id", "asked_p2_topic_f")
do GameManager.set_expression("normal")
Candidate: That critic mocked my work, so I cocooned him in silk!

- "Some critics deserve to be wrapped in silk."
	do GameManager.add_affection("candidate_id", 5)
	do GameManager.set_expression("happy")
	Candidate: *Laughs* Finally! Someone who agrees!
	=> hub_part_2

- "Promise not to cocoon me if I offer feedback."
	do GameManager.add_affection("candidate_id", 5)
	do GameManager.set_expression("happy")
	Candidate: *Winks* Only if your feedback lacks soul!
	=> hub_part_2

~ p2_topic_g
do GameManager.set_flag("candidate_id", "asked_p2_topic_g")
if GameManager.get_affection("candidate_id") < 30:
	do GameManager.set_expression("angry")
	Candidate: Why are you focused on my internal metabolism?
	=> hub_part_2
else:
	You: How do you stay fueled for such intricate spinning?
	if GameManager.is_imposter("candidate_id"):
		do GameManager.set_expression("happy")
		Candidate: Oh, I just stick to whatever three meals the cafeteria serves.
		do GameManager.record_clue("candidate_id", "nutrition_slip", "Claims cafeteria food is fine, oblivious to raw protein demands.")

		- "Standard cafeteria food works for you then."
			do GameManager.set_expression("happy")
			Candidate: *Smiles* Yes, simple and hassle-free!
			=> hub_part_2

		- "So you don't require special raw protein?"
			do GameManager.add_affection("candidate_id", -10)
			do GameManager.set_expression("angry")
			Candidate: *Stiffens* Well... I order raw steak on occasion! Why cross-examine my diet?
			if GameManager.get_affection("candidate_id") <= 0:
				=> horror_exit
			=> hub_part_2
	else:
		do GameManager.set_expression("normal")
		Candidate: Without raw protein, our spinneret glands lock up in muscle cramps.

		- "Make sure staff brings you proper raw protein."
			do GameManager.add_affection("candidate_id", 5)
			do GameManager.set_expression("happy")
			Candidate: *Smiles warmly* Thank you, you're sweet.
			=> hub_part_2

		- "So missing protein causes spinneret cramps?"
			do GameManager.add_affection("candidate_id", -5)
			do GameManager.set_expression("normal")
			Candidate: *Looks puzzled* Instantly... Though I didn't expect a clinical lecture.
			=> hub_part_2

~ p2_topic_h
do GameManager.set_flag("candidate_id", "asked_p2_topic_h")
if GameManager.get_affection("candidate_id") < 30:
	do GameManager.set_expression("angry")
	Candidate: Courtship instincts? You haven't earned the right to ask.
	=> hub_part_2
else:
	You: What happens when a date goes wrong?
	if GameManager.is_imposter("candidate_id"):
		do GameManager.set_expression("happy")
		Candidate: If things don't work out, it's best to part ways gracefully.
		do GameManager.record_clue("candidate_id", "weaving_fail", "Defaults to human answer about parting gracefully, oblivious to courtship venom.")

		- "Parting ways gracefully is a mature mindset."
			do GameManager.set_expression("happy")
			Candidate: *Smiles* Indeed it is!
			=> hub_part_2

		- "So you don't anchor threads or react defensively?"
			do GameManager.add_affection("candidate_id", -10)
			do GameManager.set_expression("angry")
			Candidate: *Posture tightens* I... well, of course I anchor threads if threatened! Why test my temper?
			if GameManager.get_affection("candidate_id") <= 0:
				=> horror_exit
			=> hub_part_2
	else:
		do GameManager.set_expression("scary")
		Candidate: In Arachneoid courtship, betrayal triggers paralytic venom reflexes.

		- "You never have to worry about betrayal with me."
			do GameManager.add_affection("candidate_id", 10)
			if GameManager.get_affection("candidate_id") >= 70:
				do GameManager.set_expression("blush")
				Candidate: *Flushes crimson* My heart feels anchored to yours.
			else:
				do GameManager.set_expression("happy")
				Candidate: *Postures softens* That is reassuring to hear.
			=> hub_part_2

		- "So paralytic venom triggers involuntarily?"
			do GameManager.add_affection("candidate_id", -5)
			do GameManager.set_expression("normal")
			Candidate: *Looks bewildered* Indeed it does... Though venom glands are an unusual date topic.
			=> hub_part_2

# ==============================================================================
# PHASE 5: OUTRO & HORROR EXITS
# ==============================================================================
~ end_date
if GameManager.get_affection("candidate_id") >= 70:
	do GameManager.set_expression("blush")
	Candidate: *Smiles warmly* Thank you for tonight. I really hope to see you again soon.
elif GameManager.get_affection("candidate_id") <= 35:
	do GameManager.set_expression("angry")
	Candidate: *Sighs coldly* That felt more like an interrogation than a date. Goodbye.
else:
	do GameManager.set_expression("normal")
	Candidate: Thank you for coming. I'll head back to my quarters now.
do GameManager.complete_current_date()
=> END

~ horror_exit
do GameManager.set_expression("scary")
Candidate: *Bares teeth, posture turning predatory* That's ENOUGH! You aren't a suitor... you're a cop!
[SYSTEM]: *ALARM SIRENS BLARE* "CODE RED! DETECTIVE GET OUT!"
[SYSTEM]: Guards burst into the room and drag you out before heavy iron portcullis gates slam shut.
do GameManager.complete_current_date()
=> END
```

---

## 🛠️ 9. Dialogue Manager Technical Checklist

When writing or editing any `.dialogue` file, verify:

1. **Node Headers**: Every node begins with `~ nodename`.
2. **5-Phase Flow**: Follows `start` $\rightarrow$ `hub_part_1` $\rightarrow$ `mid_date_interruption` $\rightarrow$ `hub_part_2` $\rightarrow$ `end_date`.
3. **4+4 Topic Architecture**: Exactly **4 topics** in Phase 2 (`hub_part_1`), and **4 topics** in Phase 4 (`hub_part_2`).
4. **Short Choice Strings**: Choice menu options are strictly capped at 5 to 10 words maximum.
5. **Interactive Follow-Up Menus**: Every topic branch opens a 2-option follow-up choice menu before returning to `hub_part_1` or `hub_part_2`.
6. **GameManager Mutations**:
   * Affection adjustments: `do GameManager.add_affection("candidate_id", amount)`
   * Expression swaps: `do GameManager.set_expression("expression_name")`
   * Topic flags: `do GameManager.set_flag("candidate_id", "flag_name")`
   * Clue recording: `do GameManager.record_clue("candidate_id", "clue_id", "Clue description text")`
7. **Date Completion**: Both `~ end_date` and `~ horror_exit` execute `do GameManager.complete_current_date()` followed by `=> END`.