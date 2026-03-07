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
	-- Цвет берется из общих настроек, если это не ты
				local Color = GetEspColor(Player, Options.BoxColor.Value)
				local SX = 2000 / Pos.Z
				local SY = 3000 / Pos.Z
				local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)
				local Thick = Options.Thickness and Options.Thickness.Value or 1

				-- BOX (Стиль, Толщина и зависимость от Draw Boxes)
				if Toggles.BoxEnabled.Value and (not IsSelf or Toggles.SelfBox.Value) then
					local TargetBox = (Options.BoxStyle and Options.BoxStyle.Value == 'Corners') and data.Corners or {data.Box}
					
					if Options.BoxStyle and Options.BoxStyle.Value == 'Corners' then
						for _, l in pairs(data.Corners) do
							l.Visible = true
							l.Color = IsSelf and Options.SelfBoxCol.Value or Color
							l.Thickness = Thick
						end
						-- Обновляем позиции углов (логика должна быть в твоем Draw-модуле)
					else
						data.Box.Visible = true
						data.Box.Position = BPos
						data.Box.Size = Vector2.new(SX, SY)
						data.Box.Color = IsSelf and Options.SelfBoxCol.Value or Color
						data.Box.Thickness = Thick
					end
				end
						
				-- TEXTS (Имя, Дистанция, ХП Текст + зависимость от Self Name & Dist)
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
						data.HPText.Position = Vector2.new(BPos.X + SX + 20, BPos.Y + SY / 2)
					end
				end
				
				-- TRACERS (Откуда, Куда, Цвет)
				if Toggles.TracerEnabled.Value and (not IsSelf or Toggles.SelfTracers.Value) then
					local Origin = Options.Origin and Options.Origin.Value or "Bottom"
					data.Tracer.Visible = true
					data.Tracer.From = (Origin == "Bottom" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)) or (Origin == "Middle" and Camera.ViewportSize / 2) or Vector2.new(Camera.ViewportSize.X / 2, 0)
					data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
					data.Tracer.Color = IsSelf and Options.SelfTracerCol.Value or Color
					data.Tracer.Thickness = Thick
				end

				-- HEALTH BAR (Сторона, Обводка)
				if Toggles.HealthBar.Value and not IsSelf then
					local H = Hum.Health / Hum.MaxHealth
					local Side = Options.HPBarSide and Options.HPBarSide.Value or "Left"
					data.HealthBar.Visible = true
					data.HealthOutline.Visible = Toggles.HPBarOutline and Toggles.HPBarOutline.Value or false
					
					-- Упрощенная позиция (для примера Left)
					data.HealthBar.From = Vector2.new(BPos.X - 5, BPos.Y + SY)
					data.HealthBar.To = Vector2.new(BPos.X - 5, BPos.Y + SY - (SY * H))
					data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
				end

				-- CHAMS
				if Toggles.ChamsEnabled.Value and (not IsSelf or Toggles.SelfChams.Value) then
					data.Highlight.Enabled = true
					data.Highlight.Adornee = Char
					data.Highlight.FillColor = IsSelf and Options.SelfChamsCol.Value or Color
					data.Highlight.FillTransparency = Options.ChamsTransp.Value
					end
				end
			end
		end
	end
end

return EspModule


