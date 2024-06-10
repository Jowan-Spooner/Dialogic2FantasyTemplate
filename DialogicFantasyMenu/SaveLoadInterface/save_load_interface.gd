extends VBoxContainer

## Script that manages saving and loading and displaying save slots.
## This is used by the save and the load tab.

## Emmitted when in load mode, and slot was loaded
signal loaded
## Emitted when in save mode and a slot was saved
signal saved
## Emitted when the page changed
signal page_changed(page_index:int)

var slots_per_page := 4
## The time string used on all the slots.
@export var time_string := "{day}/{month}/{year} | {hour}:{minute}"

enum Modes {SAVE, LOAD}
@export var mode := Modes.SAVE
@export var WarningDialog: Control = null

## The current page index
var page_index := 0


func _ready() -> void:
	$SlotPageButtons/Page1.button_group.pressed.connect(_on_page_selected)
	for slot in $Slots.get_children():
		slot.selected.connect(_on_slot_button_selected.bind(slot.get_index()))
		slot.time_string = time_string
		slot.delete_request.connect(_on_slot_delete_request.bind(slot.get_index()))

	load_page(Dialogic.Save.get_global_info("save_load_page", 0))


## Triggers, when a page button was pressed
func _on_page_selected(button: Button) -> void:
	load_page(button.get_index())
	page_changed.emit(button.get_index())


## Loads the slots on that page
func load_page(new_page_index := page_index) -> void:
	page_index = new_page_index

	for i in $Slots.get_children():
		i.clear()
		var slot_name := get_slot_name(i.get_index())
		if Dialogic.Save.has_slot(slot_name):
			i.load_info(slot_name)

	$SlotPageButtons.get_child(page_index).button_pressed = true
	Dialogic.Save.set_global_info("save_load_page", page_index)


## Saves or loads the slot, depending on the [mode]
func _on_slot_button_selected(button_index: int) -> void:
	var slot_name := get_slot_name(button_index)

	if mode == Modes.SAVE:
		if Dialogic.Save.has_slot(slot_name):
			WarningDialog.warn("Slot will be overwritten!",
				[
					{"text":"Overwrite", "action":save_to_slot.bind(slot_name)}
				])
		else:
			save_to_slot(slot_name)


	elif mode == Modes.LOAD:
		if Dialogic.Save.has_slot(slot_name):
			if find_parent("OverlayUI").has_just_saved:
				load_slot(slot_name)
			else:
				WarningDialog.warn("Unsaved progress will be lost.",
					[
						{"text":"Load", "action":load_slot.bind(slot_name)}
					])


func save_to_slot(slot_name:String) -> void:
	## Save slot and some additional slot info
	## Don't take a thumbnail now, to avoid just seeing the save menu.
	## The thumbnail should already have been taking before opening the options menu.
	Dialogic.Save.save(slot_name, false, Dialogic.Save.ThumbnailMode.STORE_ONLY)
	Dialogic.Save.set_slot_info(
		slot_name,
		{
			"name" : slot_name.capitalize(),
			"date" : Time.get_datetime_dict_from_system()
		})
	load_page(page_index)
	saved.emit()


func load_slot(slot_name:String) -> void:
	Dialogic.Save.load(slot_name)
	loaded.emit()


func _on_slot_delete_request(button_index: int) -> void:
	if WarningDialog:
		WarningDialog.warn("Are you sure you want to delete this slot?",
			[
				{"text":"Yes", "action":delete_slot.bind(get_slot_name(button_index))},
				{"text":"No"}
			], false)


## Deletes the slot
func delete_slot(slot_name:String) -> void:
	Dialogic.Save.delete_slot(slot_name)
	load_page(page_index)


## Helper that returns the name for the slot at the button (considering the page)
func get_slot_name(button_index: int) -> String:
	return "slot_"+str(page_index * slots_per_page + button_index)
