extends Control

## Script that handles opening and closing of the book overlay


## Strength of the paralax effect on the overlay menu.
@export var paralax_strength := 10

## Updated by some menus. Used to display or not display warnings when closing.
var has_just_saved := false


func _ready() -> void:
	hide()


func open() -> void:
	if visible:
		return

	## Pause the game (this menu won't be paused)
	get_tree().paused = true

	## Opening Animation
	show()
	pivot_offset = size/2
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).from(Vector2.ONE*0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.1).from(Color.TRANSPARENT)

	## Disable Save and Pause tab when no game is running
	if %MainMenu.visible:
		%SaveTab.disable()
		%PauseTab.disable()
		has_just_saved = true
	else:
		has_just_saved = false
		enable_all_tabs()


func close() -> void:
	## Closing Animation
	pivot_offset = size/2
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE*0.9, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.tween_callback(hide)
	## Make sure to unpause the game
	tween.tween_callback(get_tree().set.bind("paused", false))


	## Reload the main menu in case something was saved, or a save deleted
	if %MainMenu.visible:
		%MainMenu.open()


## Handle opening and closing the menu
func _input(event:InputEvent) -> void:
	## Close the menu on ESC
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()

	## Open the pause menu (this only works during gameplay)
	if event.is_action_pressed("open_overlay_menu"):
		if not visible and not %MainMenu.visible:
			Dialogic.Save.take_thumbnail()
			open_pause_menu()


func _on_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _on_close_button_pressed() -> void:
	close()


## Enables all the tabs buttons
func enable_all_tabs() -> void:
	for tab in %Tabs.get_children():
		tab.enable()


## Hides all the tabs
func close_all_tabs() -> void:
	for tab in %Tabs.get_children():
		tab.close()


## Hides all the tabs and opens the given one
func open_tab(tab:Control) -> void:
	close_all_tabs()
	tab.open()
	open()


#region HELPERS
################################################################################
func open_pause_menu() -> void:
	open_tab(%PauseTab)

func open_save_menu() -> void:
	open_tab(%SaveTab)

func open_load_menu() -> void:
	open_tab(%LoadTab)

func open_options_menu() -> void:
	open_tab(%OptionsTab)

func open_history_menu() -> void:
	open_tab(%HistoryTab)

func open_about_menu() -> void:
	open_tab(%AboutTab)

func open_help_menu() -> void:
	open_tab(%HelpTab)

#endregion

#region PARALAX EFFECT
################################################################################
func _process(_delta: float) -> void:
	var relative_mouse_offset: Vector2 = get_global_mouse_position() / Vector2(get_viewport().size) - Vector2.ONE
	position = relative_mouse_offset * paralax_strength

#endregion


