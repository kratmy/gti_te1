local LocalPlrModule = {}

local Initialized = false
local GameWS = 16
local GameJP = 50

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and t:IsA("Humanoid") then
        local toggles = _G.Toggles
        
        -- Если таблицы нет или чит выключен — ПРОПУСКАЕМ СРАЗУ
        if not toggles then return oldNewIndex(t, k, v) end

        if k == "WalkSpeed" then
            -- Если галка выключена, сразу даем игре доступ
            if not toggles.EnableWS or toggles.EnableWS.Value == false then
                return oldNewIndex(t, k, v)
            end
            -- Если галка включена, разрешаем только дефолт
            if v == GameWS then return oldNewIndex(t, k, v) end
            return -- БЛОКИРОВКА
        elseif k == "JumpPower" then
            if not toggles.EnableJP or toggles.EnableJP.Value == false then
                return oldNewIndex(t, k, v)
            end
            if v == GameJP then return oldNewIndex(t, k, v) end
            return -- БЛОКИРОВКА
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
            -- Возвращаем дефолт ОДИН РАЗ (проверка math.floor убирает микро-отклонения)
            if math.floor(Hum.WalkSpeed) ~= math.floor(GameWS) then
                Hum.WalkSpeed = GameWS
            end
        end
        
        -- [[ JumpPower ]]
        if Toggles.EnableJP and Toggles.EnableJP.Value then
            Hum.JumpPower = Options.JumpPowerSlider.Value
            Hum.UseJumpPower = true 
        else
            if Hum.JumpPower ~= GameJP then
                Hum.JumpPower = GameJP
            end
        end
    end
end

return LocalPlrModule
