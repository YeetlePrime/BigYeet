local UnitGUID = UnitGUID

BigYeet = {
	playerGUID = UnitGUID("player"),
	soundFile = "interface/addons/bigyeet/sounds/PedroTrimmed.ogg",
	currentSpellId = nil,
	soundHandle = 0,
	auraIds = {
		80353,
		32182,
		2825,
		264667,
		146555,
		178207,
		256740,
		230935,
		309658,
		350249,
		368245,
		390386,
		381301,
		386540,
		441076,
	},
	soundChannels = {
		{
			identifier = "master",
			name = "Master",
			volume = "Sound_MasterVolume",
			enable = "Sound_EnableAllSound",
		},
		{
			identifier = "sfx",
			name = "SFX",
			volume = "Sound_SFXVolume",
			enable = "Sound_EnableSFX",
		},
		{
			identifier = "music",
			name = "Music",
			volume = "Sound_MusicVolume",
			enable = "Sound_EnableMusic",
		},
		{
			identifier = "ambience",
			name = "Ambience",
			volume = "Sound_AmbienceVolume",
			enable = "Sound_EnableAmbience",
		},
		{
			identifier = "dialog",
			name = "Dialog",
			volume = "Sound_DialogVolume",
			enable = "Sound_EnableDialog",
		},
	},
}