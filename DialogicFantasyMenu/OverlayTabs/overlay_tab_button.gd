extends TextureButton

## Script that handles showing and hiding the button label

func _ready() -> void:
	$Label.hide()

	mouse_entered.connect(func(): if not disabled: $Label.show())
	mouse_exited.connect(func(): if not button_pressed: $Label.hide())
	toggled.connect(func(toggled_on):$Label.visible = toggled_on)
