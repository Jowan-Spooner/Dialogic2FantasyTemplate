extends TextureButton

## Script for a slot in the save_load_interface.

## Emitted when clicked
signal selected
## Emitted when the Delete button is clicked
signal delete_request

@export var hover_bg_color := Color.DARK_ORANGE
@export var unhover_bg_color := Color.BLACK

## This should be set on the save_load_interface, for all slots.
var time_string := ""


func _ready() -> void:
	_on_mouse_exited()


func _on_pressed() -> void:
	if not $DeleteButton.button_pressed:
		selected.emit()


func _on_delete_button_pressed() -> void:
	delete_request.emit()


func clear() -> void:
	%SlotName.text = "Empty Slot"
	%SlotTime.text = ""
	$SlotImage.texture = null


## Loads the info, expecting a "name" and a "date" entry.
func load_info(slot_name: String) -> void:
	var info := Dialogic.Save.get_slot_info(slot_name)
	%SlotName.text = info.name
	%SlotTime.text = time_string.format(info.date)
	$SlotImage.texture = Dialogic.Save.get_slot_thumbnail(slot_name)


func _on_mouse_entered() -> void:
	## Hover animation
	var tween := create_tween()
	tween.tween_property($ColorTint, "self_modulate", hover_bg_color, 0.2)

	## If this slot isn't empty, show the delete button
	if $SlotImage.texture != null:
		$DeleteButton.show()


func _on_mouse_exited() -> void:
	## Hover ended animation
	var tween := create_tween()
	tween.tween_property($ColorTint, "self_modulate", unhover_bg_color, 0.2)

	## Hide the delete button
	$DeleteButton.hide()
