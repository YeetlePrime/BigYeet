local GetCVar, SetCVar, PlaySoundFile, StopSound = GetCVar, SetCVar, PlaySoundFile, StopSound

function SoundFileExists(path)
	local enableAllSound = GetCVar("Sound_EnableAllSound")

	SetCVar("Sound_EnableAllSound", 1)

	local willPlay, soundHandle = PlaySoundFile(path, "master")

	if willPlay then
		StopSound(soundHandle)
	end

	SetCVar("Sound_EnableAllSound", enableAllSound)

	return willPlay
end
