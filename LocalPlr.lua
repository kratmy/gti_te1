local LocalPlrModule = {}

local Initialized = false
local GameWS = 16
local GameJP = 50

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and t:IsA("Humanoid") then
        -- Блокировка работает ТОЛЬКО если в _G.Toggles стоит true
        if k == "WalkSpeed" and _G.Toggles and _G.Toggles.EnableWS and _G.Toggles.EnableWS.Value then
            return -- Блокируем запись от игры
        elseif k == "JumpPower" and _G.Toggles and _G.Toggles.EnableJP and _G.Toggles.EnableJP.Value then
            return -- Блокируем запись от игры
        end
    end
    return oldNewIndex(t, k, v)
end)
setreadonly(mt, true)

function LocalPlrModule.Run(Options, Toggles, LP)
    local Char = LP.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    if Hum then
        if not Initialized then
            GameWS = Hum.WalkSpeed
            GameJP = Hum.JumpPower
            Initialized = true
        end

        -- [[ WalkSpeed ]]
        if Toggles.EnableWS and Toggles.EnableWS.Value then
            Hum.WalkSpeed = Options.WalkSpeedSlider.Value
        else
            -- Если чит ВЫКЛЮЧЕН, возвращаем дефолт ОДИН РАЗ
            if math.floor(Hum.WalkSpeed) ~= math.floor(GameWS) then
                Hum.WalkSpeed = GameWS
                print("Скорость возвращена к дефолту: " .. GameWS)
            end
        end
        
        -- [[ JumpPower ]]
        if Toggles.EnableJP and Toggles.EnableJP.Value then
            Hum.JumpPower = Options.JumpPowerSlider.Value
            Hum.UseJumpPower = true 
        else
            -- Возвращаем дефолт прыжка один раз
            if Hum.JumpPower ~= GameJP then
                Hum.JumpPower = GameJP
            end
        end
    end
end

function LocalPlrModule.Reset(Options)
    if Initialized then
        Options.WalkSpeedSlider:SetValue(GameWS)
        Options.JumpPowerSlider:SetValue(GameJP)
    end
end

return LocalPlrModule
