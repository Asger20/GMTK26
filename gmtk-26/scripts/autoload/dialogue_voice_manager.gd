extends Node

const SFX_BUS := &"SFX"
const PLAYER_COUNT := 6
const MIX_RATE := 44100
const BASE_FREQUENCY_HZ := 440.0
const SAMPLE_GAIN := 0.32
const VOICE_PROFILE_SCRIPT := preload(
	"res://scripts/resources/dialogue_voice_profile.gd"
)

const SILENT_CHARACTERS := " \t\n\r.,!?;:'\"-–—()[]{}"

var _players: Array[AudioStreamPlayer] = []
var _stream_cache: Dictionary = {}
var _active_profile: Resource
var _player_cursor := 0
var _audible_character_count := 0
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_ensure_sfx_bus()
	_random.randomize()

	for player_index in range(PLAYER_COUNT):
		var player := AudioStreamPlayer.new()
		player.name = "DialogueVoicePlayer%d" % (
			player_index + 1
		)
		player.bus = SFX_BUS
		add_child(player)
		_players.append(player)


func begin_line(profile: Resource) -> void:
	_active_profile = profile
	_audible_character_count = 0


func end_line() -> void:
	_active_profile = null
	_audible_character_count = 0


func speak(
	letter: String,
	_letter_index := 0,
	_speed := 1.0
) -> void:
	if (
		_active_profile == null
		or not _active_profile.enabled
		or not _is_audible_character(letter)
	):
		return

	var should_play := (
		_audible_character_count
		% maxi(
			_active_profile.characters_per_blip,
			1
		)
		== 0
	)
	_audible_character_count += 1

	if should_play:
		play_profile(_active_profile)


func play_profile(profile: Resource) -> void:
	if profile == null or not profile.enabled:
		return

	var player := _players[_player_cursor]
	_player_cursor = (
		_player_cursor + 1
	) % _players.size()

	player.stream = _get_voice_stream(profile)
	player.volume_db = profile.volume_db

	var pitch_variation := _random.randf_range(
		-profile.pitch_variation,
		profile.pitch_variation
	)
	player.pitch_scale = clampf(
		profile.pitch_scale * (1.0 + pitch_variation),
		0.05,
		4.0
	)
	player.play()


func clear_stream_cache() -> void:
	_stream_cache.clear()


func _ensure_sfx_bus() -> void:
	if AudioServer.get_bus_index(SFX_BUS) != -1:
		return

	AudioServer.add_bus()
	AudioServer.set_bus_name(
		AudioServer.bus_count - 1,
		SFX_BUS
	)


func _is_audible_character(letter: String) -> bool:
	if letter.is_empty():
		return false

	return not SILENT_CHARACTERS.contains(letter)


func _get_voice_stream(
	profile: Resource
) -> AudioStreamWAV:
	var cache_key := "%d:%.3f" % [
		profile.waveform,
		profile.duration_seconds,
	]

	if _stream_cache.has(cache_key):
		return _stream_cache[cache_key]

	var stream := _create_voice_stream(
		profile.waveform,
		profile.duration_seconds
	)
	_stream_cache[cache_key] = stream
	return stream


func _create_voice_stream(
	waveform: int,
	duration_seconds: float
) -> AudioStreamWAV:
	var sample_count := maxi(
		1,
		int(MIX_RATE * duration_seconds)
	)
	var audio_data := PackedByteArray()
	audio_data.resize(sample_count * 2)

	var noise_random := RandomNumberGenerator.new()
	noise_random.seed = 107 + waveform

	for sample_index in range(sample_count):
		var phase := fmod(
			float(sample_index)
			* BASE_FREQUENCY_HZ
			/ MIX_RATE,
			1.0
		)
		var waveform_sample := _get_waveform_sample(
			waveform,
			phase,
			noise_random
		)
		var progress := (
			float(sample_index)
			/ maxf(sample_count - 1, 1)
		)
		var attack := minf(progress / 0.08, 1.0)
		var release := pow(1.0 - progress, 2.0)
		var envelope := attack * release
		var sample_value := int(
			clampf(
				waveform_sample
				* envelope
				* SAMPLE_GAIN,
				-1.0,
				1.0
			) * 32767.0
		)

		audio_data.encode_s16(
			sample_index * 2,
			sample_value
		)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = audio_data
	return stream


func _get_waveform_sample(
	waveform: int,
	phase: float,
	noise_random: RandomNumberGenerator
) -> float:
	match waveform:
		VOICE_PROFILE_SCRIPT.Waveform.TRIANGLE:
			return 1.0 - 4.0 * abs(phase - 0.5)

		VOICE_PROFILE_SCRIPT.Waveform.SQUARE:
			return 1.0 if phase < 0.5 else -1.0

		VOICE_PROFILE_SCRIPT.Waveform.SAW:
			return phase * 2.0 - 1.0

		VOICE_PROFILE_SCRIPT.Waveform.NOISE:
			return noise_random.randf_range(-1.0, 1.0)

		_:
			return sin(TAU * phase)
