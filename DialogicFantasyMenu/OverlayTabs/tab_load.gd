extends OverlayUI_Tab

## A tab that allows loading previously saved games.


func _ready() -> void:
	super()


func _open() -> void:
	## Reload the LoadMenu at the same page
	## This is needed, because the save tab might have changed the state of slots.
	$LoadMenu.load_page()


## When a slot is loaded, hide the menus.
func _on_load_menu_loaded() -> void:
	%OverlayUI.close()
	%MainMenu.hide()
