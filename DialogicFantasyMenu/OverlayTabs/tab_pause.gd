extends OverlayUI_Tab

## Tab that contains navigational buttons.
## Only accessible while a game is running.


func _ready() -> void:
	super()


func _open() -> void:
	## Don't present the option to quit on the web
	%PauseQuit.visible = !OS.has_feature("web")



## Closes the overlay UI
func _on_resume_pressed() -> void:
	%OverlayUI.close()


## Calls [method go_to_main_menu] or presents a warning, if there is unsaved progress.
func _on_main_menu_pressed() -> void:
	if not %OverlayUI.has_just_saved:
		%WarningDialog.warn("Careful, unsaved progress will be lost!",
			[
				{"text":"Main Menu", "action":go_to_main_menu}
			])
	else:
		go_to_main_menu()


## Allows to quit, but asks the player if they are sure.
func _on_quit_pressed() -> void:
	%WarningDialog.warn("Are you sure you want to quit?",
		[
			{"text":"Quit", "action":get_tree().quit}
		])


## Stops dialogic, closes the overlay UI and opens the main menu
func go_to_main_menu() -> void:
	Dialogic.end_timeline()
	Dialogic.clear()
	%MainMenu.open()
	%OverlayUI.close()
