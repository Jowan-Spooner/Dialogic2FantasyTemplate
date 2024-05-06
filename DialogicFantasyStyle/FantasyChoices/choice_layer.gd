@tool
extends DialogicLayoutLayer

## Layer that has a couple of choices


func _ready() -> void:
	## Connect choices to hovered and unhovered
	for child: Node in %Choices.get_children():
		if child is DialogicNode_ChoiceButton:
			child.mouse_entered.connect(_button_hovered.bind(child))
			child.mouse_exited.connect(_button_unhovered.bind(child))


func _button_hovered(button: Control) -> void:
	## Animation Hovered
	var tween := button.create_tween()
	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE*1.03, 0.2)


func _button_unhovered(button: Control) -> void:
	## Animation Hover Ended
	var tween := button.create_tween()
	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE*1, 0.2)
