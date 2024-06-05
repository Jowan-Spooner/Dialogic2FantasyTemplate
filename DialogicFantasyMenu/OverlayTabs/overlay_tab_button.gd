extends TextureButton

## Script that handles showing and hiding the button label

func _ready() -> void:
	$Label.hide()

	mouse_entered.connect(func(): if not disabled: $Label.show())
	mouse_exited.connect(func(): if not button_pressed: $Label.hide())
	toggled.connect(on_toggled)


func on_toggled(toggled_on):
	$Label.visible = toggled_on
	# Needed to avoid some button nonsense
	# (it would visually hide when already toggled and pressed,
	# even though unselecting is not allowed)
	if toggled_on:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
