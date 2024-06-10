# Dialogic Fantasy Template
<img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/94a939e3-5253-4b75-bc78-eae3ccc1c094" width="45%"></img><img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/5ea8707f-7b7c-4a8b-89fb-5c7b595b31aa" width="45%"></img>
<img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/158c7d24-a8b2-4fa0-8655-c308b2b5e807" width="45%"></img> <img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/57f0c76f-ded4-488c-9a7f-ecc10ea8fb72" width="45%"></img>

This template provides a fantasy-themed menu and dialogic style. It can be used as a base or as inspiration for your projects.
The design is very much based on this [cool and free to use design](https://skolaztika.itch.io/fantasy-renpy-gui-template) by [Skolaztika](https://skolaztika.itch.io).

# Content
- [Features](#features)
- [Details](#details)
  - [Main Menu](#menu)
  - [Style](#style)


# Features
- Full main menu
- Overlay menu with:
  - Pause menu
  - Save
  - Load
  - History
  - Options
  - About
  - Help
- Warnings when trying to exit with unsaved progress

- Custom Dialogic Style Layers for:
  - Textbox (with buttons for History, Skip, Auto, Save, Q.Save, Q.Load, Options)
  - Hover Glossary
  - Choices
  - Text Input

# Details
If you want to make a game from scratch you can use this project as a base, remove the "TestStuff" folder and just start from there. 
More realisticly though, you've probably already setup a portrait and would like to incorporate some or all of this template into that. Whatever the case, I'll try to explain some things here, as it's always hard to work with someone elses code and implementation.

# Menu
Most of the menu GUI is one big scene at `res://DialogicFantasyMenu/main_menu.tscn`. This scene should be setup as your projects main scene.
This scene has two parts, the Main Menu inside the `MainMenu` canvas layer and the `GUILayer` with the overlay and warnings, which will appear *over* the game.
-> [More on canvas layers here](https://docs.godotengine.org/en/stable/tutorials/2d/canvas_layers.html)

![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/b7c1921e-e8cd-4539-904b-a4e0940f7653)

## Main Menu
The **main menu script** handles all the functionality of the main menu buttons and their hover effects (sound and growing).
Most importantly you might want to change the name of the timeline that is started when a new game begins. This is an exported property of the main menu script, that can be set in the inspector.

![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/59f7caf4-8e97-4992-bbb5-0be380f825e6)

This script also importantly connects to the `Dialogic.signal_event` and if that event is used with the parameter `"GAME_END"`, the menu will consider the end of the game reached (and thus show the menu again). This is used instead of `Dialogic.timeline_ended`, so that you can implement moments where dialogic isn't active (e.g. minigames), and still communicate to the menu when the game actually ends.

The Load, Options, About and Help buttons simply open the overlay.

Besides the buttons the main menu contains some visible elements (the title in three parts, the image behind the buttons and a background) most of which use the `MouseParalaxEffect` script at `res://DialogicFantasyMenu/Helpers/MouseParalaxEffect.gd`, though with different `paralax_strength` set in the inspector. It should be simple to change the title, add other visual elements to it and remove or reuse the paralax mouse effect script if you want.

### Interesting main menu things:
- The Quit button is hidden on the web to avoid seemingly crashing the game
```gdscript
## Don't show the Quit button on the web
%Quit.visible = !OS.has_feature("web")
```
- The Continue button is only visible when something has been saved before
```gdscript
## When there is a save to continue from, show the Continue button
%Continue.visible = not Dialogic.Save.get_latest_slot().is_empty()
```
*Note that there is some additional logic to focus and highlight the continue button instead of start new, IF continue is visible.*
- When the game ends (with even_signal("GAME_END")) the latest slot is reset, to avoid further showing the Continue button
```gdscript
## Assuming that the end of the game was reached,
## We don't want to keep suggestion to "Continue" from the last save.
Dialogic.Save.set_latest_slot("")
```

## Overlay menu
The overlay menu part resembles a book and can be opened both during the menu and during gameplay (with escape or one of the buttons of the style).

It has a number of tabs and custom buttons that open these tabs. You will find the buttons at `GUILayer/OverlayUI/TabButtons` (in case you need to change a tabs name) and the actual tabs at `GUILayer/OverlayUI/Tabs`.

![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/ef813f02-ca2e-433a-bfed-1a7ec7095620)

The `OverlayUI` script mostly handles opening and closing the "book". This includes:
- Pausing the tree when entering (unpausing when exiting). The GUI_Layer nodes process mode is set to "Always".
- A small size and transparancy tween when opening and closing
- Handling ESC input (open/close) and clicking outside the book (closing)
- Disabeling the Pause and Save tabs when opening the book from the main menu
- Some helper methods to open a specific tab

#### Pause tab
The pause tab is realy simple. It's the thing that will be shown when you press ESC during the gameplay. 
The most interesting thing is the interaction with the WarningDialog node. When you try to quit or go to the main menu, the pause menu will check whether there might be unsaved progress and if so, displays a "do you really want to" dialog. 
```gdscript
## Calls [method go_to_main_menu] or presents a warning, if there is unsaved progress.
func _on_main_menu_pressed() -> void:
	if not %OverlayUI.has_just_saved:
		%WarningDialog.warn("Careful, unsaved progress will be lost!",
			[
				{"text":"Main Menu", "action":go_to_main_menu}
			])
	else:
		go_to_main_menu()
```
*Note that the `%Overlay.has_just_saved` value is always set to false when opening the overlay and only set to true when saving.*
As in the main menu, `Quit` is hidden on the web.

#### Save and Load tabs 
The save and load tabs both have a very similar UI, so they reuse the same scene `res://DialogicFantasyMenu/SaveLoadInterface/save_load_interface.tscn` (just with a property changed to indicate the different behaviour).

Most importantly this template provides 60 slots. Internally these are named slot_0 to slot_59. When trying to display them, it just checks if that slot exists and otherwise just displays an empty slot.
```gdscript
## Loads the slots on that page
func load_page(new_page_index := page_index) -> void:
	page_index = new_page_index

	for i in $Slots.get_children():
		i.clear()
		var slot_name := get_slot_name(i.get_index())
		if Dialogic.Save.has_slot(slot_name):
			i.load_info(slot_name)
```

It will also store the slot page when switching.

The date+time string used on the slots can be changed in the inspector.


#### History tab
The history tab is rather simple. Most notably:
- it connects itself to the `Dialogic.History.open_requested` signal
- when opened it clears the history-item list and repopulates it with instances of the HistoryItem scene.

Most about how the history is displayed is thus defined by the `history_message.gd` script at `res://DialogicFantasyMenu/OverlayTabs/history_message.gd` and it's scene at `res://DialogicFantasyMenu/OverlayTabs/history_message.tscn`.
This history message allows displaying text events, character join and leave events and choices.

#### Options tab
One of the more interesting tabs! 
The options tab allows changing these game settings:
- Display (Windowed/Fullscreen)
- Text Speed
- Auto-Forward Speed
- Skipping (Stop skipping on unread text / Autostart skipping on seen text)
- Music, Sound Effects, UI Sounds Volume

All of these are common settings and have their quirks in how to get them to work, so I will try to mention everything here that's interesting or important for them to work in your game.

Generally all the settings values are stored using dialogic so that they are remmebered when reopening the game. For most settings that is done like this:
```gdscript
Dialogic.Save.set_global_info("auto_advance_modifier", value)
```
They are then loaded on ready (as an example) like this:
```gdscript
Dialogic.Inputs.auto_advance.delay_modifier = Dialogic.Save.get_global_info("auto_advance_modifier", 1)
```

**Display Setting**
The display setting switches the window mode between window and full-screen:
```gdscript
func _on_setting_display_item_selected(index: int) -> void:
	match index:
		0:
			get_viewport().get_window().mode = Window.MODE_WINDOWED
		1:
			get_viewport().get_window().mode = Window.MODE_FULLSCREEN
```

**Text Speed setting**
The text speed setting is a (multiplier) for text related things (like letter speed, pauses, etc.). That means at 0 the text will be instant, at 1 use the default and at higher values go slower. 
The text speed setting is part of the Settings subsystem and is thus automatically saved and loaded.
As a small trick I've made it so that the value of the slider is actually self-multiplied, making for a wider range of values (while still having the default at the middle):
```gdscript
func _on_setting_text_speed_value_changed(value: float) -> void:
	## We interpret the speed slider as exponential,
	## to fit a wider range of slow and fast speeds
	Dialogic.Settings.text_speed = value * value
```
Then of course we need to invert this trick when loading the value into the UI on ready:
```gdscript
%Setting_TextSpeed.value = sqrt(Dialogic.Settings.get_setting("text_speed", 1))
```

**Autoadvance Speed setting**
The autoadvance delay modifier is part of the autoadvance class on the Input subsystem. It's also a multiplier. I suggest to play around with the autoadvance delay values in the dialogic settings to find a good default. It's still nice to allow the players to modify the speed. The implementation is very simple:

```gdscript
func _on_setting_auto_speed_value_changed(value: float) -> void:
	Dialogic.Inputs.auto_advance.delay_modifier = value
	Dialogic.Save.set_global_info("auto_advance_modifier", value)
```

**Auto-Skip settings**
These are simply settings on the autoskip class on the Input subsystem. For these to work you will have to enable the "Seen events history" in the Dialogic settings > History section!
```gdscript
func _on_setting_skip_unseen_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.disable_on_unread_text = toggled_on
	Dialogic.Save.set_global_info("skip_unseen_text", toggled_on)


func _on_setting_skip_seen_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.enable_on_visited = toggled_on
	Dialogic.Save.set_global_info("skip_auto_seen_text", toggled_on)
```

**Audio settings**
Three separate audio-sliders allow adjusting the volume of the music, sound effects and UI sound effects (such as type-sounds and button hover sounds). If you read through this, you should be able to create a separate slider for voice audio if you need it.
The audio settings require a bit more setup to work:
- We need an audio bus for every type of sound: SFX, UI_SFX, Music. [More about audio buses here](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html). In this template they are setup to be sub-busses of the Master bus. This could allow you to control the master volume on a separate slider, though I chose not to.
![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/3a103f10-1b50-42cc-859a-476ecf518e3c)

- We need to make sure dialogic uses these busses. Because of this we run this in _ready:
```gdscript
Dialogic.Audio.base_music_player.bus = "Music"
Dialogic.Audio.base_music_player.process_mode = Node.PROCESS_MODE_ALWAYS

Dialogic.Audio.base_sound_player.bus = "SFX"
```
*Note that I wanted background music to keep playing when opening the in-game menu overlay, so I set the `process_mode` to `ALWAYS`.*
Also we will need to make sure that the TypeSound node has it's bus set to UI_SFX. In this template no type-sounds are setup though you might want to add them, or a character might have custom type sounds.

If all is setup we can set the volume like this:
```gdscript
AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
```
*Note that we use `linear_to_db()` because db is not equalized to our hearing perception. This way the slider feels like it has a linear influence.*

#### Help tab
The help tab has no functionality at all, simply a bunch of labels displaying some common inputs.

#### About tab
The about tab has little content, but could be used to display more info about YOU or your game. Both RichTextLabels support links (like this: `[url="https://www.google.com"]Go to google![/url]`), as they are connected to a method that handles them.

---
# Style
The style (saved at `res://DialogicFantasyStyle/fantasy_style.tres`) is made up of these layers:
- Background (default)
- 5 Portraits (default)
- Input Catcher (default)
- Fantasy Textbox
- Fantasy Choices
- Fantasy Glossary
- Fantasy Text Input

## Fantasy textbox
This textbox provides a lot of functionality besides displaying text.

### The buttons
The buttons provide useful functionality. They are rather simple to implement.
**History**
```gdscript
func _on_history_pressed() -> void:
	# Take a thumbnail.
	# This is a special case, because it's possible to navigate from the history to the save page directly.
	Dialogic.Save.take_thumbnail()

	Dialogic.History.open_history()
```
*Remember how the history tab on the book overlay connected to the `Dialogic.History.open_requested` signal [here](#history-tab)? This is where we activate that!*

**Skip & Auto**
It's simple to enable autoskip and autoadvance. Having skip and autoadvance on at the same time is not something we want, so we always toggle the other off.
```gdscript
func _on_skip_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.enabled = toggled_on
	Dialogic.Inputs.auto_advance.enabled_until_user_input = false
```
Skip and autoadvance might activate/deactivate without the button being pressed (by a short-cut key, the other being enabled or the skip settings from earlier). #
In order to have the button always show when they are on, we connect to the `Dialogic.Inputs.auto_skip.toggled` or `Dialogic.Inputs.auto_advance.toggled` signals:
```gdscript
## Dialogic informs us that the autoskip state has changed
func _on_auto_skip_toggled(toggled_on: bool) -> void:
	%Skip.set_pressed_no_signal(toggled_on)
```

**Save & Options**
These two simply open the overlay UI on their respecive tab. Before doing so, they take a screenshot for the save (we don't want the screenshot showing the overlay UI).
```
func _on_save_pressed() -> void:
	if overlay_ui:
		Dialogic.Save.take_thumbnail()
		overlay_ui.open_save_menu()
```

**Q.Save and Q.Load**
These two buttons simple save and load from/to the latest used slot.
```gdscript
func _on_q_save_pressed() -> void:
	Dialogic.Save.save(Dialogic.Save.get_latest_slot())
	Dialogic.Save.set_slot_info(Dialogic.Save.get_latest_slot(),
		{
			"name" : Dialogic.Save.get_latest_slot().capitalize(),
			"date" : Time.get_datetime_dict_from_system()
		})


func _on_q_load_pressed() -> void:
	Dialogic.Save.load(Dialogic.Save.get_latest_slot())
```
For this to work properly, the default slot should be set to `slot_0` in the Dialogic settings > Saving section.

### Other details
The textbox layer script also listens for the input action `skip_dialog` which you might have to setup in your project (it's configured in this template to CTRL):
```gdscript
func _input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("skip_dialog"):
		Dialogic.Inputs.auto_skip.enabled = true
	elif Input.is_action_just_released("skip_dialog"):
		Dialogic.Inputs.auto_skip.enabled = false
```

A texture progress bar node is setup with the autoadvance indicator node script. This way there is a visual indicator how long the autoadvance takes.

Many nodes on the textbox layer use the ParalaxMouseEffect, though only very subtle.

## Choice layer
The choice layer is really simple. The only interesting things are that
- it uses the ParalaxMouseEffect
- it adds some hover animation to the buttons

## Glossary layer & Text input layer
Nothing to be said here. They are really as simple as it gets.

# The end
I hope that is all. I hope this is helpful to anyone.
