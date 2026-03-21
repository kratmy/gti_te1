-- [[ lunaris Loader ]]
local baseUrl = "https://raw.githubusercontent.com/kratmy/gti_te1/main/"

local actualUrls = {
	main   = "lunarisV10.lua",
	aim    = "aim2.lua",
	esp    = "esp3.lua"
}


_G.LunarisLoader = actualUrls

-- [[ ЗВУКИ ]]
_G.NotifySound1 = "rbxassetid://4590662766"

_G.SendNotify = function(sound, message, duration)
	if sound then
		local s = Instance.new("Sound")
		s.SoundId = sound
		s.Volume = 2
		s.Parent = game:GetService("SoundService")
		s:Play()
		s.Ended:Connect(function() s:Destroy() end)
	end
	
	if _G.Library then
		_G.Library:Notify(message or "failed to load", duration or 5)
	end
end


local success, result = pcall(function()
	return game:HttpGet(baseUrl .. actualUrls.main)
end)

if success then
	local func, err = loadstring(result)
	if not func then 
		warn("СИНТАКСИС В ОСНОВНОМ ФАЙЛЕ ГОВНО: " .. tostring(err)) 
	else
		local ok, runtimeErr = pcall(func)
		if not ok then
			warn("СКРИПТ СДОХ ПРИ ВЫПОЛНЕНИИ: " .. tostring(runtimeErr))
		end
	end
else
	warn("ГИТХАБ СПИТ")
end
