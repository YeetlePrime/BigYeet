local UnitGUID, CreateFrame, Settings = UnitGUID, CreateFrame, Settings
local UIDropDownMenu_SetText, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, CloseDropDownMenus =
	UIDropDownMenu_SetText,
	UIDropDownMenu_Initialize,
	UIDropDownMenu_CreateInfo,
	UIDropDownMenu_AddButton,
	CloseDropDownMenus

local bigYeetDefaultConfig = {
	isMuted = false,
	soundChannel = 1,
}

BigYeet = {
	playerGUID = UnitGUID("player"),
	soundFile = "interface\\addons\\bigyeet\\sounds\\PedroTrimmed.ogg",
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

local function deepcopy(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
			end
			setmetatable(copy, deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local function createSettingsFrame()
	local panel = CreateFrame("Frame")
	panel.name = "BigYeet"
	local category, _ = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	category.ID = panel.name
	Settings.RegisterAddOnCategory(category)

	local mutedCheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	mutedCheckbox:SetPoint("TOPLEFT", 20, -20)
	mutedCheckbox.Text:SetText("Muted")
	mutedCheckbox:SetChecked(BigYeetConfig.isMuted)
	mutedCheckbox:SetScript("OnClick", function(_, _, _)
		BigYeetConfig.isMuted = mutedCheckbox:GetChecked()

		if BigYeetConfig.isMuted then
			StopSong()
		end
	end)

	local soundChannelDropdown = CreateFrame("Frame", "SoundChannelDropdown", panel, "UIDropDownMenuTemplate")
	soundChannelDropdown:SetPoint("TOPRIGHT", panel, 20, -20)
	soundChannelDropdown:SetWidth(200)
	UIDropDownMenu_SetText(soundChannelDropdown, BigYeet.soundChannels[BigYeetConfig.soundChannel].name)
	UIDropDownMenu_Initialize(soundChannelDropdown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		if (level or 1) == 1 then
			for index, soundChannel in ipairs(BigYeet.soundChannels) do
				info.text = soundChannel.name
				info.func = self.SetValue
				info.arg1, info.checked = index, index == BigYeetConfig.soundChannel
				UIDropDownMenu_AddButton(info)
			end
		end
	end)
	function soundChannelDropdown:SetValue(newValue)
		BigYeetConfig.soundChannel = newValue
		UIDropDownMenu_SetText(soundChannelDropdown, BigYeet.soundChannels[BigYeetConfig.soundChannel].name)
		CloseDropDownMenus()
	end

	local soundChannelDropdownLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	soundChannelDropdownLabel:SetPoint("RIGHT", soundChannelDropdown, "LEFT", 10, 0)
	soundChannelDropdownLabel:SetNonSpaceWrap(true)
	soundChannelDropdownLabel:SetText("Sound Channel:")

	local testSongButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	testSongButton:SetPoint("TOPLEFT", mutedCheckbox, 0, -40)
	testSongButton:SetText("Start Song")
	testSongButton:SetWidth(100)
	testSongButton:SetScript("OnClick", function()
		PlaySong(1)
	end)

	local stopSongButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	stopSongButton:SetPoint("TOPLEFT", testSongButton, 120, 0)
	stopSongButton:SetText("Stop Song")
	stopSongButton:SetWidth(100)
	stopSongButton:SetScript("OnClick", function()
		StopSong()
	end)
end

local function loadConfig(self, event, addonName)
	if addonName ~= "BigYeet" then
		return
	end

	if type(BigYeetConfig) == "table" then
		local config = deepcopy(bigYeetDefaultConfig)
		for defaultKey, defaultValue in pairs(config) do
			config[defaultKey] = BigYeetConfig[defaultKey] and BigYeetConfig[defaultKey] or defaultValue
		end

		BigYeetConfig = config
	else
		BigYeetConfig = deepcopy(bigYeetDefaultConfig)
	end

	createSettingsFrame()

	if SoundFileExists(BigYeet.soundFile) then
		print("EXISTS")
	else
		print("DOES NOT EXIST")
	end

	print("BigYeet: Addon Loaded")
end

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", loadConfig)
