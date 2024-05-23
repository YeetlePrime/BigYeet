local defaultBigYeetConfig = {
    isMuted = false,
    soundChannel = 1,
}

local bigYeet = {
    playerGUID = UnitGUID('player'),
    filepath = 'interface\\addons\\bigyeet\\sounds\\',
    isCurrentlyPlaying = false,
    currentSpellId = 0,
    soundHandle = 0,
    auraIds = {80353, 32182, 2825, 264667, 146555, 178207, 256740, 230935, 309658, 350249, 368245, 390386, 381301, 386540, 441076},
    soundChannels = {
        {
            identifier = 'master',
            name = 'Master',
            volume = 'Sound_MasterVolume',
            enable = 'Sound_EnableAllSound'
        },
        {
            identifier = 'sfx',
            name = 'SFX',
            volume = 'Sound_SFXVolume',
            enable = 'Sound_EnableSFX'
        },
        {
            identifier = 'music',
            name = 'Music',
            volume = 'Sound_MusicVolume',
            enable = 'Sound_EnableMusic'
        },
        {
            identifier = 'ambience',
            name = 'Ambience',
            volume = 'Sound_AmbienceVolume',
            enable = 'Sound_EnableAmbience'
        },
        {
            identifier = 'dialog',
            name = 'Dialog',
            volume = 'Sound_DialogVolume',
            enable = 'Sound_EnableDialog'
        },
    }
}

function StopSong()
    bigYeet.isCurrentlyPlaying = false
    bigYeet.currentSpellId = 0
    StopSound(bigYeet.soundHandle)
    print('The song was stopped')
end

function PlaySong(auraId)
    local songFilePath = bigYeet.filepath .. 'PedroTrimmed.ogg' 

    if BigYeetConfig.isMuted then
        print('I am muted.')
        StopSong()
        return
    elseif bigYeet.isCurrentlyPlaying then
        print('Already playing a song')
        return
    end

    bigYeet.isCurrentlyPlaying, bigYeet.soundHandle = PlaySoundFile(songFilePath, bigYeet.soundChannels[BigYeetConfig.soundChannel].identifier)

    if bigYeet.isCurrentlyPlaying then
        bigYeet.currentSpellId = auraId
        print('Now playing a song')
    else
        StopSong()
    end
end

local function isBloodLustAuraId(auraId) 
    for _, id in ipairs(bigYeet.auraIds) do
        if id == auraId then
            return true
        end
    end

    return false
end

local loadFrame = CreateFrame('Frame')
loadFrame:RegisterEvent('ADDON_LOADED')
loadFrame:SetScript('OnEvent',
    function (self, event, addonName)
        if addonName ~= 'BigYeet' then
            return
        end

        BigYeetConfig = (BigYeetConfig and type(BigYeetConfig) == 'table') and BigYeetConfig or {}
        BigYeetConfig.isMuted = BigYeetConfig.isMuted and BigYeetConfig.isMuted or false
        BigYeetConfig.soundChannel = BigYeetConfig.soundChannel and BigYeetConfig.soundChannel or 1

        print('BigYeet: Addon Loaded')
    end
)

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
eventFrame:SetScript("OnEvent", 
    function (self, event)
        local _, subevent, _, _, _, _, _, destinationGUID, _, _, _, auraId = CombatLogGetCurrentEventInfo()
        if destinationGUID ~= bigYeet.playerGUID then
            return
        end

        if subevent == 'SPELL_AURA_APPLIED' and isBloodLustAuraId(auraId) then
            PlaySong(auraId)
        end

        if subevent == 'SPELL_AURA_REMOVED' and auraId == bigYeet.currentSpellId then
            StopSong()
        end
    end
)