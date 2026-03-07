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
for Player, data in pairs(Objects) do
	local IsSelf = (Player == LP)
	local Char = Player.Character
	local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
	
	-- 1. СБРОС (Чистим всё перед кадром)
	data.Box.Visible = false
	data.Tracer.Visible = false
	data.Name.Visible = false
	data.Dist.Visible = false
	data.HPText.Visible = false
	data.HealthBar.Visible = false
	data.HealthOutline.Visible = false
	data.Highlight.Enabled = false
	if data.Corners then for _, l in pairs(data.Corners) do l.Visible = false end end

	-- 2. ГЛАВНЫЙ ЧЕК (Если Enabled выключен - дальше не идем)
	if not (Toggles.EspEnabled and Toggles.EspEnabled.Value) then continue end

	if Char and Hum and Hum.Health > 0 then
		local Root = Char:FindFirstChild("HumanoidRootPart")
		if Root then
			local Pos, OnS = Camera:WorldToViewportPoint(Root.Position)
			if OnS then
				local Color = GetEspColor(Player, Options.BoxColor.Value)
				local SX = 2000 / Pos.Z
				local SY = 3000 / Pos.Z
				local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)

				-- BOX (Только если Draw Boxes ON)
				if Toggles.BoxEnabled and Toggles.BoxEnabled.Value then
					if not IsSelf or (IsSelf and Toggles.SelfBox and Toggles.SelfBox.Value) then
						data.Box.Visible = true
						data.Box.Position = BPos
						data.Box.Size = Vector2.new(SX, SY)
						data.Box.Color = (IsSelf and Options.SelfBoxCol) and Options.SelfBoxCol.Value or Color
					end
				end
						
				-- TEXTS (Имя и Дистанция зависят от своих общих кнопок)
				if not IsSelf or (IsSelf and Toggles.SelfNameAndDist and Toggles.SelfNameAndDist.Value) then
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
				end

				-- TRACERS
				if Toggles.TracerEnabled and Toggles.TracerEnabled.Value then
					if not IsSelf or (IsSelf and Toggles.SelfTracers and Toggles.SelfTracers.Value) then
						data.Tracer.Visible = true
						data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
						data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
						data.Tracer.Color = (IsSelf and Options.SelfTracerCol) and Options.SelfTracerCol.Value or Color
					end
				end

				-- CHAMS
				if Toggles.ChamsEnabled and Toggles.ChamsEnabled.Value then
					if not IsSelf or (IsSelf and Toggles.SelfChams and Toggles.SelfChams.Value) then
						data.Highlight.Enabled = true
						data.Highlight.Adornee = Char
						data.Highlight.FillColor = (IsSelf and Options.SelfChamsCol) and Options.SelfChamsCol.Value or Color
						data.Highlight.FillTransparency = Options.ChamsTransp.Value
					end
				end

				-- HP (Только если включен Health Bar и это НЕ ты)
				if Toggles.HealthBar and Toggles.HealthBar.Value and not IsSelf then
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
