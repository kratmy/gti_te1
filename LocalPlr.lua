local LocalPlrModule = {}

local Initialized = false
local GameWS = 16
local GameJP = 50

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
