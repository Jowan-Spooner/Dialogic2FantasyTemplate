extends CanvasLayer

## Script that manages the main menu buttons

## A tween that controls the pitch of the main menu button sounds
## These sounds get higher pitched, when buttons are hovered in quick succession
var main_menu_button_pitch_tween: Tween

@export var beginning_timeline := "TestTimeline"

func _ready() -> void:
	## Connect buttons to hovered, unhovered and pressed
	for button: Node in %MainMenuButtons.get_children():
		if not button is Button:
			continue
		button.mouse_entered.connect(_on_button_hovered.bind(button))
		button.mouse_exited.connect(_on_button_unhovered.bind(button))
		button.pressed.connect(_on_button_pressed.bind(button))

	open()

	Dialogic.signal_event.connect(_on_dialogic_signal_event)


func open() -> void:
	show()

	## When there is a save to continue from, show the Continue button
	## and make the Continue button special, instead of the start one.
	%Continue.visible = not Dialogic.Save.get_latest_slot().is_empty()
	if %Continue.visible:
		%Continue.grab_focus()
		%Start.theme_type_variation = ""
		%Start.flat = true
	else:
		%Start.grab_focus()
		%Start.theme_type_variation = "SpecialButton"
		%Start.flat = false

	## Don't show the Quit button on the web
	%Quit.visible = !OS.has_feature("web")


func _on_dialogic_signal_event(arg: Variant) -> void:
	if arg == "GAME_END":
		Dialogic.clear()
		## Assuming that the end of the game was reached,
		## We don't want to keep suggestion to "Continue" from the last save.
		Dialogic.Save.set_latest_slot("")
		open()


#region BUTTON FUNCTIONALITY
################################################################################

func _on_start_pressed() -> void:
	Dialogic.start(beginning_timeline)
	hide()


func _on_continue_pressed() -> void:
	Dialogic.Save.load(Dialogic.Save.get_latest_slot())
	hide()


func _on_load_pressed() -> void:
	%OverlayUI.open_load_menu()


func _on_options_pressed() -> void:
	%OverlayUI.open_options_menu()


func _on_about_pressed() -> void:
	%OverlayUI.open_about_menu()


func _on_help_pressed() -> void:
	%OverlayUI.open_help_menu()


func _on_quit_pressed() -> void:
	get_tree().quit()

#endregion


#region BUTTON HOVER/UNHOVER
################################################################################

func _on_button_hovered(button:Button) -> void:
	## Hover Animation
	var tween := button.create_tween()
	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE * 1.1, 0.2)

	## Hover sound
	%ButtonHoverSound.play()


func _on_button_unhovered(button:Button) -> void:
	## Hover Ended Animation
	var tween := button.create_tween()
	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE, 0.2)


func _on_main_menu_button_sound_finished() -> void:
	## Tween the button pitch to increase and then decrease after a second.
	## As this get's interrupted by following hover sounds,
	##  the pitch can increase for a while
	if main_menu_button_pitch_tween:
		main_menu_button_pitch_tween.kill()

	main_menu_button_pitch_tween = create_tween()

	## First increase the pitch
	main_menu_button_pitch_tween.tween_property(
		%ButtonHoverSound, "pitch_scale",
		lerp(%ButtonHoverSound.pitch_scale, 1.3, 0.1), 0.3)
	## Then decrease it
	main_menu_button_pitch_tween.tween_property(
		%ButtonHoverSound, "pitch_scale", 0.6, 2)


func _on_button_pressed(button: Button) -> void:
	%ButtonPressedSound.play()

#endregion

