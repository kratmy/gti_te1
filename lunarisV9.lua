local EspModule = {}

function EspModule.Run(Objects, Toggles, Options, LP, Camera, UIS)
	-- 1. ИСПРАВЛЕННАЯ ФУНКЦИЯ ЦВЕТА (вернули Player)
	local function GetEspColor(Player, StaticColor)
		if Toggles.GlobalRainbow and Toggles.GlobalRainbow.Value then 
			return Color3.fromHSV(tick() % 5 / 5, 1, 1) 
		end
		if not Options.GlobalMode or not Player then 
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

	if type(Objects) ~= "table" then return end

	for Player, data in pairs(Objects) do
		local IsSelf = (Player == LP)
		local Char = Player.Character
		local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
		
		-- СБРОС ВИДИМОСТИ
		data.Box.Visible = false
		data.Tracer.Visible = false
		data.Name.Visible = false
		data.Dist.Visible = false
		data.HPText.Visible = false
		data.HealthBar.Visible = false
		data.HealthOutline.Visible = false
		data.Highlight.Enabled = false
		if data.Corners then for _, l in pairs(data.Corners) do l.Visible = false end end

		-- ГЛАВНАЯ ПРОВЕРКА
		if not Toggles.EspEnabled.Value then continue end

		if Char and Hum and Hum.Health > 0 then
			-- Tracer Target (из настроек)
			local TargetPart = Options.TracerTarget and Options.TracerTarget.Value or "HumanoidRootPart"
			local Root = Char:FindFirstChild(TargetPart)
			
			if Root then
				local Pos, OnS = Camera:WorldToViewportPoint(Root.Position)
				if OnS then
					-- ОПРЕДЕЛЕНИЕ ЦВЕТА (Твой или общий)
					local Color = GetEspColor(Player, Options.BoxColor.Value)
					
					local SX = 2000 / Pos.Z
					local SY = 3000 / Pos.Z
					local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)
					local Thick = Options.Thickness and Options.Thickness.Value or 1

					-- BOX (Стиль: Corners/Box + Толщина)
					if Toggles.BoxEnabled.Value and (not IsSelf or Toggles.SelfBox.Value) then
						if Options.BoxStyle and Options.BoxStyle.Value == 'Corners' and data.Corners then
							for _, l in pairs(data.Corners) do
								l.Visible = true
								l.Color = Color
								l.Thickness = Thick
							end
						else
							data.Box.Visible = true
							data.Box.Position = BPos
							data.Box.Size = Vector2.new(SX, SY)
							data.Box.Color = Color
							data.Box.Thickness = Thick
						end
					end
							
					-- TEXTS (Имя, Дистанция, ХП Текст)
					if not IsSelf or (IsSelf and Toggles.SelfNameAndDist.Value) then
						if Toggles.ShowNames.Value then
							data.Name.Visible = true
							data.Name.Text = IsSelf and "YOU" or Player.Name
							data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
						end
						
						if Toggles.ShowDistance.Value then
							data.Dist.Visible = true
							data.Dist.Text = math.floor(Pos.Z) .. "m"
							data.Dist.Position = Vector2.new(Pos.X, BPos.Y + SY + 2)
						end

						if Toggles.ShowHPText.Value then
							data.HPText.Visible = true
							data.HPText.Text = math.floor(Hum.Health) .. " HP"
							data.HPText.Position = Vector2.new(BPos.X + SX + 15, BPos.Y + SY/2)
						end
					end
					
					-- TRACERS (Откуда, Цвет, Толщина)
					if Toggles.TracerEnabled.Value and (not IsSelf or Toggles.SelfTracers.Value) then
						local Origin = Options.Origin and Options.Origin.Value or "Bottom"
						local TColor = IsSelf and Options.SelfTracerCol.Value or Color
						data.Tracer.Visible = true
						data.Tracer.From = (Origin == "Bottom" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)) or (Origin == "Middle" and Camera.ViewportSize / 2) or Vector2.new(Camera.ViewportSize.X / 2, 0)
						data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
						data.Tracer.Color = TColor
						data.Tracer.Thickness = Thick
					end

					-- HEALTH BAR (Только враги + Обводка)
					if Toggles.HealthBar.Value and not IsSelf then
						local H = Hum.Health / Hum.MaxHealth
						data.HealthBar.Visible = true
						data.HealthOutline.Visible = Toggles.HPBarOutline and Toggles.HPBarOutline.Value or false
						
						data.HealthBar.From = Vector2.new(BPos.X - 5, BPos.Y + SY)
						data.HealthBar.To = Vector2.new(BPos.X - 5, BPos.Y + SY - (SY * H))
						data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
					end

					-- CHAMS (Highlights)
					if Toggles.ChamsEnabled.Value and (not IsSelf or Toggles.SelfChams.Value) then
						local CColor = IsSelf and Options.SelfChamsCol.Value or Color
						data.Highlight.Enabled = true
						data.Highlight.Adornee = Char
						data.Highlight.FillColor = CColor
						data.Highlight.FillTransparency = Options.ChamsTransp.Value
					end
				end
			end
		end
	end
end

return EspModule
