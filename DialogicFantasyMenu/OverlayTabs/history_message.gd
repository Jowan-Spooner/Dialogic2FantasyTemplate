extends VBoxContainer

var character_joined_text := "{character} entered."
var character_left_text := "{character} left."
var all_character_left_text := "Everyone left."

@export var dot_image: Texture = null


func load_info(info:Dictionary) -> void:
	%Speaker.hide()

	match info.event_type:
		"Text":
			%Message.text = info['text']

			if not info.get('character', null) == null:
				%Speaker.text = info.character
				%Speaker.modulate = info.character_color
				%Speaker.show()

		"Character":
			match info.mode:
				"Join":
					%Message.text = '[i]' + character_joined_text.format(info)
				"Left":
					if info.character == "All":
						%Message.text = '[i]' + all_character_left_text.format(info)
					else:
						%Message.text = '[i]' + character_left_text.format(info)

		"Choice":
			var choices_text: String = ""
			for choice_text: String in info['all_choices']:
				if choice_text.ends_with('#disabled'):
					choices_text += "- [i]({choice_text})[/i]\n".format({"choice_text":choice_text.trim_suffix('#disabled')})

				elif choice_text == info['text']:
					choices_text += "- [b]{choice_text}[/b]\n".format({"choice_text":choice_text})

				else:
					choices_text += "- {choice_text}\n".format({"choice_text":choice_text})

			%Message.text = choices_text
