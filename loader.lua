-- [[ lunaris Loader ]]
local baseUrl = "https://raw.githubusercontent.com/kratmy/gti_te1/main/"

local actualUrls = {
	main   = "lunarisV9.lua",
	aim    = "aim2.lua",
	esp    = "esp2.lua"
}


_G.LunarisLoader = actualUrls

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
    warn("ГИТХАБ НЕ ОТВЕТИЛ")
end
