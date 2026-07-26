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
const AMBIENCE_BUS := &"Ambience"

const SILENT_DB := -60.0
const DEFAULT_LEAD_DB := 0.0
const DEFAULT_LOW_PASS_CUTOFF_HZ := 900.0
const DEFAULT_MOOD_DISTORTION_DRIVE := 0.40
const DEFAULT_MOOD_PITCH_SCALE := 0.40
const ANGRY_MOOD_DISTORTION_DRIVE := 0.15
const ANGRY_MOOD_PITCH_SCALE := 0.60

const STEMS := [
	preload("res://assets/music/backing.ogg"),
	preload("res://assets/music/drums.ogg"),
	preload("res://assets/music/lead_sea_monster.ogg"),
	preload("res://assets/music/lead_zombie.ogg"),
	preload("res://assets/music/lead_angel.ogg"),
	preload("res://assets/music/lead_insect.ogg"),
	preload("res://assets/music/lead_vampire.ogg"),
	preload("res://assets/music/lead_slime.ogg"),
]

const AMBIENCE_STREAM := preload(
	"res://assets/sfx/noise.ogg"
)

const CHARACTER_STEMS := {
	&"sea_monster": Stem.SEA_MONSTER,
	&"zombie": Stem.ZOMBIE,
	&"angel": Stem.ANGEL,
	&"insect": Stem.INSECT,
	&"bug_monster": Stem.INSECT,
	&"vampire": Stem.VAMPIRE,
	&"slime": Stem.SLIME,
}

var _music_player: AudioStreamPlayer
var _ambience_player: AudioStreamPlayer
var _synchronized_stream: AudioStreamSynchronized

var _current_lead_index := -1

var _backing_enabled := true
var _drums_enabled := true
var _low_pass_enabled := false
var _mood_effect_enabled := false
var _ambience_enabled := true

var _music_volume_linear := 0.8
var _ambience_volume_linear := 0.3

var _lead_tween: Tween
var _backing_tween: Tween
var _drums_tween: Tween
var _music_tween: Tween
var _ambience_tween: Tween

var _music_bus_index := -1
var _ambience_bus_index := -1
var _low_pass_effect_index := -1
var _distortion_effect_index := -1
var _pitch_shift_effect_index := -1

var _low_pass_filter: AudioEffectLowPassFilter
var _distortion_effect: AudioEffectDistortion
var _pitch_shift_effect: AudioEffectPitchShift


func _ready() -> void:
	_setup_music_bus()
	_setup_ambience_bus()

	_create_music_player()
	_create_ambience_player()
	_create_synchronized_stream()
	_initialize_stem_volumes()

	play_ambience()


# ------------------------------------------------------------------
# BUS SETUP
# ------------------------------------------------------------------

func _setup_music_bus() -> void:
	_music_bus_index = AudioServer.get_bus_index(
		MUSIC_BUS
	)

	if _music_bus_index == -1:
		AudioServer.add_bus()
		_music_bus_index = AudioServer.bus_count - 1

		AudioServer.set_bus_name(
			_music_bus_index,
			MUSIC_BUS
		)

	_find_or_create_mood_effects()
	_find_or_create_low_pass_filter()


func _setup_ambience_bus() -> void:
	_ambience_bus_index = AudioServer.get_bus_index(
		AMBIENCE_BUS
	)

	if _ambience_bus_index == -1:
		AudioServer.add_bus()
		_ambience_bus_index = AudioServer.bus_count - 1

		AudioServer.set_bus_name(
			_ambience_bus_index,
			AMBIENCE_BUS
		)


func _find_or_create_low_pass_filter() -> void:
	var effect_count := AudioServer.get_bus_effect_count(
		_music_bus_index
	)

	for effect_index in range(effect_count):
		var effect := AudioServer.get_bus_effect(
			_music_bus_index,
			effect_index
		)

		if effect is AudioEffectLowPassFilter:
			_low_pass_filter = (
				effect as AudioEffectLowPassFilter
			)
			_low_pass_effect_index = effect_index
			break

	if _low_pass_effect_index == -1:
		_low_pass_filter = AudioEffectLowPassFilter.new()
		_low_pass_filter.cutoff_hz = (
			DEFAULT_LOW_PASS_CUTOFF_HZ
		)
		_low_pass_filter.resonance = 0.2
		_low_pass_filter.db = (
			AudioEffectFilter.FILTER_12DB
		)

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


func _find_or_create_mood_effects() -> void:
	var effect_count := AudioServer.get_bus_effect_count(
		_music_bus_index
	)

	for effect_index in range(effect_count):
		var effect := AudioServer.get_bus_effect(
			_music_bus_index,
			effect_index
		)

		if (
			effect is AudioEffectDistortion
			and _distortion_effect_index == -1
		):
			_distortion_effect = (
				effect as AudioEffectDistortion
			)
			_distortion_effect_index = effect_index
		elif (
			effect is AudioEffectPitchShift
			and _pitch_shift_effect_index == -1
		):
			_pitch_shift_effect = (
				effect as AudioEffectPitchShift
			)
			_pitch_shift_effect_index = effect_index

	if _distortion_effect_index == -1:
		_distortion_effect = AudioEffectDistortion.new()
		_distortion_effect.drive = (
			DEFAULT_MOOD_DISTORTION_DRIVE
		)
		AudioServer.add_bus_effect(
			_music_bus_index,
			_distortion_effect
		)
		_distortion_effect_index = (
			AudioServer.get_bus_effect_count(
				_music_bus_index
			) - 1
		)

	if _pitch_shift_effect_index == -1:
		_pitch_shift_effect = AudioEffectPitchShift.new()
		_pitch_shift_effect.pitch_scale = (
			DEFAULT_MOOD_PITCH_SCALE
		)
		AudioServer.add_bus_effect(
			_music_bus_index,
			_pitch_shift_effect
		)
		_pitch_shift_effect_index = (
			AudioServer.get_bus_effect_count(
				_music_bus_index
			) - 1
		)

	set_mood_effect_enabled(false)


# ------------------------------------------------------------------
# PLAYER SETUP
# ------------------------------------------------------------------

func _create_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "DateMusicPlayer"
	_music_player.bus = MUSIC_BUS
	_music_player.volume_linear = _music_volume_linear

	add_child(_music_player)


func _create_ambience_player() -> void:
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "AmbiencePlayer"
	_ambience_player.bus = AMBIENCE_BUS
	_ambience_player.volume_linear = (
		_ambience_volume_linear
	)

	var ambience_stream := (
		AMBIENCE_STREAM.duplicate()
		as AudioStreamOggVorbis
	)

	ambience_stream.loop = true
	_ambience_player.stream = ambience_stream

	add_child(_ambience_player)


func _create_synchronized_stream() -> void:
	_synchronized_stream = AudioStreamSynchronized.new()
	_synchronized_stream.stream_count = STEMS.size()

	for stem_index in range(STEMS.size()):
		var stem_stream := (
			STEMS[stem_index].duplicate()
			as AudioStreamOggVorbis
		)

		stem_stream.loop = true

		_synchronized_stream.set_sync_stream(
			stem_index,
			stem_stream
		)

	_music_player.stream = _synchronized_stream


func _initialize_stem_volumes() -> void:
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


# ------------------------------------------------------------------
# DATING MUSIC
# ------------------------------------------------------------------

func play_date_music(
	character_id: StringName,
	fade_seconds := 0.4
) -> void:
	if _music_tween != null:
		_music_tween.kill()
		_music_tween = null

	_music_player.volume_linear = _music_volume_linear
	_music_player.stream_paused = false

	if not _music_player.playing:
		_music_player.play()

	set_low_pass_enabled(false)
	set_date_character(
		character_id,
		fade_seconds
	)


func play_between_dates(
	fade_seconds := 0.4
) -> void:
	if _music_tween != null:
		_music_tween.kill()
		_music_tween = null

	_music_player.volume_linear = _music_volume_linear
	_music_player.stream_paused = false

	if not _music_player.playing:
		_music_player.play()

	clear_date_character(fade_seconds)
	set_low_pass_enabled(true)


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


func pause_date_music() -> void:
	_music_player.stream_paused = true


func resume_date_music() -> void:
	_music_player.stream_paused = false


func stop_date_music(
	fade_seconds := 0.6
) -> void:
	if not _music_player.playing:
		return

	if _music_tween != null:
		_music_tween.kill()

	if fade_seconds <= 0.0:
		_finish_music_stop()
		return

	_music_tween = create_tween()
	_music_tween.tween_property(
		_music_player,
		"volume_db",
		SILENT_DB,
		fade_seconds
	)
	_music_tween.tween_callback(
		_finish_music_stop
	)


func set_music_volume(
	linear_volume: float
) -> void:
	_music_volume_linear = clampf(
		linear_volume,
		0.0,
		1.0
	)

	_music_player.volume_linear = _music_volume_linear


func _finish_music_stop() -> void:
	_music_player.stop()
	_music_player.volume_linear = _music_volume_linear

	_current_lead_index = -1
	_music_tween = null

	for stem_index in range(
		Stem.SEA_MONSTER,
		STEMS.size()
	):
		_synchronized_stream.set_sync_stream_volume(
			stem_index,
			SILENT_DB
		)


# ------------------------------------------------------------------
# BACKING AND DRUMS
# ------------------------------------------------------------------

func set_backing_enabled(
	enabled: bool,
	fade_seconds := 0.25
) -> void:
	_backing_enabled = enabled

	if _backing_tween != null:
		_backing_tween.kill()

	var target_volume := (
		0.0 if enabled else SILENT_DB
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
		0.0 if enabled else SILENT_DB
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


# ------------------------------------------------------------------
# MUSIC LOW-PASS
# ------------------------------------------------------------------

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


# ------------------------------------------------------------------
# MUSIC MOOD EFFECT
# ------------------------------------------------------------------

func set_mood_effect_enabled(
	enabled: bool,
	distortion_drive := DEFAULT_MOOD_DISTORTION_DRIVE,
	pitch_scale := DEFAULT_MOOD_PITCH_SCALE,
	volume_db_offset := 0.0
) -> void:
	_mood_effect_enabled = enabled

	_distortion_effect.drive = clampf(
		distortion_drive,
		0.0,
		1.0
	)
	_pitch_shift_effect.pitch_scale = clampf(
		pitch_scale,
		0.01,
		16.0
	)

	AudioServer.set_bus_effect_enabled(
		_music_bus_index,
		_distortion_effect_index,
		enabled
	)
	AudioServer.set_bus_effect_enabled(
		_music_bus_index,
		_pitch_shift_effect_index,
		enabled
	)

	if _music_bus_index != -1:
		var target_db = volume_db_offset if enabled else 0.0
		AudioServer.set_bus_volume_db(_music_bus_index, target_db)


func toggle_mood_effect(
	distortion_drive := DEFAULT_MOOD_DISTORTION_DRIVE,
	pitch_scale := DEFAULT_MOOD_PITCH_SCALE
) -> bool:
	set_mood_effect_enabled(
		not _mood_effect_enabled,
		distortion_drive,
		pitch_scale
	)

	return _mood_effect_enabled


func is_mood_effect_enabled() -> bool:
	return _mood_effect_enabled


# ------------------------------------------------------------------
# AMBIENCE
# ------------------------------------------------------------------

func play_ambience(
	fade_seconds := 0.0
) -> void:
	_ambience_enabled = true

	if _ambience_tween != null:
		_ambience_tween.kill()
		_ambience_tween = null

	if fade_seconds <= 0.0:
		_ambience_player.volume_linear = (
			_ambience_volume_linear
		)

		if not _ambience_player.playing:
			_ambience_player.play()

		return

	if not _ambience_player.playing:
		_ambience_player.volume_db = SILENT_DB
		_ambience_player.play()

	_ambience_tween = create_tween()
	_ambience_tween.tween_property(
		_ambience_player,
		"volume_linear",
		_ambience_volume_linear,
		fade_seconds
	)


func stop_ambience(
	fade_seconds := 0.5
) -> void:
	_ambience_enabled = false

	if _ambience_tween != null:
		_ambience_tween.kill()

	if not _ambience_player.playing:
		return

	if fade_seconds <= 0.0:
		_finish_ambience_stop()
		return

	_ambience_tween = create_tween()
	_ambience_tween.tween_property(
		_ambience_player,
		"volume_db",
		SILENT_DB,
		fade_seconds
	)
	_ambience_tween.tween_callback(
		_finish_ambience_stop
	)


func set_ambience_enabled(
	enabled: bool,
	fade_seconds := 0.5
) -> void:
	if enabled:
		play_ambience(fade_seconds)
	else:
		stop_ambience(fade_seconds)


func toggle_ambience(
	fade_seconds := 0.5
) -> bool:
	set_ambience_enabled(
		not _ambience_enabled,
		fade_seconds
	)

	return _ambience_enabled


func set_ambience_volume(
	linear_volume: float
) -> void:
	_ambience_volume_linear = clampf(
		linear_volume,
		0.0,
		1.0
	)

	if _ambience_enabled:
		_ambience_player.volume_linear = (
			_ambience_volume_linear
		)


func _finish_ambience_stop() -> void:
	_ambience_player.stop()
	_ambience_player.volume_db = SILENT_DB
	_ambience_tween = null


# ------------------------------------------------------------------
# INTERNAL
# ------------------------------------------------------------------

func _set_stem_volume(
	volume_db: float,
	stem_index: int
) -> void:
	_synchronized_stream.set_sync_stream_volume(
		stem_index,
		volume_db
	)
