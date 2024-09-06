local CreateFrame, Settings, C_Timer = CreateFrame, Settings, C_Timer

local bigYeetDefaultConfig = {
	isMuted = false,
	soundChannel = 1,
}

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

	self.panel = panel
	self.rows = {
		{
			frame = titleRow,
			label = titleFrame,
			value = {},
			button = {},
		},
	}

	return o
end

function SettingsPanel:createNewOptionRowWithLabel(label)
	local optionRow = CreateFrame("Frame", nil, self.panel)
	optionRow:SetSize(self.config.panelWidth, self.config.optionRowHeight)
	optionRow:SetPoint("TOPLEFT", self.rows[#self.rows].frame, "BOTTOMLEFT", 0, 0)

	local labelFrame = optionRow:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	labelFrame:SetPoint("LEFT", optionRow, "LEFT", self.config.labelOffset, 0)
	labelFrame:SetNonSpaceWrap(true)
	labelFrame:SetText(label)

	table.insert(self.rows, {
		frame = optionRow,
		label = label,
		value = {},
		value2 = {},
	})

	return optionRow
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

local function createSettingsFrame()
	local settingsPanel = SettingsPanel:new(nil, "BigYeet")
	settingsPanel:createNewOptionRowWithLabel("Soundchannel")
	settingsPanel:addDropdownToLastRow(1, function(index)
		return BigYeetConfig.soundChannel == index
	end, function(index)
		BigYeetConfig.soundChannel = index
	end, BigYeet.soundChannels)

	settingsPanel:createNewOptionRowWithLabel("Muted")
	settingsPanel:addCheckboxToLastRow(1, function(self, _, _)
		BigYeetConfig.isMuted = self:GetChecked()

		if BigYeetConfig.isMuted then
			StopSong()
		end
	end, BigYeetConfig.isMuted)

	settingsPanel:createNewOptionRowWithLabel("Test Song for 5 seconds")
	settingsPanel:addButtonToLastRow(1, "Start Song", function()
		PlaySong(1)
		C_Timer.After(5, StopSong)
	end)
	settingsPanel:addButtonToLastRow(2, "Stop Song", function()
		PlaySong(1)
		C_Timer.After(5, StopSong)
	end)

	-- local newSongInputBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	-- newSongInputBox:SetPoint("TOPLEFT", testSongButton, 0, -40)
	-- newSongInputBox:SetSize(200, 30)
	-- newSongInputBox:SetAutoFocus(false)

	-- local newSongSaveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	-- newSongSaveButton:SetPoint("LEFT", newSongInputBox, "RIGHT", 40, 0)
	-- newSongSaveButton:SetText("Add new song")
	-- newSongSaveButton:SetWidth(100)
	-- newSongSaveButton:SetScript("OnClick", function()
	-- 	print("clicked!!!")
	-- end)
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

	createSettingsFrame()

	print("BigYeet: Addon Loaded")
end

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", loadConfig)
