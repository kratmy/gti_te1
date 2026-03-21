local LocalPlrModule = {}

local Initialized = false
local InitializedAfterDisable = false
local GameWS = 16
local GameJP = 50

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and t:IsA("Humanoid") then
        local toggles = _G.Toggles
        
        if k == "WalkSpeed" then
            -- Если чит ВКЛЮЧЕН, мы просто НЕ выполняем запись, но возвращаем оригинал
            if toggles and toggles.EnableWS and toggles.EnableWS.Value then
                -- Если игра пытается поставить дефолт, разрешаем, чтобы не ломать логику
                if math.floor(v) == math.floor(GameWS) then 
                    return oldNewIndex(t, k, v) 
                end
                -- В остальных случаях имитируем успех для игры, но ничего не меняем
                return oldNewIndex(t, k, t.WalkSpeed) 
            end
        elseif k == "JumpPower" then
            if toggles and toggles.EnableJP and toggles.EnableJP.Value then
                if math.floor(v) == math.floor(GameJP) then 
                    return oldNewIndex(t, k, v) 
                end
                return oldNewIndex(t, k, t.JumpPower)
            end
        end
    end
    -- Это самая важная строка, она должна выполняться ВСЕГДА
    return oldNewIndex(t, k, v)
end))

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
