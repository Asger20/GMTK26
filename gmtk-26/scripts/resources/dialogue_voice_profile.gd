class_name DialogueVoiceProfile
extends Resource

enum Waveform {
	SINE,
	TRIANGLE,
	SQUARE,
	SAW,
	NOISE,
}

@export var enabled := true

@export_group("Pitch")
@export_range(0.25, 3.0, 0.01) var pitch_scale := 1.0
@export_range(0.0, 0.5, 0.01) var pitch_variation := 0.05

@export_group("Timbre")
@export var waveform := Waveform.SINE
@export_range(0.015, 0.12, 0.005) var duration_seconds := 0.04

@export_group("Rhythm")
@export_range(1, 8, 1) var characters_per_blip := 2

@export_group("Mix")
@export_range(-40.0, 6.0, 0.5) var volume_db := -14.0
