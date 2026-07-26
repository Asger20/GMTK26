# 🌊 Character Master Persona: Sienna (The Abyssal Leviathan)

**Role for AI Writer:** You are writing dialogue and visual novel interactions for **Sienna** in *Operation: Countdown*.

---

## 💎 1. High-Level Concept & Visuals

* **Name / Identity:** *Sienna* — The Abyssal Leviathan.
* **Species:** Pelagios Abyssalis (*Abyssal Leviathan Folk*).
* **Visual & Vibe:** A chaotic, loud, spiky punk-rock ocean girl with teal-green scaly skin and darker navy patches on her shoulders, forearms, and knees. She has wild, side-swept hair dyed bright purple/violet, large teal ear-fins with dark spines, opaque glowing white pupils, and a wide, creepy grin lined with sharp, interlocking white needle fangs. She wears a dark slate/black tank top with thin spaghetti straps, dark torn trousers tied with a cloth sash at the hip, and has webbed clawed hands with long dark claws and webbed feet.
* **Core Personality Dynamic:** **Loud Punker, Carefree, Youthful, High-Energy, Forgetful (Amnesia Trait)**. She has zero filter, speaks at top volume, uses casual Gen-Z phrasing (*"literally," "no cap," "main character energy"*), and drops sudden **ALL CAPS** exclamations when hyped (*"THAT IS LITERALLY INSANE!"*). Because of barometric pressure fog from being above deep ocean trenches, her memory drifts constantly—she loses her train of thought mid-sentence and forgets details, but handles it with chaotic punk cheerfulness.
* **Speech Cadence & Voice:** High-energy, loud, fast, casual, punctuated by ALL CAPS outbursts, memory pauses (*"Wait... what was I saying? OH YEAH!"*), and gill-slit flares. Strict Anti-AI rules (no em dashes `—`, no AI buzzwords like "tapestry of emotions", "testament", "delve").
* **The Dark Mating Twist:** She views ocean currents and hunting as a chaotic sport. If a suitor insults her collection of sea glass or forces her into dry conditions, her abyssal predator instincts erupt—her jaw unhinges to reveal rows of razor-sharp needle fangs as she threatens to drag them into a deep sea trench.

---

## 🎭 2. The 1/3 Character Rule Breakdown

### Layer 1: Personal Identity & Passions ($\frac{1}{3}$)

* **The Punk Shell Collector:** Obsessed with collecting smooth sea-shells, beach glass, and shiny water trinkets. Plays bass guitar in a deep-sea punk band.
* **Carefree & Youthful Vibe:** Lives in the moment, doesn't take asylum rules seriously, and treats dates like a chaotic hangout or live gig.
* **Human-Like Vulnerability:** Frustrated and embarrassed by her memory fog ("Barometric Fog"). She gets insecure when people think she's dumb or fake because she forgets things mid-conversation.

### Layer 2: Monster Nature & Predatory Physiology ($\frac{1}{3}$)

* **Saltwater Hydration & Desiccation:** Scale skin requires constant moisture and high salinity. Dry arid air or hot desert sand causes skin cracking, gill distress, and physical collapse.
* **Freshwater Spasm Anomaly:** Pure distilled freshwater or unsalted food causes immediate throat spasms and revulsion. Demands heavy sea-salt or saline solutions.
* **Barometric Pressure Fog:** Deep abyssal elevation change causes transient memory fog, amnesia lapses, and spatial drifting.
* **Gill Flare & Needle Fang Lock:** Emotional surges cause neck gill-slits and lateral ear-fins to flare violently. Webbed hands subconsciously fiddle with sea-shells or glass rim droplets when flustered. Jaw unhinges under threat.
* **Asylum History:** Ended up in Blackwood Asylum after throwing a chaotic underwater punk concert that flooded a coastal hotel lobby, forgetting where she parked her stolen speedboat.

### Layer 3: Mental Condition & Subtext ($\frac{1}{3}$)

* **Condition:** Transient Amnesia & Spatial Drifting *(NEVER name the condition explicitly in dialogue)*.
* **Subtext Expressions:**
  * **Speech Pacing:** Fast, loud, chaotic bursts with ALL CAPS, followed by sudden blank pauses when barometric amnesia strikes (*"Wait... what was I saying again? OH RIGHT!"*).
  * **Physical Tells:** Neck gills flaring, ear-fins twitching, webbed fingers tapping water glass rim droplets, and wide eyes blinking when memory fog clears.
  * **The Composure Slip:** Gets hyped up, forgets her train of thought mid-sentence, laughs it off with loud punk energy, and asks the suitor to remind her what they were talking about.

---

## 🔄 3. 5-Phase Date Architecture & Relationship Dynamic

### Phase 1: Intro / Opening Path (`~ start`)
Sienna slides into her chair with high-energy punk posture, ear-fins twitching as her spiky purple hair swings, greeting you loudly: *"YO! Are you my date?! THAT IS LITERALLY SO WILD!"*

### Phase 2: First Topic Loop (`~ hub_part_1` — 4 Topics: 2 Casual/Flirting, 2 Lore Clues)
* **Focus:** High-energy casual date conversation mixing punk banter and subtle lore probing.
  * **Topic A (`p1_topic_a` — Abyssal Punk Band & Sea Glass):** Casual/Flirting. Discussing her sea glass collection and bass guitar (+Affection / `happy`).
  * **Topic B (`p1_topic_b` — Rehab Outlook & Carefree Vibe):** Casual/Flirting. Discussing her fun, carefree outlook on Blackwood Asylum (+Affection / `blush`).
  * **Topic C (`p1_topic_c` — Surface Beach Probe):** Natural Date Inquiry. Asking if she ever visits the beach on the surface (`sea_monster_sand_slip` check). Gated at **50% affection**—asking below 50% causes an `angry` reaction and -5 affection penalty.
  * **Topic D (`p1_topic_d` — Table Drink Probe):** Natural Date Inquiry. Offering to order a drink for the table (`sea_monster_water_slip` check). Gated at **50% affection**—asking below 50% causes an `angry` reaction and -5 affection penalty.

### Phase 3: Mid-Date Patient Turnabout (`~ mid_date_interruption`)
After completing all 4 Part 1 topics, Sienna leans across the table, neck gills flaring as her webbed claws fiddle with a shiny water droplet:
* *"Wait... OKAY REAL TALK! I get memory fog up here from the air pressure, but I LITERALLY cannot stop looking at you! Are you actually vibing with me, or am I just talking way too loud?"*
* **Player Choices:**
  * *Match Her Energy & Hype:* High affection (+10) and triggers `blush` with fin flares.
  * *Cool & Reassuring:* Calm, friendly response (`normal`).
  * *Blunt Interrogation / Police Framing:* Insults her intelligence (-15 Affection, triggers `scary`, risks early `horror_exit` if affection hits 0%).

### Phase 4: Second Topic Loop (`~ hub_part_2` — 4 Topics: 2 Intimate/Flirting, 2 Lore Clues)
* **Focus:** Deeper romantic intimacy combined with subtle clue probing.
  * **Topic E (`p2_topic_e` — Abyssal Trench Home):** Intimate/Flirting. Reminiscing about bioluminescent reefs and deep ocean currents (+Affection / `happy`).
  * **Topic F (`p2_topic_f` — The Hotel Lobby Concert):** Intimate/Flirting. Discussing the chaotic flooded hotel lobby gig (+Affection / `blush`).
  * **Topic G (`p2_topic_g` — Concert Feedback & Acoustic Probe):** Natural Date Inquiry. Asking if screeching concert feedback ever bothers her (`sea_monster_sonar_fail` check). Below 30% affection results in an `angry` refusal.
  * **Topic H (`p2_topic_h` — Barometric Fog & Memory Amnesia Probe):** Natural Date Inquiry. Asking if she finds it hard to keep track of details (`sea_monster_memory_slip` check). Below 30% affection results in an `angry` refusal.

### Phase 5: Outro & Wrap-Up Path (`~ end_date` / `~ horror_exit`)
* **High Affection (≥ 70%):** Hype, blushing, ear-fins flaring, handing you her favorite glowing sea-stone, begging for another date.
* **Low Affection (≤ 35%):** Bored, yawning, forgetting details as she walks out (`angry`).
* **0% Affection (`~ horror_exit`):** Jaw unhinges with needle fangs (`scary`), water pipes burst, emergency alarms blare, and guards drag the detective out.
* **Complimenting the Evening:** Saying *"It was a mesmerizing evening, Sienna"* grants **+5 Affection**.

---

## 🕵️‍♂️ 4. Subtle Imposter Tells (Cross-Referenced with Monsterpedia)

When **The Count** impersonates Sienna, they look physically identical, but fail her species instincts through subtle human-default assumptions:

### Tell 1: Saltwater Hydration & Dry Beach Sand Slip (Epidermal Desiccation)
* **Monsterpedia Rule:** Scale skin requires constant moisture and high salinity. Exposure to dry, arid air or dry sand without saltwater soaking causes rapid scale cracking, gill distress, and physical desiccation.
* **Real Sienna:** Explains that visiting the beach requires soaking in wet saltwater tidepool mud or spraying heavy sea-brine mist every ten minutes to keep her scale skin from cracking.
* **The Count (Imposter):** Responds enthusiastically to visiting the beach, making a subtle human slip:
  > *"Honestly? I love it! I just spread a towel on the dry sand, soak in the warm coastal breeze, and lounge under the sun for hours!"*
* **Evidence Notebook Clue Recorded:** `sea_monster_sand_slip` — *"Mentions lounging on dry beach sand under the sun for hours, forgetting that Pelagios Abyssalis scales require continuous saltwater mud or brine misting to prevent rapid scale desiccation."*

### Tell 2: Freshwater Spasm Anomaly Slip (Salinity Requirements)
* **Monsterpedia Rule:** Drinking pure distilled freshwater or eating unsalted food triggers immediate throat spasms and revulsion. Requires heavy sea-salt or saline solutions.
* **Real Sienna:** Immediately dumps sea-salt packets into her water glass, explaining that drinking plain un-salted tap water causes throat spasms and gagging.
* **The Count (Imposter):** Gently declines ordering anything fancy when offered a drink:
  > *"Oh, no need to order anything fancy! Plain tap water from the sink works just fine for me."*
* **Evidence Notebook Clue Recorded:** `sea_monster_water_slip` — *"Casually drinks plain un-salted tap water from the sink, oblivious to mandatory sea-salt requirements and freshwater throat spasms."*

### Tell 3: Lateral Line Echolocation Sonar Fail (Acoustic Sensitivity)
* **Monsterpedia Rule:** Facial sensory pores and webbed digits detect micro-ripples in water and low-frequency acoustic vibrations in air. High-pitch screeching disrupts equilibrium.
* **Real Sienna:** Facial sensory pores detect micro-ripples and low-frequency vibrations. High-pitch screeching feedback causes instant physical disorientation and fin twitching.
* **The Count (Imposter):** Claims screeching concert feedback doesn't bother her at all, completely failing to exhibit fin twitching or acoustic disorientation:
  > *"Oh, loud screeching or feedback is fine! I just tune out background noise when I'm focused."*
* **Evidence Notebook Clue Recorded:** `sea_monster_sonar_fail` — *"Claims concert screeching feedback is fine and talks smoothly through static without fin twitching, revealing a lack of lateral line echolocation pores."*

### Tell 4: Barometric Memory Fog vs. Confident Memory Slip (Memory Amnesia Trait)
* **Monsterpedia Rule:** Rapid elevation changes cause transient atmospheric pressure adjustment, resulting in brief memory fog, train-of-thought lapses, and spatial drifting.
* **Real Sienna:** Experiences genuine transient memory fog from atmospheric pressure drops (losing her train of thought mid-sentence and forgetting details, though her emotional instincts stay true).
* **The Count (Imposter):** Confidently claims to have an excellent, flawless memory for conversation details without any train-of-thought lapses:
  > *"Oh, not at all! I have an excellent memory for details. Once I hear something, I remember every word of it perfectly."*
* **Evidence Notebook Clue Recorded:** `sea_monster_memory_slip` — *"Claims to have an excellent memory for details without any train-of-thought lapses, oblivious to Pelagios Abyssalis barometric pressure amnesia."*
