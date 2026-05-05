local LocalPlrModule = {}

local Initialized = false
local GameWS = 16
local GameJP = 50

-- УБРАЛИ ВЕСЬ БЛОК С METATABLE (МЕТКИ ИЗГОЯ БОЛЬШЕ НЕ НУЖНЫ)

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
        -- Просто меняем значение. Если АЧ его сбросит, цикл Run поставит снова.
        if Toggles.EnableWS and Toggles.EnableWS.Value then
            if Hum.WalkSpeed ~= Options.WalkSpeedSlider.Value then
                Hum.WalkSpeed = Options.WalkSpeedSlider.Value
            end
        else
            if Initialized and Hum.WalkSpeed ~= GameWS then
                Hum.WalkSpeed = GameWS
            end
        end
        
        -- [[ JumpPower ]]
        if Toggles.EnableJP and Toggles.EnableJP.Value then
            Hum.UseJumpPower = true 
            if Hum.JumpPower ~= Options.JumpPowerSlider.Value then
                Hum.JumpPower = Options.JumpPowerSlider.Value
            end
        else
            if Initialized and Hum.JumpPower ~= GameJP then
                Hum.JumpPower = GameJP
            end
        end

        -- [[ Infinite Jump ]] - этот блок обычно не детектится через 267
        if Toggles.InfJump and Toggles.InfJump.Value then
            if not _G.JumpConn then
                _G.JumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                    local Hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                    if Hum then
                        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        else
            if _G.JumpConn then
                _G.JumpConn:Disconnect()
                _G.JumpConn = nil
            end
        end
    end
end

function LocalPlrModule.Unload(Options)
    -- Очистка метатаблицы больше не нужна
    Initialized = false
end

return LocalPlrModule
