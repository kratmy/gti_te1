local LocalPlrModule = {}

local Initialized = false
local InitializedAfterDisable = false -- Метка для однократного возврата скорости
local GameWS = 16
local GameJP = 50

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and t:IsA("Humanoid") then
        local toggles = _G.Toggles
        
        if k == "WalkSpeed" then
            if toggles and toggles.EnableWS and toggles.EnableWS.Value then
                if math.floor(v) == math.floor(GameWS) then 
                    return oldNewIndex(t, k, v) 
                end
                -- Возвращаем текущую скорость, чтобы не крашить ControlModule игры
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
    return oldNewIndex(t, k, v)
end) -- Исправлено: убрана лишняя скобка )

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
            InitializedAfterDisable = false -- Сбрасываем метку, когда чит включен
        else
            -- Возвращаем дефолт ТОЛЬКО ОДИН РАЗ после выключения
            if not InitializedAfterDisable then
                Hum.WalkSpeed = GameWS
                InitializedAfterDisable = true
            end
            -- Теперь, когда InitializedAfterDisable = true, этот блок больше не мешает игре менять скорость
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
