local LocalPlrModule = {}

local Initialized = false
local GameWS = 16
local GameJP = 50

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and t:IsA("Humanoid") then
        -- 1. Сначала ПРОВЕРЯЕМ, существует ли вообще таблица тюнеров
        local toggles = _G.Toggles
        if not toggles then return oldNewIndex(t, k, v) end

        -- 2. Проверка скорости
        if k == "WalkSpeed" then
            -- Если галка ВЫКЛЮЧЕНА — вообще ничего не делаем, пропускаем игру
            if not toggles.EnableWS or toggles.EnableWS.Value == false then
                return oldNewIndex(t, k, v)
            end
            
            -- Если галка ВКЛЮЧЕНА, но игра ставит дефолт — пропускаем
            if v == GameWS then 
                return oldNewIndex(t, k, v) 
            end
            
            -- В ОСТАЛЬНЫХ СЛУЧАЯХ (когда чит включен и игра хочет свою скорость) — БЛОКИРУЕМ
            return 
        end

        -- 3. Проверка прыжка (аналогично)
        if k == "JumpPower" then
            if not toggles.EnableJP or toggles.EnableJP.Value == false then
                return oldNewIndex(t, k, v)
            end
            if v == GameJP then return oldNewIndex(t, k, v) end
            return 
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
			Hum.WalkSpeed = GameWS
		end
		
		-- [[ JumpPower ]]
		if Toggles.EnableJP and Toggles.EnableJP.Value then
			Hum.JumpPower = Options.JumpPowerSlider.Value
			Hum.UseJumpPower = true 
		else
			Hum.JumpPower = GameJP
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
