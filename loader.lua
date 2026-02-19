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
    loadstring(result)()
else
    warn("lunaris: Ошибка загрузки основного файла. Проверьте интернет или GitHub.")
end
