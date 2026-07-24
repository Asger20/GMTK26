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

var current_character: StringName = &"slime"
var current_character_name := "Slim"

var music_paused := false
var backing_enabled := true
var drums_enabled := true
var low_pass_enabled := false

var status_label: Label
var volume_slider: HSlider

var pause_button: Button
var backing_button: Button
var drums_button: Button
var low_pass_button: Button


func _ready() -> void:
	_build_interface()
	_update_status("Klar til at teste")


func _build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.color = Color("#18151f")
	add_child(background)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -320.0
	panel.offset_top = -310.0
	panel.offset_right = 320.0
	panel.offset_bottom = 310.0
	add_child(panel)

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
		"Backing, trommer og low-pass kan toggles separat."
	)
	description.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	layout.add_child(description)

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
			"%d — %s" % [
				character_index + 1,
				character_name
			],
			_select_character.bind(
				character_id,
				character_name
			),
			240.0
		)

		character_grid.add_child(button)

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
			125.0
		)
	)

	transport.add_child(
		_create_button(
			"Fjern lead",
			_clear_lead,
			125.0
		)
	)

	pause_button = _create_button(
		"Pause",
		_toggle_pause,
		125.0
	)
	transport.add_child(pause_button)

	transport.add_child(
		_create_button(
			"Stop",
			_stop_music,
			125.0
		)
	)

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
		165.0
	)
	layer_controls.add_child(backing_button)

	drums_button = _create_button(
		"Trommer: TIL",
		_toggle_drums,
		165.0
	)
	layer_controls.add_child(drums_button)

	low_pass_button = _create_button(
		"Low-pass: FRA",
		_toggle_low_pass,
		165.0
	)
	layer_controls.add_child(low_pass_button)

	var volume_row := HBoxContainer.new()
	volume_row.add_theme_constant_override(
		"separation",
		12
	)
	layout.add_child(volume_row)

	var volume_label := Label.new()
	volume_label.text = "Volume"
	volume_label.custom_minimum_size.x = 70
	volume_row.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = 0.8
	volume_slider.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	volume_slider.value_changed.connect(
		_on_volume_changed
	)
	volume_row.add_child(volume_slider)

	status_label = Label.new()
	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	status_label.add_theme_color_override(
		"font_color",
		Color("#f3c969")
	)
	layout.add_child(status_label)

	var shortcuts := Label.new()
	shortcuts.text = (
		"1–6 = monster  •  B = backing  •  D = drums\n" +
		"L = low-pass  •  C = fjern lead  •  Space = pause\n" +
		"R = start  •  S = stop"
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


func _select_character(
	character_id: StringName,
	character_name: String
) -> void:
	current_character = character_id
	current_character_name = character_name
	music_paused = false
	pause_button.text = "Pause"

	MusicManager.resume_date_music()
	MusicManager.set_music_volume(
		volume_slider.value
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

	_update_status("Backing toggled")


func _toggle_drums() -> void:
	drums_enabled = (
		MusicManager.toggle_drums(0.25)
	)

	drums_button.text = (
		"Trommer: TIL"
		if drums_enabled
		else "Trommer: FRA"
	)

	_update_status("Trommer toggled")


func _toggle_low_pass() -> void:
	low_pass_enabled = (
		MusicManager.toggle_low_pass(900.0)
	)

	low_pass_button.text = (
		"Low-pass: TIL"
		if low_pass_enabled
		else "Low-pass: FRA"
	)

	_update_status("Low-pass toggled")


func _on_volume_changed(
	value: float
) -> void:
	MusicManager.set_music_volume(value)


func _update_status(
	message: String
) -> void:
	status_label.text = message


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

		KEY_C:
			_clear_lead()

		KEY_R:
			_restart_music()

		KEY_S:
			_stop_music()

		_:
			return

	get_viewport().set_input_as_handled()
