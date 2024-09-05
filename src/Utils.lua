local GetCVar, SetCVar, PlaySoundFile, StopSound = GetCVar, SetCVar, PlaySoundFile, StopSound

function Deepcopy(orig, copies)
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
				copy[Deepcopy(orig_key, copies)] = Deepcopy(orig_value, copies)
			end
			setmetatable(copy, Deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

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
