extends Node

enum Stem {
	BACKING,
	DRUMS,
	SEA_MONSTER,
	ZOMBIE,
	ANGEL,
	INSECT,
	VAMPIRE,
	SLIME,
}

const MUSIC_BUS := &"Music"

const SILENT_DB := -60.0
const DEFAULT_LEAD_DB := 0.0
const DEFAULT_LOW_PASS_CUTOFF_HZ := 900.0

const STEMS := [
	preload("res://assets/music/backing.wav"),
	preload("res://assets/music/drums.wav"),
	preload("res://assets/music/lead_sea_monster.wav"),
	preload("res://assets/music/lead_zombie.wav"),
	preload("res://assets/music/lead_angel.wav"),
	preload("res://assets/music/lead_insect.wav"),
	preload("res://assets/music/lead_vampire.wav"),
	preload("res://assets/music/lead_slime.wav"),
]

const CHARACTER_STEMS := {
	&"sea_monster": Stem.SEA_MONSTER,
	&"zombie": Stem.ZOMBIE,
	&"angel": Stem.ANGEL,
	&"insect": Stem.INSECT,
	&"vampire": Stem.VAMPIRE,
	&"slime": Stem.SLIME,
}

var _player: AudioStreamPlayer
var _synchronized_stream: AudioStreamSynchronized

var _current_lead_index := -1

var _backing_enabled := true
var _drums_enabled := true
var _low_pass_enabled := false

var _music_volume_linear := 0.8

var _lead_tween: Tween
var _backing_tween: Tween
var _drums_tween: Tween
var _master_tween: Tween

var _music_bus_index := -1
var _low_pass_effect_index := -1
var _low_pass_filter: AudioEffectLowPassFilter


func _ready() -> void:
	_setup_music_bus()
	_create_player()
	_create_synchronized_stream()
	_initialize_volumes()


func _setup_music_bus() -> void:
	_music_bus_index = AudioServer.get_bus_index(MUSIC_BUS)

	if _music_bus_index == -1:
		AudioServer.add_bus()
		_music_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(
			_music_bus_index,
			MUSIC_BUS
		)

	for effect_index in range(
		AudioServer.get_bus_effect_count(_music_bus_index)
	):
		var effect := AudioServer.get_bus_effect(
			_music_bus_index,
			effect_index
		)

		if effect is AudioEffectLowPassFilter:
			_low_pass_filter = effect as AudioEffectLowPassFilter
			_low_pass_effect_index = effect_index
			break

	if _low_pass_effect_index == -1:
		_low_pass_filter = AudioEffectLowPassFilter.new()
		_low_pass_filter.cutoff_hz = (
			DEFAULT_LOW_PASS_CUTOFF_HZ
		)
		_low_pass_filter.resonance = 0.2
		_low_pass_filter.db = AudioEffectFilter.FILTER_12DB

		AudioServer.add_bus_effect(
			_music_bus_index,
			_low_pass_filter
		)

		_low_pass_effect_index = (
			AudioServer.get_bus_effect_count(
				_music_bus_index
			) - 1
		)

	AudioServer.set_bus_effect_enabled(
		_music_bus_index,
		_low_pass_effect_index,
		false
	)


func _create_player() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "DateMusicPlayer"
	_player.bus = MUSIC_BUS
	_player.volume_linear = _music_volume_linear
	add_child(_player)


func _create_synchronized_stream() -> void:
	_synchronized_stream = AudioStreamSynchronized.new()
	_synchronized_stream.stream_count = STEMS.size()

	for stem_index in range(STEMS.size()):
		_synchronized_stream.set_sync_stream(
			stem_index,
			STEMS[stem_index]
		)

	_player.stream = _synchronized_stream


func _initialize_volumes() -> void:
	_synchronized_stream.set_sync_stream_volume(
		Stem.BACKING,
		0.0
	)

	_synchronized_stream.set_sync_stream_volume(
		Stem.DRUMS,
		0.0
	)

	for stem_index in range(
		Stem.SEA_MONSTER,
		STEMS.size()
	):
		_synchronized_stream.set_sync_stream_volume(
			stem_index,
			SILENT_DB
		)


func play_date_music(
	character_id: StringName,
	fade_seconds := 0.4
) -> void:
	if _master_tween != null:
		_master_tween.kill()
		_master_tween = null

	_player.volume_linear = _music_volume_linear

	if not _player.playing:
		_player.play()

	_player.stream_paused = false

	set_date_character(
		character_id,
		fade_seconds
	)


func set_date_character(
	character_id: StringName,
	fade_seconds := 0.4
) -> void:
	var next_lead_index: int = CHARACTER_STEMS.get(
		character_id,
		-1
	)

	if next_lead_index == -1:
		push_warning(
			"Unknown date character: %s" % character_id
		)
		return

	if next_lead_index == _current_lead_index:
		return

	if _lead_tween != null:
		_lead_tween.kill()

	for stem_index in range(
		Stem.SEA_MONSTER,
		STEMS.size()
	):
		if (
			stem_index != _current_lead_index
			and stem_index != next_lead_index
		):
			_synchronized_stream.set_sync_stream_volume(
				stem_index,
				SILENT_DB
			)

	if fade_seconds <= 0.0:
		if _current_lead_index != -1:
			_synchronized_stream.set_sync_stream_volume(
				_current_lead_index,
				SILENT_DB
			)

		_synchronized_stream.set_sync_stream_volume(
			next_lead_index,
			DEFAULT_LEAD_DB
		)

		_current_lead_index = next_lead_index
		return

	_lead_tween = create_tween()
	_lead_tween.set_parallel(true)

	if _current_lead_index != -1:
		var old_volume := (
			_synchronized_stream.get_sync_stream_volume(
				_current_lead_index
			)
		)

		_lead_tween.tween_method(
			_set_stem_volume.bind(
				_current_lead_index
			),
			old_volume,
			SILENT_DB,
			fade_seconds
		)

	var new_volume := (
		_synchronized_stream.get_sync_stream_volume(
			next_lead_index
		)
	)

	_lead_tween.tween_method(
		_set_stem_volume.bind(next_lead_index),
		new_volume,
		DEFAULT_LEAD_DB,
		fade_seconds
	)

	_current_lead_index = next_lead_index


func clear_date_character(
	fade_seconds := 0.4
) -> void:
	if _current_lead_index == -1:
		return

	if _lead_tween != null:
		_lead_tween.kill()

	var previous_lead := _current_lead_index
	_current_lead_index = -1

	if fade_seconds <= 0.0:
		_synchronized_stream.set_sync_stream_volume(
			previous_lead,
			SILENT_DB
		)
		return

	var current_volume := (
		_synchronized_stream.get_sync_stream_volume(
			previous_lead
		)
	)

	_lead_tween = create_tween()
	_lead_tween.tween_method(
		_set_stem_volume.bind(previous_lead),
		current_volume,
		SILENT_DB,
		fade_seconds
	)


func set_backing_enabled(
	enabled: bool,
	fade_seconds := 0.25
) -> void:
	_backing_enabled = enabled

	if _backing_tween != null:
		_backing_tween.kill()

	var target_volume := (
		0.0 if enabled
		else SILENT_DB
	)

	var current_volume := (
		_synchronized_stream.get_sync_stream_volume(
			Stem.BACKING
		)
	)

	if fade_seconds <= 0.0:
		_synchronized_stream.set_sync_stream_volume(
			Stem.BACKING,
			target_volume
		)
		return

	_backing_tween = create_tween()
	_backing_tween.tween_method(
		_set_stem_volume.bind(Stem.BACKING),
		current_volume,
		target_volume,
		fade_seconds
	)


func toggle_backing(
	fade_seconds := 0.25
) -> bool:
	set_backing_enabled(
		not _backing_enabled,
		fade_seconds
	)

	return _backing_enabled


func set_drums_enabled(
	enabled: bool,
	fade_seconds := 0.25
) -> void:
	_drums_enabled = enabled

	if _drums_tween != null:
		_drums_tween.kill()

	var target_volume := (
		0.0 if enabled
		else SILENT_DB
	)

	var current_volume := (
		_synchronized_stream.get_sync_stream_volume(
			Stem.DRUMS
		)
	)

	if fade_seconds <= 0.0:
		_synchronized_stream.set_sync_stream_volume(
			Stem.DRUMS,
			target_volume
		)
		return

	_drums_tween = create_tween()
	_drums_tween.tween_method(
		_set_stem_volume.bind(Stem.DRUMS),
		current_volume,
		target_volume,
		fade_seconds
	)


func toggle_drums(
	fade_seconds := 0.25
) -> bool:
	set_drums_enabled(
		not _drums_enabled,
		fade_seconds
	)

	return _drums_enabled


func set_low_pass_enabled(
	enabled: bool,
	cutoff_hz := DEFAULT_LOW_PASS_CUTOFF_HZ
) -> void:
	_low_pass_enabled = enabled

	_low_pass_filter.cutoff_hz = clampf(
		cutoff_hz,
		20.0,
		20500.0
	)

	AudioServer.set_bus_effect_enabled(
		_music_bus_index,
		_low_pass_effect_index,
		enabled
	)


func toggle_low_pass(
	cutoff_hz := DEFAULT_LOW_PASS_CUTOFF_HZ
) -> bool:
	set_low_pass_enabled(
		not _low_pass_enabled,
		cutoff_hz
	)

	return _low_pass_enabled


func pause_date_music() -> void:
	_player.stream_paused = true


func resume_date_music() -> void:
	_player.stream_paused = false


func stop_date_music(
	fade_seconds := 0.6
) -> void:
	if not _player.playing:
		return

	if _master_tween != null:
		_master_tween.kill()

	if fade_seconds <= 0.0:
		_finish_stop()
		return

	_master_tween = create_tween()
	_master_tween.tween_property(
		_player,
		"volume_db",
		SILENT_DB,
		fade_seconds
	)
	_master_tween.tween_callback(_finish_stop)


func set_music_volume(
	linear_volume: float
) -> void:
	_music_volume_linear = clampf(
		linear_volume,
		0.0,
		1.0
	)

	_player.volume_linear = _music_volume_linear


func _set_stem_volume(
	volume_db: float,
	stem_index: int
) -> void:
	_synchronized_stream.set_sync_stream_volume(
		stem_index,
		volume_db
	)


func _finish_stop() -> void:
	_player.stop()
	_player.volume_linear = _music_volume_linear
	_current_lead_index = -1
	_master_tween = null

	for stem_index in range(
		Stem.SEA_MONSTER,
		STEMS.size()
	):
		_synchronized_stream.set_sync_stream_volume(
			stem_index,
			SILENT_DB
		)
