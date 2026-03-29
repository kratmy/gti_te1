local LocalPlrModule = {}

local Initialized = false
local InitializedAfterDisable = false --метка изгоя
local GameWS = 16
local GameJP = 50
local lastJ = 0

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
			InitializedAfterDisable = false
		else
			if not InitializedAfterDisable then
				Hum.WalkSpeed = GameWS
				InitializedAfterDisable = true
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
		-- [[ Infinite Jump ]]
		if Toggles.InfJump and Toggles.InfJump.Value then
			if not _G.JumpConn then
				local lastJ = 0
				_G.JumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
					if tick() - lastJ > 0.18 then
						local Hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
						if Hum then
							Hum:ChangeState(Enum.HumanoidStateType.Jumping)
							lastJ = tick()
						end
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
	local mt = getrawmetatable(game)
	setreadonly(mt, false)

	if oldNewIndex then
		mt.__newindex = oldNewIndex
	end
	
	setreadonly(mt, true)
	
	--[[if Initialized then
		LocalPlrModule.Reset(Options)
	end]]
	
	--метки изгоя убрать надо
	Initialized = false
	InitializedAfterDisable = false
end

return LocalPlrModule
