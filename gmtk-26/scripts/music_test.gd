extends Control

const CHARACTERS := [
	{
		"id": &"sea_monster",
		"name": "Havmonster",
		"key": KEY_1,
	},
	{
		"id": &"zombie",
		"name": "Zombie",
		"key": KEY_2,
	},
	{
		"id": &"angel",
		"name": "Bibelsk engel",
		"key": KEY_3,
	},
	{
		"id": &"insect",
		"name": "Insekt",
		"key": KEY_4,
	},
	{
		"id": &"vampire",
		"name": "Vampyr",
		"key": KEY_5,
	},
	{
		"id": &"slime",
		"name": "Slim",
		"key": KEY_6,
	},
]

const TRACKS := [
	{
		"id": &"ambience",
		"name": "Ambience",
		"color": "#65737e",
	},
	{
		"id": &"backing",
		"name": "Backing",
		"color": "#f3c969",
	},
	{
		"id": &"drums",
		"name": "Trommer",
		"color": "#e06c75",
	},
	{
		"id": &"sea_monster",
		"name": "Havmonster",
		"color": "#56b6c2",
	},
	{
		"id": &"zombie",
		"name": "Zombie",
		"color": "#98c379",
	},
	{
		"id": &"angel",
		"name": "Engel",
		"color": "#e5c07b",
	},
	{
		"id": &"insect",
		"name": "Insekt",
		"color": "#c678dd",
	},
	{
		"id": &"vampire",
		"name": "Vampyr",
		"color": "#be5046",
	},
	{
		"id": &"slime",
		"name": "Slim",
		"color": "#61afef",
	},
]

var current_character: StringName = &"slime"
var current_character_name := "Slim"

var music_paused := false
var lead_enabled := false
var backing_enabled := true
var drums_enabled := true
var low_pass_enabled := false
var mood_effect_enabled := false

var status_label: Label
var timeline_time_label: Label

var music_volume_slider: HSlider
var ambience_volume_slider: HSlider

var pause_button: Button
var backing_button: Button
var drums_button: Button
var low_pass_button: Button
var mood_effect_button: Button

var track_bars: Dictionary = {}


func _ready() -> void:
	var window := get_window()

	# Slå projektets eventuelle pixel-art-skalering fra
	# for denne testscene.
	window.content_scale_size = Vector2i.ZERO
	window.size = Vector2i(900, 800)

	# Vent på at vinduet har opdateret sin størrelse.
	await get_tree().process_frame

	# Sørg for at testscenens root fylder hele viewportet.
	position = Vector2.ZERO
	size = get_viewport_rect().size
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	print("Viewport size: ", get_viewport_rect().size)
	print("Test root size: ", size)

	_build_interface()

	MusicManager.set_music_volume(
		music_volume_slider.value
	)

	MusicManager.set_ambience_volume(
		ambience_volume_slider.value
	)

	MusicManager.play_ambience()

	mood_effect_enabled = (
		MusicManager.is_mood_effect_enabled()
	)
	_update_mood_effect_button()
	_update_status("Klar til at teste")


func _process(_delta: float) -> void:
	_update_timeline()


# ------------------------------------------------------------------
# LOOP SETUP
# ------------------------------------------------------------------

func _force_audio_looping() -> void:
	for stream in MusicManager.STEMS:
		var ogg_stream := (
			stream as AudioStreamOggVorbis
		)

		if ogg_stream != null:
			ogg_stream.loop = true

	var ambience_ogg := (
		MusicManager.AMBIENCE_STREAM
		as AudioStreamOggVorbis
	)

	if ambience_ogg != null:
		ambience_ogg.loop = true


# ------------------------------------------------------------------
# INTERFACE
# ------------------------------------------------------------------

func _build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.color = Color("#18151f")
	add_child(background)

	var page_margin := MarginContainer.new()
	page_margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	page_margin.add_theme_constant_override(
		"margin_left",
		16
	)
	page_margin.add_theme_constant_override(
		"margin_top",
		16
	)
	page_margin.add_theme_constant_override(
		"margin_right",
		16
	)
	page_margin.add_theme_constant_override(
		"margin_bottom",
		16
	)
	add_child(page_margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	page_margin.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	scroll.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(
		680.0,
		0.0
	)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override(
		"margin_left",
		28
	)
	margin.add_theme_constant_override(
		"margin_top",
		24
	)
	margin.add_theme_constant_override(
		"margin_right",
		28
	)
	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override(
		"separation",
		14
	)
	margin.add_child(layout)

	_build_header(layout)
	_build_character_buttons(layout)
	_build_transport_buttons(layout)
	_build_layer_buttons(layout)
	_build_volume_controls(layout)
	_build_timeline(layout)
	_build_status(layout)
	_build_shortcuts(layout)


func _build_header(
	layout: VBoxContainer
) -> void:
	var title := Label.new()
	title.text = "Monster Dating Music Test"
	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	title.add_theme_font_size_override(
		"font_size",
		26
	)
	layout.add_child(title)

	var description := Label.new()
	description.text = (
		"Skift mellem monstrene uden at genstarte musikken.\n" +
		"Ambience looper uafhængigt i baggrunden."
	)
	description.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	layout.add_child(description)


func _build_character_buttons(
	layout: VBoxContainer
) -> void:
	var heading := Label.new()
	heading.text = "Karakter-lead"
	heading.add_theme_font_size_override(
		"font_size",
		18
	)
	layout.add_child(heading)

	var character_grid := GridContainer.new()
	character_grid.columns = 2
	character_grid.add_theme_constant_override(
		"h_separation",
		10
	)
	character_grid.add_theme_constant_override(
		"v_separation",
		10
	)
	layout.add_child(character_grid)

	for character_index in range(
		CHARACTERS.size()
	):
		var character: Dictionary = (
			CHARACTERS[character_index]
		)

		var character_id: StringName = (
			character["id"]
		)

		var character_name: String = (
			character["name"]
		)

		var button := _create_button(
			"%d - %s" % [
				character_index + 1,
				character_name
			],
			_select_character.bind(
				character_id,
				character_name
			),
			270.0
		)

		character_grid.add_child(button)


func _build_transport_buttons(
	layout: VBoxContainer
) -> void:
	var separator := HSeparator.new()
	layout.add_child(separator)

	var transport := HBoxContainer.new()
	transport.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)
	transport.add_theme_constant_override(
		"separation",
		8
	)
	layout.add_child(transport)

	transport.add_child(
		_create_button(
			"Start igen",
			_restart_music,
			130.0
		)
	)

	transport.add_child(
		_create_button(
			"Fjern lead",
			_clear_lead,
			130.0
		)
	)

	pause_button = _create_button(
		"Pause",
		_toggle_pause,
		130.0
	)
	transport.add_child(pause_button)

	transport.add_child(
		_create_button(
			"Stop musik",
			_stop_music,
			130.0
		)
	)


func _build_layer_buttons(
	layout: VBoxContainer
) -> void:
	var layer_controls := HBoxContainer.new()
	layer_controls.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)
	layer_controls.add_theme_constant_override(
		"separation",
		8
	)
	layout.add_child(layer_controls)

	backing_button = _create_button(
		"Backing: TIL",
		_toggle_backing,
		175.0
	)
	layer_controls.add_child(backing_button)

	drums_button = _create_button(
		"Trommer: TIL",
		_toggle_drums,
		175.0
	)
	layer_controls.add_child(drums_button)

	low_pass_button = _create_button(
		"Low-pass: FRA",
		_toggle_low_pass,
		240.0
	)
	layer_controls.add_child(low_pass_button)

	var mood_controls := HBoxContainer.new()
	mood_controls.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)
	layout.add_child(mood_controls)

	mood_effect_button = _create_button(
		"Mørk stemning: FRA",
		_toggle_mood_effect,
		240.0
	)
	mood_controls.add_child(mood_effect_button)


func _build_volume_controls(
	layout: VBoxContainer
) -> void:
	var separator := HSeparator.new()
	layout.add_child(separator)

	var heading := Label.new()
	heading.text = "Volume"
	heading.add_theme_font_size_override(
		"font_size",
		18
	)
	layout.add_child(heading)

	var music_row := HBoxContainer.new()
	music_row.add_theme_constant_override(
		"separation",
		12
	)
	layout.add_child(music_row)

	var music_label := Label.new()
	music_label.text = "Musik"
	music_label.custom_minimum_size.x = 100.0
	music_row.add_child(music_label)

	music_volume_slider = HSlider.new()
	music_volume_slider.min_value = 0.0
	music_volume_slider.max_value = 1.0
	music_volume_slider.step = 0.01
	music_volume_slider.value = 0.8
	music_volume_slider.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	music_volume_slider.value_changed.connect(
		_on_music_volume_changed
	)
	music_row.add_child(music_volume_slider)

	var ambience_row := HBoxContainer.new()
	ambience_row.add_theme_constant_override(
		"separation",
		12
	)
	layout.add_child(ambience_row)

	var ambience_label := Label.new()
	ambience_label.text = "Ambience"
	ambience_label.custom_minimum_size.x = 100.0
	ambience_row.add_child(ambience_label)

	ambience_volume_slider = HSlider.new()
	ambience_volume_slider.min_value = 0.0
	ambience_volume_slider.max_value = 1.0
	ambience_volume_slider.step = 0.01
	ambience_volume_slider.value = 0.3
	ambience_volume_slider.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	ambience_volume_slider.value_changed.connect(
		_on_ambience_volume_changed
	)
	ambience_row.add_child(
		ambience_volume_slider
	)


func _build_timeline(
	layout: VBoxContainer
) -> void:
	var separator := HSeparator.new()
	layout.add_child(separator)

	var timeline_header := HBoxContainer.new()
	layout.add_child(timeline_header)

	var heading := Label.new()
	heading.text = "Track timeline"
	heading.add_theme_font_size_override(
		"font_size",
		18
	)
	heading.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	timeline_header.add_child(heading)

	timeline_time_label = Label.new()
	timeline_time_label.text = "0.00 / 0.00"
	timeline_time_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	timeline_header.add_child(
		timeline_time_label
	)

	var timeline := VBoxContainer.new()
	timeline.add_theme_constant_override(
		"separation",
		5
	)
	layout.add_child(timeline)

	for track in TRACKS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override(
			"separation",
			10
		)
		timeline.add_child(row)

		var track_label := Label.new()
		track_label.text = track["name"]
		track_label.custom_minimum_size.x = 110.0
		row.add_child(track_label)

		var track_color := Color(
			track["color"]
		)

		var progress := _create_track_bar(
			track_color
		)
		row.add_child(progress)

		track_bars[track["id"]] = progress


func _build_status(
	layout: VBoxContainer
) -> void:
	status_label = Label.new()
	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	status_label.add_theme_color_override(
		"font_color",
		Color("#f3c969")
	)
	layout.add_child(status_label)


func _build_shortcuts(
	layout: VBoxContainer
) -> void:
	var shortcuts := Label.new()
	shortcuts.text = (
		"1-6 = monster  |  B = backing  |  D = drums\n" +
		"L = low-pass  |  M = mørk stemning  |  C = fjern lead\n" +
		"Space = pause  |  " +
		"R = start  |  S = stop"
	)
	shortcuts.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	shortcuts.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.65
	)
	layout.add_child(shortcuts)


func _create_button(
	button_text: String,
	callback: Callable,
	minimum_width := 240.0
) -> Button:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(
		minimum_width,
		42.0
	)
	button.pressed.connect(callback)
	return button


func _create_track_bar(
	track_color: Color
) -> ProgressBar:
	var progress := ProgressBar.new()
	progress.min_value = 0.0
	progress.max_value = 1.0
	progress.value = 0.0
	progress.show_percentage = false
	progress.custom_minimum_size.y = 20.0
	progress.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color("#27232f")
	background_style.corner_radius_top_left = 3
	background_style.corner_radius_top_right = 3
	background_style.corner_radius_bottom_left = 3
	background_style.corner_radius_bottom_right = 3

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = track_color
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3

	progress.add_theme_stylebox_override(
		"background",
		background_style
	)
	progress.add_theme_stylebox_override(
		"fill",
		fill_style
	)

	return progress


# ------------------------------------------------------------------
# MUSIC CONTROLS
# ------------------------------------------------------------------

func _select_character(
	character_id: StringName,
	character_name: String
) -> void:
	current_character = character_id
	current_character_name = character_name

	lead_enabled = true
	music_paused = false
	pause_button.text = "Pause"

	MusicManager.resume_date_music()
	MusicManager.set_music_volume(
		music_volume_slider.value
	)
	MusicManager.play_date_music(
		character_id,
		0.4
	)

	_update_status(
		"Spiller: %s" % character_name
	)


func _restart_music() -> void:
	_select_character(
		current_character,
		current_character_name
	)


func _clear_lead() -> void:
	lead_enabled = false

	MusicManager.clear_date_character(0.4)
	_update_status("Kun backing og trommer")


func _toggle_pause() -> void:
	music_paused = not music_paused

	if music_paused:
		MusicManager.pause_date_music()
		pause_button.text = "Fortsæt"
		_update_status("Musikken er pauset")
	else:
		MusicManager.resume_date_music()
		pause_button.text = "Pause"
		_update_status(
			"Spiller: %s" % current_character_name
		)


func _stop_music() -> void:
	music_paused = false
	lead_enabled = false
	pause_button.text = "Pause"

	MusicManager.stop_date_music(0.6)
	_update_status("Musikken stopper")


func _toggle_backing() -> void:
	backing_enabled = (
		MusicManager.toggle_backing(0.25)
	)

	backing_button.text = (
		"Backing: TIL"
		if backing_enabled
		else "Backing: FRA"
	)

	_update_status(
		"Backing: %s" %
		("TIL" if backing_enabled else "FRA")
	)


func _toggle_drums() -> void:
	drums_enabled = (
		MusicManager.toggle_drums(0.25)
	)

	drums_button.text = (
		"Trommer: TIL"
		if drums_enabled
		else "Trommer: FRA"
	)

	_update_status(
		"Trommer: %s" %
		("TIL" if drums_enabled else "FRA")
	)


func _toggle_low_pass() -> void:
	low_pass_enabled = (
		MusicManager.toggle_low_pass(900.0)
	)

	low_pass_button.text = (
		"Low-pass: TIL"
		if low_pass_enabled
		else "Low-pass: FRA"
	)

	_update_status(
		"Low-pass: %s" %
		("TIL" if low_pass_enabled else "FRA")
	)


func _toggle_mood_effect() -> void:
	mood_effect_enabled = (
		MusicManager.toggle_mood_effect()
	)
	_update_mood_effect_button()

	_update_status(
		"Mørk stemning: %s" %
		("TIL" if mood_effect_enabled else "FRA")
	)


func _update_mood_effect_button() -> void:
	mood_effect_button.text = (
		"Mørk stemning: TIL"
		if mood_effect_enabled
		else "Mørk stemning: FRA"
	)


func _on_music_volume_changed(
	value: float
) -> void:
	MusicManager.set_music_volume(value)


func _on_ambience_volume_changed(
	value: float
) -> void:
	MusicManager.set_ambience_volume(value)


func _update_status(
	message: String
) -> void:
	status_label.text = message


# ------------------------------------------------------------------
# TIMELINE
# ------------------------------------------------------------------

func _update_timeline() -> void:
	if track_bars.is_empty():
		return

	var music_player: AudioStreamPlayer = (
		MusicManager._music_player
	)

	var ambience_player: AudioStreamPlayer = (
		MusicManager._ambience_player
	)

	var music_length := (
		MusicManager.STEMS[0].get_length()
	)

	var ambience_length := (
		MusicManager.AMBIENCE_STREAM.get_length()
	)

	var music_position := 0.0
	var ambience_position := 0.0

	if music_player.playing:
		music_position = (
			music_player.get_playback_position()
		)

	if ambience_player.playing:
		ambience_position = (
			ambience_player.get_playback_position()
		)

	var music_active := music_player.playing

	_set_track_progress(
		&"ambience",
		ambience_position,
		ambience_length,
		ambience_player.playing
	)

	_set_track_progress(
		&"backing",
		music_position,
		music_length,
		music_active and backing_enabled
	)

	_set_track_progress(
		&"drums",
		music_position,
		music_length,
		music_active and drums_enabled
	)

	for character in CHARACTERS:
		var character_id: StringName = (
			character["id"]
		)

		var character_active := (
			music_active
			and lead_enabled
			and current_character == character_id
		)

		_set_track_progress(
			character_id,
			music_position,
			music_length,
			character_active
		)

	timeline_time_label.text = (
		"Music %.2f / %.2f   Ambience %.2f / %.2f"
		% [
			music_position,
			music_length,
			ambience_position,
			ambience_length
		]
	)


func _set_track_progress(
	track_id: StringName,
	position: float,
	length: float,
	active: bool
) -> void:
	if not track_bars.has(track_id):
		return

	var progress: ProgressBar = (
		track_bars[track_id]
	)

	progress.max_value = maxf(length, 0.01)
	progress.value = position

	progress.modulate = (
		Color.WHITE
		if active
		else Color(1.0, 1.0, 1.0, 0.22)
	)


# ------------------------------------------------------------------
# KEYBOARD
# ------------------------------------------------------------------

func _unhandled_key_input(
	event: InputEvent
) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	for character in CHARACTERS:
		if event.keycode == character["key"]:
			_select_character(
				character["id"],
				character["name"]
			)
			get_viewport().set_input_as_handled()
			return

	match event.keycode:
		KEY_SPACE:
			_toggle_pause()

		KEY_B:
			_toggle_backing()

		KEY_D:
			_toggle_drums()

		KEY_L:
			_toggle_low_pass()

		KEY_M:
			_toggle_mood_effect()

		KEY_C:
			_clear_lead()

		KEY_R:
			_restart_music()

		KEY_S:
			_stop_music()

		_:
			return

	get_viewport().set_input_as_handled()
