local CreateFrame, Settings, C_Timer = CreateFrame, Settings, C_Timer

local bigYeetDefaultConfig = {
	isMuted = false,
	soundChannel = 1,
	songs = {},
	selectedSong = "interface\\addons\\bigyeet\\sounds\\pedro.ogg",
}
bigYeetDefaultConfig.songs["interface\\addons\\bigyeet\\sounds\\pedro.ogg"] = "Pedro"

local SettingsPanel = {
	panel = nil,
	rows = {},
	config = {
		panelWidth = 650,
		titleRowHeight = 50,
		optionRowHeight = 40,
		titleOffset = 5,
		labelOffset = 30,
		valueWidth = 200,
		valueOffset = 200,
	},
}

function SettingsPanel:new(o, title)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	local panel = CreateFrame("Frame")
	panel.name = "BigYeet"

	local category, _ = Settings.RegisterCanvasLayoutCategory(panel, "BigYeet")
	category.ID = panel.name
	Settings.RegisterAddOnCategory(category)

	local titleRow = CreateFrame("Frame", nil, panel)
	titleRow:SetSize(self.config.panelWidth, self.config.titleRowHeight)
	titleRow:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local titleFrame = titleRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	titleFrame:SetText(title)
	titleFrame:SetPoint("LEFT", titleRow, "LEFT", self.config.titleOffset, 0)

	local row = {
		frame = titleRow,
		label = titleFrame,
		value = {},
		button = {},
	}

	self.panel = panel
	self.rows = {
		row,
	}

	return o
end

function SettingsPanel:createOptionRowWithLabel(label)
	local optionRow = CreateFrame("Frame", nil, self.panel)
	optionRow:SetSize(self.config.panelWidth, self.config.optionRowHeight)
	optionRow:SetPoint("TOPLEFT", self.rows[#self.rows].frame, "BOTTOMLEFT", 0, 0)

	local labelFrame = optionRow:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	labelFrame:SetPoint("LEFT", optionRow, "LEFT", self.config.labelOffset, 0)
	labelFrame:SetNonSpaceWrap(true)
	labelFrame:SetText(label)

	local row = {
		frame = optionRow,
		label = label,
		value = {},
		value2 = {},
	}

	table.insert(self.rows, row)

	return row
end

function SettingsPanel:createDescriptionRow(description)
	local descriptionFrame = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	descriptionFrame:SetPoint("TOPLEFT", self.rows[#self.rows].frame, "BOTTOMLEFT", 0, 0)
	descriptionFrame:SetWidth(self.config.panelWidth)
	descriptionFrame:SetText(description)

	local row = {
		frame = descriptionFrame,
	}

	table.insert(self.rows, row)

	return row
end

function SettingsPanel:addDropdownToLastRow(valuePosition, isSelectedFunction, setSelectedFunction, options)
	local lastRow = self.rows[#self.rows]

	local dropdown = CreateFrame("DropdownButton", nil, lastRow.frame, "WoWStyle1DropdownTemplate")
	dropdown:SetWidth(self.config.valueWidth)
	dropdown:SetupMenu(function(_, rootDescription)
		for index, soundChannel in ipairs(options) do
			rootDescription:CreateCheckbox(soundChannel.name, isSelectedFunction, setSelectedFunction, index)
		end
	end)

	if valuePosition == 1 then
		dropdown:SetPoint("LEFT", lastRow.frame, "LEFT", self.config.valueOffset, 0)
		lastRow.value = dropdown
	else
		dropdown:SetPoint("RIGHT", lastRow.frame, "RIGHT", 0, 0)
		lastRow.value2 = dropdown
	end

	return dropdown
end

function SettingsPanel:addCheckboxToLastRow(valuePosition, onClickFunction, checked)
	local lastRow = self.rows[#self.rows]

	local checkbox = CreateFrame("CheckButton", nil, lastRow.frame, "InterfaceOptionsCheckButtonTemplate")
	checkbox:SetChecked(checked)
	checkbox:SetScript("OnClick", onClickFunction)

	if valuePosition == 1 then
		checkbox:SetPoint("LEFT", lastRow.frame, "LEFT", self.config.valueOffset, 0)
		lastRow.value = checkbox
	else
		checkbox:SetPoint("RIGHT", lastRow.frame, "RIGHT", 0, 0)
		lastRow.value2 = checkbox
	end

	return checkbox
end

function SettingsPanel:addButtonToLastRow(valuePosition, text, onClickFunction)
	local lastRow = self.rows[#self.rows]

	local button = CreateFrame("Button", nil, lastRow.frame, "UIPanelButtonTemplate")
	button:SetText(text)
	button:SetWidth(self.config.valueWidth)
	button:SetScript("OnClick", onClickFunction)

	if valuePosition == 1 then
		button:SetPoint("LEFT", lastRow.frame, "LEFT", self.config.valueOffset, 0)
		lastRow.value = button
	else
		button:SetPoint("RIGHT", lastRow.frame, "RIGHT", 0, 0)
		lastRow.value2 = button
	end

	return button
end

function SettingsPanel:addSongSelectionToLastRow()
	local lastRow = self.rows[#self.rows]

	local function isSelectedSong(songPath)
		return BigYeetConfig.selectedSong == songPath
	end

	local function setSelectedSong(songPath)
		BigYeetConfig.selectedSong = songPath
	end

	local checkboxPool = {}
	local dropdown = CreateFrame("DropdownButton", nil, lastRow.frame, "WoWStyle1DropdownTemplate")
	dropdown:SetWidth(self.config.valueWidth)
	local function populateDropdown()
		checkboxPool = {}
		dropdown:SetupMenu(function(_, rootDescription)
			for path, name in pairs(BigYeetConfig.songs) do
				local checkbox = rootDescription:CreateCheckbox(name, isSelectedSong, setSelectedSong, path)

				table.insert(checkboxPool, checkbox)
			end
		end)
	end
	populateDropdown()

	dropdown:SetPoint("LEFT", lastRow.frame, "LEFT", self.config.valueOffset, 0)
	lastRow.checkboxPool = checkboxPool
	lastRow.value = dropdown
	lastRow.reload = populateDropdown

	return dropdown
end

function SettingsPanel:addInputBoxToLastRow(buttonText, onClickFunction)
	local lastRow = self.rows[#self.rows]

	local inputBox = CreateFrame("EditBox", nil, lastRow.frame, "InputBoxTemplate")
	inputBox:SetPoint("LEFT", lastRow.frame, "LEFT", self.config.valueOffset, 0)
	inputBox:SetSize(self.config.valueWidth, 30)
	inputBox:SetAutoFocus(false)

	local button = CreateFrame("Button", nil, lastRow.frame, "UIPanelButtonTemplate")
	button:SetPoint("RIGHT", lastRow.frame, "RIGHT", 0, 0)
	button:SetText(buttonText)
	button:SetWidth(self.config.valueWidth)

	local function onClickWrapper()
		onClickFunction(inputBox:GetText())
	end
	button:SetScript("OnClick", onClickWrapper)

	lastRow.value = inputBox
	lastRow.button = button

	return inputBox
end

local function createSettingsFrame()
	-- create panel
	local settingsPanel = SettingsPanel:new(nil, "BigYeet")

	-- create soundchannel dropdown
	settingsPanel:createOptionRowWithLabel("Soundchannel")
	settingsPanel:addDropdownToLastRow(1, function(index)
		return BigYeetConfig.soundChannel == index
	end, function(index)
		BigYeetConfig.soundChannel = index
	end, BigYeet.soundChannels)

	-- create mute checkbox
	settingsPanel:createOptionRowWithLabel("Muted")
	settingsPanel:addCheckboxToLastRow(1, function(self, _, _)
		BigYeetConfig.isMuted = self:GetChecked()

		if BigYeetConfig.isMuted then
			StopSong()
		end
	end, BigYeetConfig.isMuted)

	-- create test buttons
	settingsPanel:createOptionRowWithLabel("Test Song")
	settingsPanel:addButtonToLastRow(1, "Start Song", function()
		PlaySong(1)
	end)
	settingsPanel:addButtonToLastRow(2, "Stop Song", StopSong)

	-- create song selection
	local songSelectionRow = settingsPanel:createOptionRowWithLabel("Selected Song")
	settingsPanel:addSongSelectionToLastRow()

	-- create song creation
	settingsPanel:createOptionRowWithLabel("Add new song")
	settingsPanel:addInputBoxToLastRow("Add song", function(text)
		local path = string.lower(BigYeet.customSongBasePath .. text)
		local name = text

		if SoundFileExists(path .. ".ogg") then
			path = path .. ".ogg"
		elseif SoundFileExists(path .. ".mp3") then
			path = path .. ".mp3"
		else
			print(
				'BigYeet Error: No soundfile ""'
					.. name
					.. '" exists in ".'
					.. BigYeet.customSongBasePath
					.. '".\nSupported formats are .ogg and .mp3!'
			)
			return
		end

		BigYeetConfig.songs[path] = name
		songSelectionRow.reload()
	end)

	-- create description
	settingsPanel:createDescriptionRow(
		'You can add a custom song to this addon. To do that, you have to add a soundfile (.ogg or .mp3 format) to "World of Warcraft\\__retail__\\'
			.. BigYeet.customSongBasePath
			.. '".After that you have to close WoW, so that the new file can be detected on next startup.Now you can type the name of the new file (without path or fileformat) in the input field and press the button to add the song to your selection.'
	)
end

local function removeInvalidSongs()
	for path, _ in pairs(BigYeetConfig.songs) do
		if not SoundFileExists(path) then
			BigYeetConfig.songs[path] = nil
			if string.lower(path) == string.lower(BigYeetConfig.selectedSong) then
				BigYeetConfig.selectedSong = nil
			end
		end
	end

	if BigYeetConfig.selectedSong == nil then
		for path, _ in pairs(BigYeetConfig.songs) do
			BigYeetConfig.selectedSong = path
			break
		end
	end
end

local function loadConfig(_, _, addonName)
	if addonName ~= "BigYeet" then
		return
	end

	if type(BigYeetConfig) == "table" then
		local config = Deepcopy(bigYeetDefaultConfig)
		for defaultKey, defaultValue in pairs(config) do
			config[defaultKey] = BigYeetConfig[defaultKey] and BigYeetConfig[defaultKey] or defaultValue
		end

		BigYeetConfig = config
	else
		BigYeetConfig = Deepcopy(bigYeetDefaultConfig)
	end

	removeInvalidSongs()
	createSettingsFrame()

	print("BigYeet: Addon Loaded")
end

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", loadConfig)
