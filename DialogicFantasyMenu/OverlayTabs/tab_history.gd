extends OverlayUI_Tab

## A tab that displays the recent game history.

## Reference to a PackedScene that represents each "entry"
const HistoryItem := preload("res://DialogicFantasyMenu/OverlayTabs/history_message.tscn")


func _ready() -> void:
	super()

	## Connect to the open_requested signal of the history subsystem
	Dialogic.History.open_requested.connect(%OverlayUI.open_history_menu)


## Reloads the history
func _open() -> void:
	## Clear previous items
	for child: Node in %HistoryList.get_children():
		child.queue_free()

	## Add all history entries
	for info: Dictionary in Dialogic.History.get_simple_history():
		var history_item : Node = HistoryItem.instantiate()
		history_item.load_info(info)

		%HistoryList.add_child(history_item)

	## Wait one frame (until all the nodes are correctly added and sized)
	## Then scroll to last message
	await get_tree().process_frame
	$Scroll.ensure_control_visible(%HistoryList.get_child(-1))
