local AimlockModule = {}

local LockedTarget = nil

function AimlockModule.Run(Options, Toggles, LP, Players, Camera, UIS)
local function IsVisible(Part, Char)
		if not Toggles.WallCheck or not Toggles.WallCheck.Value then 
			return true 
		end
		
		local RayOrigin = Camera.CFrame.Position
		local RayDirection = (Part.Position - RayOrigin)
		
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		
		local IgnoreList = {LP.Character, Camera}
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character ~= Char then
				table.insert(IgnoreList, p.Character)
			end
		end

		Params.FilterDescendantsInstances = IgnoreList
		Params.IgnoreWater = true

		local Res = workspace:Raycast(RayOrigin, RayDirection, Params)
		
		if not Res or Res.Instance:IsDescendantOf(Char) then
			return true
		end
		
		return false
	end

	local AimKey = "MB2"
	if Options and Options.AimKeybind then
		AimKey = Options.AimKeybind.Value
	end
	
	local IsPressed = false
	if AimKey == "MB2" then
		IsPressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	elseif AimKey == "MB1" then
		IsPressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	else
		local success, keyEnum = pcall(function() return Enum.KeyCode[AimKey] end)
		if success then
			IsPressed = UIS:IsKeyDown(keyEnum)
		end
	end
	
	if Toggles.AimEnabled and Toggles.AimEnabled.Value and IsPressed then
		if LockedTarget then
		local Char = LockedTarget.Character
			local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
			local Part = Char and Char:FindFirstChild(Options.AimPart.Value)
			local isAlive = true
				
			local visible = IsVisible(Part, Char)
				if not visible and Toggles.WallCheck and Toggles.WallCheck.Value then
					isAlive = false
				end
				
				-- alive check
				if Toggles.AliveCheck and Toggles.AliveCheck.Value and Hum then
					if Hum.Health <= 0 then isAlive = false end
				end
				
					if not Part or not Hum or not isAlive then
					LockedTarget = nil 
				end
			end
			
			if not LockedTarget then
				local Closest = Options.FOVRadius.Value
				local MousePos = UIS:GetMouseLocation()

				for _, p in pairs(Players:GetPlayers()) do
					if p ~= LP and p.Character and p.Character:FindFirstChild(Options.AimPart.Value) then
						local Hum = p.Character:FindFirstChildOfClass("Humanoid")
						local canTarget = true
						local Part = p.Character:FindFirstChild(Options.AimPart.Value)
						if Toggles.AliveCheck and Toggles.AliveCheck.Value and Hum and Hum.Health <= 0 then
							canTarget = false
						end
						
						if canTarget and Part then
							local pos, ons = Camera:WorldToViewportPoint(Part.Position)
							if ons and IsVisible(Part, p.Character) then
								local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
								if dist < Closest then 
									LockedTarget = p 
									Closest = dist 
								end
							end
						end
					end
				end	
			end

			if LockedTarget then 
				local TargetPart = LockedTarget.Character[Options.AimPart.Value]
				local LookAt = CFrame.new(Camera.CFrame.Position, TargetPart.Position)
				Camera.CFrame = Camera.CFrame:Lerp(LookAt, Options.AimSmooth.Value) 
			end
		
		else
			LockedTarget = nil
		end
end

return AimlockModule





