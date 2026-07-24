extends Node

const SFX_BUS := &"SFX"

const CLICK := &"click"
const ROLLOVER := &"rollover"
const SWITCH := &"switch"
const POWER_UP := &"power_up"

const STREAMS := {
	CLICK: preload("res://assets/sfx/click.ogg"),
	ROLLOVER: preload("res://assets/sfx/rollover.ogg"),
	SWITCH: preload("res://assets/sfx/switch.ogg"),
	POWER_UP: preload("res://assets/sfx/powerUp.ogg"),
}

const UI_SFX_CONNECTED_META := &"_ui_sfx_connected"
const DISABLE_UI_SFX_META := &"disable_ui_sfx"

var _players: Dictionary = {}
var _enabled := true


func _ready() -> void:
	_ensure_sfx_bus()
	_create_players()

	get_tree().node_added.connect(_on_node_added)

	for node in get_tree().root.find_children(
		"*",
		"BaseButton",
		true,
		false
	):
		_connect_ui_node(node)


func play(sfx_id: StringName) -> void:
	if not _enabled:
		return

	var player: AudioStreamPlayer = _players.get(sfx_id)
	if player == null:
		push_warning("Unknown SFX: %s" % sfx_id)
		return

	player.play()


func play_click() -> void:
	play(CLICK)


func play_rollover() -> void:
	play(ROLLOVER)


func play_switch() -> void:
	play(SWITCH)


func play_power_up() -> void:
	play(POWER_UP)


func set_enabled(enabled: bool) -> void:
	_enabled = enabled


func is_enabled() -> bool:
	return _enabled


func _ensure_sfx_bus() -> void:
	if AudioServer.get_bus_index(SFX_BUS) != -1:
		return

	AudioServer.add_bus()
	AudioServer.set_bus_name(
		AudioServer.bus_count - 1,
		SFX_BUS
	)


func _create_players() -> void:
	for sfx_id in STREAMS:
		var player := AudioStreamPlayer.new()
		player.name = "%sPlayer" % String(sfx_id).to_pascal_case()
		player.bus = SFX_BUS
		player.stream = STREAMS[sfx_id]
		player.max_polyphony = 4

		_players[sfx_id] = player
		add_child(player)


func _on_node_added(node: Node) -> void:
	_connect_ui_node(node)


func _connect_ui_node(node: Node) -> void:
	if node.get_meta(DISABLE_UI_SFX_META, false):
		return

	if node.get_meta(UI_SFX_CONNECTED_META, false):
		return

	if node is BaseButton:
		var button := node as BaseButton
		button.pressed.connect(
			_on_button_pressed.bind(button)
		)
		button.mouse_entered.connect(
			_on_button_hovered.bind(button)
		)
		button.set_meta(UI_SFX_CONNECTED_META, true)

		if button is OptionButton:
			button.item_selected.connect(
				_on_selection_changed
			)
	elif node is TabContainer:
		node.tab_changed.connect(_on_selection_changed)
		node.set_meta(UI_SFX_CONNECTED_META, true)
	elif node is TabBar:
		var tab_bar := node as TabBar
		if tab_bar.get_parent() is TabContainer:
			return

		tab_bar.tab_changed.connect(_on_selection_changed)
		node.set_meta(UI_SFX_CONNECTED_META, true)


func _on_button_pressed(button: BaseButton) -> void:
	if not button.disabled:
		play_click()


func _on_button_hovered(button: BaseButton) -> void:
	if not button.disabled and button.is_visible_in_tree():
		play_rollover()


func _on_selection_changed(_index: int) -> void:
	play_switch()
