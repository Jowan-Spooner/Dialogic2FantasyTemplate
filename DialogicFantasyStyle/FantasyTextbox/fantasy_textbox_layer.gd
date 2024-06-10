@tool
extends DialogicLayoutLayer

## This layer displays text, but also has a  bunch of useful buttons for use in-game.

var overlay_ui: Control = null

func _ready() -> void:
	Dialogic.Inputs.auto_skip.toggled.connect(_on_auto_skip_toggled)
	Dialogic.Inputs.auto_advance.toggled.connect(_on_auto_advance_toggled)
	if get_tree().root.has_node("Menus"):
		overlay_ui = get_tree().root.get_node("Menus/GUILayer/OverlayUI")


#region TOOL BUTTONS
################################################################################

func _on_history_pressed() -> void:
	# Take a thumbnail.
	# This is a special case, because it's possible to navigate from the history to the save page directly.
	Dialogic.Save.take_thumbnail()

	Dialogic.History.open_history()


func _on_skip_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.enabled = toggled_on
	Dialogic.Inputs.auto_advance.enabled_until_user_input = false

## Dialogic informs us that the autoskip state has changed
func _on_auto_skip_toggled(toggled_on: bool) -> void:
	%Skip.set_pressed_no_signal(toggled_on)


func _on_auto_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_advance.enabled_until_user_input = toggled_on
	Dialogic.Inputs.auto_skip.enabled = false


## Dialogic informs us that the autoadvance state has changed
func _on_auto_advance_toggled(toggled_on: bool) -> void:
	%Auto.set_pressed_no_signal(toggled_on)


func _on_save_pressed() -> void:
	if overlay_ui:
		Dialogic.Save.take_thumbnail()
		overlay_ui.open_save_menu()


func _on_q_save_pressed() -> void:
	Dialogic.Save.save(Dialogic.Save.get_latest_slot())
	Dialogic.Save.set_slot_info(Dialogic.Save.get_latest_slot(),
		{
			"name" : Dialogic.Save.get_latest_slot().capitalize(),
			"date" : Time.get_datetime_dict_from_system()
		})


func _on_q_load_pressed() -> void:
	Dialogic.Save.load(Dialogic.Save.get_latest_slot())


func _on_options_pressed() -> void:
	if overlay_ui:
		# Take a thumbnail.
		# This is a special case, because it's possible to navigate from the options to the save page directly.
		Dialogic.Save.take_thumbnail()
		overlay_ui.open_options_menu()

#endregion

func _input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("skip_dialog"):
		Dialogic.Inputs.auto_skip.enabled = true
	elif Input.is_action_just_released("skip_dialog"):
		Dialogic.Inputs.auto_skip.enabled = false
