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

	-- 2. ГЛАВНАЯ ПРОВЕРКА (Если общий ESP выключен — ничего не рисуем)
	if not Toggles.EspEnabled.Value then continue end

	if Char and Hum and Hum.Health > 0 then
		local Root = Char:FindFirstChild("HumanoidRootPart")
		if Root then
			local Pos, OnS = Camera:WorldToViewportPoint(Root.Position)
			if OnS then
				-- ЦВЕТ: Всегда берем общий цвет через твою функцию GetEspColor
				local Color = GetEspColor(Player, Options.BoxColor.Value)
				local SX = 2000 / Pos.Z
				local SY = 3000 / Pos.Z
				local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)

				-- BOX (Зависит только от BoxEnabled)
				if Toggles.BoxEnabled.Value then
					data.Box.Visible = true
					data.Box.Position = BPos
					data.Box.Size = Vector2.new(SX, SY)
					data.Box.Color = Color
				end
						
				-- NAME & DIST (Зависит только от ShowName/ShowDist)
				if Toggles.ShowName.Value then
					data.Name.Visible = true
					data.Name.Text = IsSelf and "YOU" or Player.Name
					data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
					data.Name.Color = Color
				end
				
				if Toggles.ShowDist.Value then
					data.Dist.Visible = true
					data.Dist.Text = math.floor(Pos.Z) .. "m"
					data.Dist.Position = Vector2.new(Pos.X, BPos.Y + SY + 2)
				end
				
				-- TRACERS (Зависит только от TracerEnabled и общего цвета)
				if Toggles.TracerEnabled.Value then
					data.Tracer.Visible = true
					data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
					data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
					data.Tracer.Color = GetEspColor(Player, Options.TracerColor.Value)
				end

				-- CHAMS (Зависит только от ChamsEnabled и общего цвета)
				if Toggles.ChamsEnabled.Value then
					data.Highlight.Enabled = true
					data.Highlight.Adornee = Char
					data.Highlight.FillColor = GetEspColor(Player, Options.ChamsColor.Value)
					data.Highlight.FillTransparency = Options.ChamsTransp.Value
				end

				-- HP BAR & TEXT (Зависит только от основных настроек)
				if Toggles.HealthBar.Value then
					local H = Hum.Health / Hum.MaxHealth
					data.HealthBar.Visible = true
					data.HealthBar.From = Vector2.new(BPos.X - 5, BPos.Y + SY)
					data.HealthBar.To = Vector2.new(BPos.X - 5, BPos.Y + SY - (SY * H))
					data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
				end
				
				if Toggles.ShowHPText.Value then
					data.HPText.Visible = true
					data.HPText.Text = math.floor(Hum.Health) .. " HP"
					data.HPText.Position = Vector2.new(BPos.X + SX + 20, BPos.Y + SY / 2)
				end
			end
		end
	end
end

return EspModule


