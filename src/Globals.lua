local UnitGUID = UnitGUID

BigYeet = {
	songsToPlay = {},
	availableSongs = {},
	playerGUID = UnitGUID("player"),
	customSongBasePath = "Interface\\AddOns\\BigYeet\\customsounds\\",
	currentSpellId = nil,
	soundHandle = 0,
	auraIds = {
		386540, -- temporal warp
		368245, -- resonant bloodlust
		-- classes
		80353, -- time warp (mage)
		350249, -- time warp (mage)
		32182, -- heroism (alliance shaman)
		2825, -- bloodlust (horde shaman)
		264667, -- primal rage (hunter)
		390386, -- fury of the aspects (evoker)
		-- drums
		146555, -- drums of rage
		178207, -- drums of fury
		441076, -- timeless drums
		230935, -- drums of the mountain (legion)
		256740, -- drums of the maelstrom (battle for azeroth)
		309658, -- drums of deathly ferocity (shadowlands)
		381301, -- feral hide drums (dragonflight)
		444257, -- thunderous drums (the war within)
	},
	isBloodLustAuraId = function(auraId)
		for _, id in ipairs(BigYeet.auraIds) do
			if id == auraId then
				return true
			end
		end

		return false
	end,
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
