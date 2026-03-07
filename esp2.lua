local EspModule = {}

function EspModule.Run(Objects, Toggles, Options, LP, Camera, UIS)
	-- [[ ТВОЯ ФУНКЦИЯ ЦВЕТА ]]
	local function GetEspColor(Player, StaticColor)
		if Toggles.GlobalRainbow and Toggles.GlobalRainbow.Value then 
			return Color3.fromHSV(tick() % 5 / 5, 1, 1) 
		end
		if not Options.GlobalMode then 
			return StaticColor 
		end
		
		local Mode = Options.GlobalMode.Value
		if Mode == 'Team Color' then 
			return Player.TeamColor.Color
		elseif Mode == 'Friend/Enemy' then 
			if Player.Team == LP.Team then
				return Options.FriendCol.Value
			else
				return Options.EnemyCol.Value
			end
		end
		return StaticColor
	end

	-- [[ ТВОЙ ЦИКЛ ESP ]]
	if type(Objects) ~= "table" then return end
for Player, data in pairs(Objects) do
	local IsSelf = (Player == LP)
	local Char = Player.Character
	local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
	
	-- 1. СБРОС ВИДИМОСТИ
	data.Box.Visible = false
	data.Tracer.Visible = false
	data.Name.Visible = false
	data.Dist.Visible = false
	data.HPText.Visible = false
	data.HealthBar.Visible = false
	data.HealthOutline.Visible = false
	data.Highlight.Enabled = false
	if data.Corners then for _, l in pairs(data.Corners) do l.Visible = false end end

	-- 2. ГЛАВНЫЙ ВЫКЛЮЧАТЕЛЬ (Enabled)
	if not Toggles.EspEnabled.Value then continue end

	if Char and Hum and Hum.Health > 0 then
		local Root = Char:FindFirstChild("HumanoidRootPart")
		if Root then
			local Pos, OnS = Camera:WorldToViewportPoint(Root.Position)
			if OnS then
				local Color = GetEspColor(Player, Options.BoxColor.Value)
				local SX = 2000 / Pos.Z
				local SY = 3000 / Pos.Z
				local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)

				-- BOX (Зависит от Draw Boxes + Self Box для тебя)
				if Toggles.BoxEnabled.Value then
					if not IsSelf or (IsSelf and Toggles.SelfBox.Value) then
						data.Box.Visible = true
						data.Box.Position = BPos
						data.Box.Size = Vector2.new(SX, SY)
						data.Box.Color = IsSelf and Options.SelfBoxCol.Value or Color
					end
				end
						
				-- NAME & DIST (Зависит от Show Names + Self Name & Dist для тебя)
				if Toggles.ShowName.Value then
					if not IsSelf or (IsSelf and Toggles.SelfText.Value) then
						data.Name.Visible = true
						data.Name.Text = IsSelf and "YOU" or Player.Name
						data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
					end
				end
				
				if Toggles.ShowDist.Value then
					if not IsSelf or (IsSelf and Toggles.SelfText.Value) then
						data.Dist.Visible = true
						data.Dist.Text = math.floor(Pos.Z) .. "m"
						local YOff = (Options.HealthBarSide.Value == 'Bottom') and 12 or 2
						data.Dist.Position = Vector2.new(Pos.X, BPos.Y + SY + YOff)
					end
				end

				-- HP TEXT (Зависит от Show HP Text)
				if Toggles.ShowHPText.Value then
					if not IsSelf or (IsSelf and Toggles.SelfText.Value) then
						data.HPText.Visible = true
						data.HPText.Text = math.floor(Hum.Health) .. " HP"
						data.HPText.Position = Vector2.new(BPos.X + SX + 20, BPos.Y + SY / 2)
					end
				end
				
				-- TRACERS (Зависит от Tracers + Self Tracers для тебя)
				if Toggles.TracerEnabled.Value then
					if not IsSelf or (IsSelf and Toggles.SelfTracers.Value) then
						data.Tracer.Visible = true
						data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
						data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
						data.Tracer.Color = IsSelf and Options.SelfTracerCol.Value or GetEspColor(Player, Options.TracerColor.Value)
					end
				end

				-- CHAMS (Зависит от Chams (Highlights) + Self Chams для тебя)
				if Toggles.ChamsEnabled.Value then
					if not IsSelf or (IsSelf and Toggles.SelfChams.Value) then
						data.Highlight.Enabled = true
						data.Highlight.Adornee = Char
						data.Highlight.FillColor = IsSelf and Options.SelfChamsCol.Value or GetEspColor(Player, Options.ChamsColor.Value)
						data.Highlight.FillTransparency = Options.ChamsTransp.Value
					end
				end

				-- HEALTH BAR (Только для других игроков)
				if Toggles.HealthBar.Value and not IsSelf then
					local H = Hum.Health / Hum.MaxHealth
					data.HealthBar.Visible = true
					data.HealthBar.From = Vector2.new(BPos.X - 5, BPos.Y + SY)
					data.HealthBar.To = Vector2.new(BPos.X - 5, BPos.Y + SY - (SY * H))
					data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
				end
			end
		end
	end
end

return EspModule


