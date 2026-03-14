local EspModule = {}

function EspModule.Run(Objects, Toggles, Options, LP, Camera, UIS)
	-- 1. ФУНКЦИЯ ЦВЕТА (Исправлена, принимает Player)
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
		data.HPBarOutline.Visible = false
		data.Highlight.Enabled = false
		if data.Corners then for _, l in pairs(data.Corners) do l.Visible = false end end

		-- 2. ГЛАВНАЯ ПРОВЕРКА
		if not Toggles.EspEnabled or not Toggles.EspEnabled.Value then continue end

		if Char and Hum and Hum.Health > 0 then
			local TargetPart = Options.TracerTarget and Options.TracerTarget.Value or "HumanoidRootPart"
			local Root = Char:FindFirstChild(TargetPart)
			
			if Root then
				local Pos, OnS = Camera:WorldToViewportPoint(Root.Position)
				
				-- ЗАЩИТА ОТ ДЕЛЕНИЯ НА НОЛЬ (Fix "Box only on one person")
				if OnS and Pos.Z > 1 then 
					local SX = 2000 / Pos.Z
					local SY = 3000 / Pos.Z
					local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)
					
					-- ОПРЕДЕЛЕНИЕ ЦВЕТА
					local Color = IsSelf and (Options.SelfBoxCol and Options.SelfBoxCol.Value or Color3.new(1,1,1)) 
								or GetEspColor(Player, Options.BoxColor.Value)
					
					local Thick = Options.BoxThickness and Options.BoxThickness.Value or 1

					-- BOX
					if Toggles.BoxEnabled and Toggles.BoxEnabled.Value then
						if not IsSelf or (IsSelf and Toggles.SelfBox and Toggles.SelfBox.Value) then
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
					end
					
					-- TEXTS (Имя, Дистанция, ХП)
					if not IsSelf or (IsSelf and Toggles.SelfText and Toggles.SelfText.Value) then
						if Toggles.ShowName and Toggles.ShowName.Value then
							data.Name.Visible = true
							data.Name.Text = IsSelf and "YOU" or Player.Name
							data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
						end
						
						if Toggles.ShowDist and Toggles.ShowDist.Value then
							data.Dist.Visible = true
							data.Dist.Text = math.floor(Pos.Z) .. "m"
							data.Dist.Position = Vector2.new(Pos.X, BPos.Y + SY + 2)
						end
						
						if Toggles.ShowHPText and Toggles.ShowHPText.Value then
							data.HPText.Visible = true
							data.HPText.Text = math.floor(Hum.Health) .. " HP"
							data.HPText.Position = Vector2.new(BPos.X + SX + 15, BPos.Y + SY/2)
						end
					end
					
					-- TRACERS
					if Toggles.TracerEnabled and Toggles.TracerEnabled.Value then
						if not IsSelf or (IsSelf and Toggles.SelfTracers and Toggles.SelfTracers.Value) then
							data.Tracer.Visible = true

							local Origin = Options.TracerOrigin and Options.TracerOrigin.Value or "Bottom"
							if Origin == "Bottom" then
								data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							elseif Origin == "Center" then
								data.Tracer.From = Camera.ViewportSize / 2
							elseif Origin == "Top" then
								data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
							elseif Origin == "Mouse" then
								data.Tracer.From = UIS:GetMouseLocation()
							end
							
							data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
							data.Tracer.Color = IsSelf and (Options.SelfTracerCol and Options.SelfTracerCol.Value or Color) or Color
							data.Tracer.Thickness = Thick
						end
					end

					-- HEALTH BAR
					if Toggles.HealthBar and Toggles.HealthBar.Value and not IsSelf then
						local Side = Options.HealthBarSide and Options.HealthBarSide.Value or "Left"
						local H = Hum.Health / Hum.MaxHealth
						data.HealthBar.Visible = true
						data.HPBarOutline.Visible = Toggles.HPBarOutline and Toggles.HPBarOutline.Value or false
						
						local barX = (Side == "Left") and (BPos.X - 5) or (BPos.X + SX + 5)
	
						data.HealthBar.From = Vector2.new(barX, BPos.Y + SY)
						data.HealthBar.To = Vector2.new(barX, BPos.Y + SY - (SY * H))
						data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
						
						if data.HPBarOutline.Visible then
							data.HPBarOutline.From = data.HealthBar.From
							data.HPBarOutline.To = data.HealthBar.To
						end
					end

					-- CHAMS
					if Toggles.ChamsEnabled and Toggles.ChamsEnabled.Value then
						if not IsSelf or (IsSelf and Toggles.SelfChams and Toggles.SelfChams.Value) then
							data.Highlight.Enabled = true
							data.Highlight.Adornee = Char
							data.Highlight.FillColor = IsSelf and (Options.SelfChamsCol and Options.SelfChamsCol.Value or Color) or Color
							data.Highlight.FillTransparency = Options.ChamsTransp and Options.ChamsTransp.Value or 0.5
						end
					end
				end
			end
		end
	end
end

return EspModule
