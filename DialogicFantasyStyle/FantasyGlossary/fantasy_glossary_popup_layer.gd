@tool
extends DialogicLayoutLayer



func _ready() -> void:
	if Engine.is_editor_hint():
		return

	set_process(false)

	Dialogic.Text.animation_textbox_hide.connect($Pointer.hide)
	Dialogic.Text.meta_hover_started.connect(_on_dialogic_text_meta_hover_started)
	Dialogic.Text.meta_hover_ended.connect(_on_dialogic_text_meta_hover_ended)


func _on_dialogic_text_meta_hover_started(meta: String) -> void:
	$Pointer.show()
	set_process(true)

	var meta_info := Dialogic.Glossary.get_entry(meta)

	%Title.text = meta_info.title
	%Text.text = meta_info.text
	%Extra.text = meta_info.extra

	%Title.modulate = meta_info.color



func _on_dialogic_text_meta_hover_ended(_meta: String) -> void:
	$Pointer.hide()
	set_process(false)


func _process(_delta: float) -> void:
	$Pointer.global_position = $Pointer.get_global_mouse_position()
