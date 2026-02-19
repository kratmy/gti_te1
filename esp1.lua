local EspModule = {}

function EspModule.Run(Objects, Toggles, Options, LP, Camera, UIS)
    -- Функция цвета внутри модуля (чтобы всё работало автономно)
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

    -- Твой основной цикл обновления
    for Player, data in pairs(Objects) do
        local Char = Player.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        
        -- СБРОС ВИДИМОСТИ ПЕРЕД ПРОВЕРКОЙ
        data.Box.Visible = false
        data.Tracer.Visible = false
        data.Name.Visible = false
        data.Dist.Visible = false
        data.HPText.Visible = false
        data.HealthBar.Visible = false
        data.HealthOutline.Visible = false
        data.Highlight.Enabled = false

        if Toggles.EspEnabled and Toggles.EspEnabled.Value then
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
                        if Toggles.BoxEnabled.Value then
                            data.Box.Visible = true
                            data.Box.Position = BPos
                            data.Box.Size = Vector2.new(SX, SY)
                            data.Box.Color = Color
                        end
                        
                        -- HEALTH BAR
                        if Toggles.HealthBar.Value then
                            local H = Hum.Health / Hum.MaxHealth
                            local Side = Options.HealthBarSide.Value
                            data.HealthBar.Visible = true
                            data.HealthOutline.Visible = Toggles.HealthOutline.Value
                            
                            if Side == 'Left' then
                                data.HealthOutline.From = Vector2.new(BPos.X - 5, BPos.Y + SY + 1)
                                data.HealthOutline.To = Vector2.new(BPos.X - 5, BPos.Y - 1)
                                data.HealthBar.From = Vector2.new(BPos.X - 5, BPos.Y + SY)
                                data.HealthBar.To = Vector2.new(BPos.X - 5, BPos.Y + SY - (SY * H))
                            elseif Side == 'Right' then
                                data.HealthOutline.From = Vector2.new(BPos.X + SX + 5, BPos.Y + SY + 1)
                                data.HealthOutline.To = Vector2.new(BPos.X + SX + 5, BPos.Y - 1)
                                data.HealthBar.From = Vector2.new(BPos.X + SX + 5, BPos.Y + SY)
                                data.HealthBar.To = Vector2.new(BPos.X + SX + 5, BPos.Y + SY - (SY * H))
                            elseif Side == 'Bottom' then
                                data.HealthOutline.From = Vector2.new(BPos.X - 1, BPos.Y + SY + 5)
                                data.HealthOutline.To = Vector2.new(BPos.X + SX + 1, BPos.Y + SY + 5)
                                data.HealthBar.From = Vector2.new(BPos.X, BPos.Y + SY + 5)
                                data.HealthBar.To = Vector2.new(BPos.X + (SX * H), BPos.Y + SY + 5)
                            end
                            data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
                        end
                        
                        -- TEXTS (NAME, DIST, HP)
                        if Toggles.ShowName.Value then
                            data.Name.Visible = true
                            data.Name.Text = Player.Name
                            data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
                        end
                        
                        if Toggles.ShowDist.Value then
                            data.Dist.Visible = true
                            data.Dist.Text = math.floor(Pos.Z) .. "m"
                            local YOff = (Options.HealthBarSide.Value == 'Bottom') and 12 or 2
                            data.Dist.Position = Vector2.new(Pos.X, BPos.Y + SY + YOff)
                        end
                        
                        if Toggles.ShowHPText.Value then
                            data.HPText.Visible = true
                            data.HPText.Text = math.floor(Hum.Health) .. " HP"
                            data.HPText.Position = Vector2.new(BPos.X + SX + 20, BPos.Y + SY / 2)
                        end
                        
                        -- TRACERS
                        if Toggles.TracerEnabled.Value then
                            local Origin = Options.TracerOrigin.Value
                            local FromPos
                            if Origin == 'Top' then 
                                FromPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
                            elseif Origin == 'Center' then 
                                FromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            elseif Origin == 'Mouse' then 
                                FromPos = UIS:GetMouseLocation()
                            else 
                                FromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            end
                            data.Tracer.Visible = true
                            data.Tracer.From = FromPos
                            data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
                            data.Tracer.Color = GetEspColor(Player, Options.TracerColor.Value)
                        end
                        
                        -- CHAMS (HIGHLIGHTS)
                        if Toggles.ChamsEnabled.Value then
                            data.Highlight.Enabled = true
                            data.Highlight.Adornee = Char
                            data.Highlight.FillColor = GetEspColor(Player, Options.ChamsColor.Value)
                            data.Highlight.FillTransparency = Options.ChamsTransp.Value
                        end
                    end
                end
            end
        end
    end
end

return EspModule
