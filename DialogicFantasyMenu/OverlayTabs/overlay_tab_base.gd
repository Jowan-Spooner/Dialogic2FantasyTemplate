class_name OverlayUI_Tab
extends Control

## Base script for the "Tabs" of the overlay UI

## Reference to the "tab" button for this tab
@export var button: TextureButton = null


func _ready() -> void:
	if button:
		button.pressed.connect(%OverlayUI.open_tab.bind(self))


## Show this tab and it's button
func open() -> void:
	show()
	if button:
		button.button_pressed = true
	_open()


## Hide this tab
func close() -> void:
	hide()
	_close()


## Disable this tabs button
func disable() -> void:
	if button:
		button.disabled = true


## Enable this tabs button
func enable() -> void:
	if button:
		button.disabled = false


## To be overwritten
func _open() -> void:
	pass


## To be overwritten
func _close() -> void:
	pass
