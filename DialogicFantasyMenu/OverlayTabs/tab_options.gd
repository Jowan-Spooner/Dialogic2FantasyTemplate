extends OverlayUI_Tab

## A tab that allows changing useful settings.


## The default music volume (linear, not db)
@export var default_music_volume := 0.8
## The default sound effects volume (linear, not db)
@export var default_sound_effects_volume := 0.8
## The default ui sounds volume (linear, not db)
@export var default_ui_sounds_volume := 0.5


func _ready() -> void:
	## Assign the correct default audio buses
	Dialogic.Audio.base_music_player.bus = "Music"
	Dialogic.Audio.base_music_player.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.Audio.base_sound_player.bus = "SFX"

	## Set the volume from the audio settings
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI_SFX"),
		linear_to_db(Dialogic.Save.get_global_info("ui_sounds_volume", default_ui_sounds_volume)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
		linear_to_db(Dialogic.Save.get_global_info("music_volume", default_music_volume)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
		linear_to_db(Dialogic.Save.get_global_info("sound_effects_volume", default_sound_effects_volume)))


	## Set the input settings
	Dialogic.Inputs.auto_skip.disable_on_unread_text = Dialogic.Save.get_global_info("skip_unseen_text", false)
	Dialogic.Inputs.auto_skip.enable_on_visited = Dialogic.Save.get_global_info("skip_auto_seen_text", false)

	super()


## Loads the settings values into the settings controls
func _open() -> void:
	## Display Setting
	%Setting_Display.select(0)
	if get_viewport().get_window().mode == Window.MODE_FULLSCREEN:
		%Setting_Display.select(1)

	## We interpret the speed slider as exponential,
	## to fit a wider range of slow and fast speeds
	%Setting_TextSpeed.value = sqrt(Dialogic.Settings.get_setting("text_speed", 1))

	%Setting_AutoSpeed.value = Dialogic.Save.get_global_info("auto_advance_modifier", 1)

	## Audio Volume Settings
	%Setting_MusicVolume.value = Dialogic.Save.get_global_info("music_volume", default_music_volume)
	%Setting_SoundsVolume.value = Dialogic.Save.get_global_info("sound_effects_volume", default_sound_effects_volume)
	%Setting_UIVolume.value = Dialogic.Save.get_global_info("ui_sounds_volume", default_ui_sounds_volume)

	## Input Settings
	%Setting_SkipUnseen.button_pressed = Dialogic.Save.get_global_info("skip_unseen_text", false)
	%Setting_SkipSeen.button_pressed = Dialogic.Save.get_global_info("skip_auto_seen_text", false)


#region SETTINGS CHANGED SIGNALS
################################################################################

## Display Setting
func _on_setting_display_item_selected(index: int) -> void:
	match index:
		0:
			get_viewport().get_window().mode = Window.MODE_WINDOWED
		1:
			get_viewport().get_window().mode = Window.MODE_FULLSCREEN


## Text Speed Setting
func _on_setting_text_speed_value_changed(value: float) -> void:
	## We interpret the speed slider as exponential,
	## to fit a wider range of slow and fast speeds
	Dialogic.Settings.text_speed = value * value


## Auto Advance Speed Setting
func _on_setting_auto_speed_value_changed(value: float) -> void:
	Dialogic.Inputs.auto_advance.delay_modifier = value
	Dialogic.Save.set_global_info("auto_advance_modifier", value)


## Audio Volumes
## Music
func _on_setting_music_volume_value_changed(value: float) -> void:
	Dialogic.Save.set_global_info("music_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

## Sound Effects
func _on_setting_sounds_volume_value_changed(value: float) -> void:
	Dialogic.Save.set_global_info("sound_effects_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

## UI Sounds
func _on_setting_ui_volume_value_changed(value: float) -> void:
	Dialogic.Save.set_global_info("ui_sounds_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI_SFX"), linear_to_db(value))


## Input Settings
func _on_setting_skip_unseen_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.disable_on_unread_text = toggled_on
	Dialogic.Save.set_global_info("skip_unseen_text", toggled_on)


func _on_setting_skip_seen_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.enable_on_visited = toggled_on
	Dialogic.Save.set_global_info("skip_auto_seen_text", toggled_on)

#endregion
