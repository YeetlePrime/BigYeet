local StopSound, C_Sound, PlaySoundFile, CreateFrame, CombatLogGetCurrentEventInfo =
	StopSound, C_Sound, PlaySoundFile, CreateFrame, CombatLogGetCurrentEventInfo

function StopSong()
	BigYeet.currentSpellId = nil
	StopSound(BigYeet.soundHandle)
end

function PlaySong(auraId)
	if BigYeetConfig.isMuted then
		StopSong()
		return
	elseif C_Sound.IsPlaying(BigYeet.soundHandle) then
		return
	end

	local success
	success, BigYeet.soundHandle =
		PlaySoundFile(BigYeetConfig.selectedSong, BigYeet.soundChannels[BigYeetConfig.soundChannel].identifier)

	if success then
		BigYeet.currentSpellId = auraId
	else
		StopSong()
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(_, _)
	local _, subevent, _, _, _, _, _, destinationGUID, _, _, _, auraId = CombatLogGetCurrentEventInfo()
	if destinationGUID ~= BigYeet.playerGUID then
		return
	end

	if subevent == "SPELL_AURA_APPLIED" and BigYeet.isBloodLustAuraId(auraId) then
		PlaySong(auraId)
	end

	if subevent == "SPELL_AURA_REMOVED" and auraId == BigYeet.currentSpellId then
		StopSong()
	end
end)
