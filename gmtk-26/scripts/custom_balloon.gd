class_name CustomBalloon extends CanvasLayer

@export var dialogue_resource: DialogueResource
@export var start_from_title: String = ""
@export var will_block_other_input: bool = true
@export var next_action: StringName = &"ui_accept"
@export var skip_action: StringName = &"ui_cancel"

@onready var balloon: Control = $Balloon
@onready var dialogue_box: Panel = $Balloon/DialogueBox
@onready var speech_container: VBoxContainer = $Balloon/DialogueBox/Margin/SpeechContainer
@onready var character_label: RichTextLabel = $Balloon/DialogueBox/Margin/SpeechContainer/CharacterLabel
@onready var dialogue_label: DialogueLabel = $Balloon/DialogueBox/Margin/SpeechContainer/DialogueLabel
@onready var continue_prompt: Label = $Balloon/DialogueBox/Margin/SpeechContainer/ContinuePrompt

@onready var responses_container: VBoxContainer = $Balloon/DialogueBox/Margin/ResponsesContainer
@onready var responses_menu: DialogueResponsesMenu = $Balloon/DialogueBox/Margin/ResponsesContainer/ResponsesMenu

var temporary_game_states: Array = []
var is_waiting_for_input: bool = false
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			queue_free()
	get:
		return dialogue_line

func _ready() -> void:
	balloon.hide()
	balloon.gui_input.connect(_on_balloon_gui_input)
	if dialogue_box:
		dialogue_box.gui_input.connect(_on_balloon_gui_input)

	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action
	responses_menu.hide_failed_responses = true
	responses_menu.response_selected.connect(_on_responses_menu_response_selected)
	dialogue_label.spoke.connect(_on_dialogue_label_spoke)


func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not title.is_empty():
		start_from_title = title
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_title, temporary_game_states)
	show()

func apply_dialogue_line() -> void:
	is_waiting_for_input = false
	continue_prompt.hide()
	balloon.show()

	# Handle lines without spoken text (e.g. condition blocks or mutation nodes)
	if dialogue_line.text.strip_edges().is_empty():
		var valid_responses: Array = dialogue_line.responses.filter(func(r): return r.is_allowed)
		if valid_responses.size() > 0:
			var responses: Array = valid_responses
			if responses.size() > 4:
				responses = responses.slice(0, 4)
			if responses.size() > 0:
				# Pure choice container line: immediately show choices without a blank speech bubble!
				speech_container.hide()
				responses_container.show()
				responses_menu.responses = responses
				return
			else:
				next(dialogue_line.next_id)
				return
		else:
			# Empty control node: skip automatically to next line
			next(dialogue_line.next_id)
			return

	# SHOW MONSTER SPEECH VIEW FIRST FOR SPOKEN TEXT
	responses_container.hide()
	speech_container.show()

	var speaker_name = dialogue_line.character
	var current_monster = GameManager.get_current_date_monster()
	if current_monster and not speaker_name.is_empty():
		speaker_name = current_monster.display_name

	var voice_profile: Resource
	if (
		current_monster
		and not dialogue_line.character.is_empty()
		and dialogue_line.character.to_lower() != "you"
	):
		voice_profile = current_monster.dialogue_voice
	DialogueVoiceManager.begin_line(voice_profile)

	character_label.visible = not speaker_name.is_empty()
	character_label.text = "[b][color=#7a1c1c]" + tr(speaker_name, "dialogue") + "[/color][/b]"

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing
	DialogueVoiceManager.end_line()

	# WHEN MONSTER FINISHES SPEAKING: SHOW PROMPT & WAIT FOR PLAYER CLICK BEFORE ADVANCING/SHOWING CHOICES
	var valid_next_responses: Array = dialogue_line.responses.filter(func(r): return r.is_allowed)
	if valid_next_responses.size() > 0:
		continue_prompt.text = "[ CLICK TO SEE RESPONSES ▶ ]"
	else:
		continue_prompt.text = "[ CLICK TO CONTINUE ▶ ]"
	
	continue_prompt.show()
	is_waiting_for_input = true


func _on_balloon_gui_input(event: InputEvent) -> void:
	if dialogue_label.is_typing:
		var mouse_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_clicked or skip_pressed:
			get_viewport().set_input_as_handled()
			SFXManager.play_click()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return

	var is_click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	var is_accept: bool = event.is_action_pressed(next_action)

	if is_click or is_accept:
		get_viewport().set_input_as_handled()
		is_waiting_for_input = false
		continue_prompt.hide()

		var valid_responses: Array = dialogue_line.responses.filter(func(r): return r.is_allowed)
		if valid_responses.size() > 0:
			var responses: Array = valid_responses
			if responses.size() > 4:
				responses = responses.slice(0, 4)

			if responses.size() > 0:
				# PLAYER CLICKED TO SEE CHOICES: SWITCH TO CHOICE MENU (MAX 4 OPTIONS)
				SFXManager.play_switch()
				speech_container.hide()
				responses_container.show()
				responses_menu.responses = responses
			else:
				SFXManager.play_click()
				next(dialogue_line.next_id)
		else:
			# ADVANCE TO NEXT LINEAR DIALOGUE LINE
			SFXManager.play_click()
			next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	SFXManager.play_click()
	responses_container.hide()
	speech_container.show()
	next(response.next_id)


func _on_dialogue_label_spoke(
	letter: String,
	letter_index: int,
	speed: float
) -> void:
	DialogueVoiceManager.speak(
		letter,
		letter_index,
		speed
	)


func _exit_tree() -> void:
	DialogueVoiceManager.end_line()


func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)
