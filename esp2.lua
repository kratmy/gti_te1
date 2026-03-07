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

    -- 2. ГЛАВНАЯ ПРОВЕРКА (Если общий ESP выключен — выходим сразу)
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

					-- BOX
					if Toggles.BoxEnabled.Value and (not IsSelf or Toggles.SelfBox.Value) then
						data.Box.Visible = true
						data.Box.Position = BPos
						data.Box.Size = Vector2.new(SX, SY)
						data.Box.Color = IsSelf and Options.SelfBoxCol.Value or Color
					end
							
					-- TEXTS
					if Toggles.ShowName.Value and (not IsSelf or Toggles.SelfText.Value) then
						data.Name.Visible = true
						data.Name.Text = IsSelf and "YOU" or Player.Name
						data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
					end
					
					-- TRACERS
					if Toggles.TracerEnabled.Value and (not IsSelf or Toggles.SelfTracers.Value) then
						data.Tracer.Visible = true
						data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
						data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
						data.Tracer.Color = IsSelf and Options.SelfTracerCol.Value or Color
					end

					-- CHAMS
					if Toggles.ChamsEnabled.Value and (not IsSelf or Toggles.SelfChams.Value) then
						data.Highlight.Enabled = true
						data.Highlight.Adornee = Char
						data.Highlight.FillColor = IsSelf and Options.SelfChamsCol.Value or Color
						data.Highlight.FillTransparency = Options.ChamsTransp.Value
					end

					-- HP (Линия и текст)
					if (not IsSelf and Toggles.HealthBar.Value) then
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
end

return EspModule


