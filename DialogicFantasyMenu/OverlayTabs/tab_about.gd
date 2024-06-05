extends OverlayUI_Tab

## Tab that does nothing, but could display some stuff.


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	if meta.begins_with("http"):
		OS.shell_open(meta)
