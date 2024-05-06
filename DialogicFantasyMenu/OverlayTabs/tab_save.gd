extends OverlayUI_Tab

## A tab that allows saving to slots.

func _ready() -> void:
	super()


## Update the [has_just_saved] flag, which is used by "Unsaved Progress" warnings
func _on_save_menu_saved() -> void:
	%OverlayUI.has_just_saved = true
