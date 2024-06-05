# Dialogic Fantasy Template
<img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/94a939e3-5253-4b75-bc78-eae3ccc1c094" width="45%"></img><img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/5ea8707f-7b7c-4a8b-89fb-5c7b595b31aa" width="45%"></img>
![grafik]()
<img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/158c7d24-a8b2-4fa0-8655-c308b2b5e807" width="45%"></img> <img src="https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/57f0c76f-ded4-488c-9a7f-ecc10ea8fb72" width="45%"></img>

This template provides a fantasy-themed menu and dialogic style. It can be used as a base or as inspiration for your projects.
The design is very much based on this [cool and free to use design](https://skolaztika.itch.io/fantasy-renpy-gui-template) by [Skolaztika](https://skolaztika.itch.io).

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
  - Textbox
  - Glossary
  - Choices
  - Text Input


There is a lot of functionality/polish throughout. Some notable effects used:
- Mouse Paralax (subtle UI-movement when moving the mouse)
- Button sounds with increasing pitch (try out moving the mouse over the buttons, it's a cool effect)
- Button tweening (visibly reacting to hover) 

# Details
If you want to make a game from scratch you can use this project as a base, remove the "TestStuff" folder and just start from there. 
More realisticly though, you've probably already setup a portrait and would like to incorporate some or all of this template into that. Whatever the case, I'll try to explain some things here, as it's always hard to work with someone elses code and implementation.

## Menu
Most of the menu GUI is one big scene at `res://DialogicFantasyMenu/main_menu.tscn`. This scene should be setup as your projects main scene.
This scene has two parts, the Main Menu inside the `MainMenu` canvas layer and the `GUILayer` with the overlay and warnings, which will appear *over* the game.
-> [More on canvas layers here](https://docs.godotengine.org/en/stable/tutorials/2d/canvas_layers.html)

![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/b7c1921e-e8cd-4539-904b-a4e0940f7653)

### Main Menu
The **main menu script** handles all the functionality of the main menu buttons and their hover effects (sound and growing).
Most importantly you might want to change the name of the timeline that is started when a new game begins. This is an exported property of the main menu script, that can be set in the inspector.

![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/59f7caf4-8e97-4992-bbb5-0be380f825e6)

This script also importantly connects to the `Dialogic.signal_event` and if that event is used with the parameter `"GAME_END"`, the menu will consider the end of the game reached (and thus show the menu again). This is used instead of `Dialogic.timeline_ended`, so that you can implement moments where dialogic isn't active (e.g. minigames), and still communicate to the menu when the game actually ends.

The Load, Options, About and Help buttons simply open the overlay.

Besides the buttons the main menu contains some visible elements (the title in three parts, the image behind the buttons and a background) most of which use the `MouseParalaxEffect` script at `res://DialogicFantasyMenu/Helpers/MouseParalaxEffect.gd`, though with different `paralax_strength` set in the inspector. It should be simple to change the title, add other visual elements to it and remove or reuse the paralax mouse effect script if you want.

#### Interesting main menu things:
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

### Overlay menu
The overlay menu part resembles a book and can be opened both during the menu and during gameplay (with escape or one of the buttons of the style).

It has a number of tabs and custom buttons that open these tabs. You will find the buttons at `GUILayer/OverlayUI/TabButtons` (in case you need to change a tabs name) and the actual tabs at `GUILayer/OverlayUI/Tabs`.

![grafik](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate/assets/42868150/ef813f02-ca2e-433a-bfed-1a7ec7095620)

The `OverlayUI` script mostly handles opening and closing the "book". This includes:
- Pausing the tree when entering (unpausing when exiting). The GUI_Layer nodes process mode is set to "Always".
- A small size and transparancy tween when opening and closing
- Handling ESC input (open/close) and clicking outside the book (closing)
- Disabeling the Pause and Save tabs when opening the book from the main menu
- Some helper methods to open a specific tab

##### Pause tab
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

##### Save and Load tabs 
The save and load tabs both have a very similar UI, so they reuse the same scene `res://DialogicFantasyMenu/SaveLoadInterface/save_load_interface.tscn` (just with a property changed to indicate the different behaviour).

Most importantly this template provides 60 slots. Behind the scenes these are named slot_0 to slot_59. When trying to display them, it just checks if that slot exists and otherwise just displays an empty slot.
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
