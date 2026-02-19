-- [[ lunaris Loader ]]
local baseUrl = "https://raw.githubusercontent.com/kratmy/gti_te1/main/"

local actualUrls = {
    main   = "lunarisV9.lua",
    aim    = "aim2.lua",
    esp    = "esp2.lua"
}


_G.LunarisLoader = actualUrls
loadstring(game:HttpGet(baseUrl .. actualUrls.main))()
