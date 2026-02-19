local EspModule = {}

-- [[ 1. ПЕРЕНОСИМ ФУНКЦИЮ ЦВЕТА ]]
local function GetEspColor(Player, StaticColor, Toggles, Options, LP)
    if Toggles.GlobalRainbow and Toggles.GlobalRainbow.Value then 
        return Color3.fromHSV(tick() % 5 / 5, 1, 1) 
    end
    if not Options.GlobalMode then return StaticColor end
    
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

-- [[ 2. ОСНОВНАЯ ФУНКЦИЯ ESP ]]
function EspModule.Run(Objects, Toggles, Options, LP, Camera, UIS)
    for Player, data in pairs(Objects) do
        local Char = Player.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        
        -- СБРОС (взято из строк 204-211 старого файла)
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
                        -- Вызываем перенесенную функцию цвета
                        local Color = GetEspColor(Player, Options.BoxColor.Value, Toggles, Options, LP)
                        local SX = 2000 / Pos.Z
                        local SY = 3000 / Pos.Z
                        local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)
                        
                        -- ЛОГИКА ОТРИСОВКИ (взята из строк 224-285 старого файла)
                        if Toggles.BoxEnabled.Value then
                            data.Box.Visible, data.Box.Position, data.Box.Size, data.Box.Color = true, BPos, Vector2.new(SX, SY), Color
                        end
                        
                        if Toggles.HealthBar.Value then
                            local H = Hum.Health / Hum.MaxHealth
                            local Side = Options.HealthBarSide.Value
                            data.HealthBar.Visible = true
                            data.HealthOutline.Visible = Toggles.HealthOutline.Value
                            
                            if Side == 'Left' then
                                data.HealthOutline.From, data.HealthOutline.To = Vector2.new(BPos.X - 5, BPos.Y + SY + 1), Vector2.new(BPos.X - 5, BPos.Y - 1)
                                data.HealthBar.From, data.HealthBar.To = Vector2.new(BPos.X - 5, BPos.Y + SY), Vector2.new(BPos.X - 5, BPos.Y + SY - (SY * H))
                            elseif Side == 'Right' then
                                data.HealthOutline.From, data.HealthOutline.To = Vector2.new(BPos.X + SX + 5, BPos.Y + SY + 1), Vector2.new(BPos.X + SX + 5, BPos.Y - 1)
                                data.HealthBar.From, data.HealthBar.To = Vector2.new(BPos.X + SX + 5, BPos.Y + SY), Vector2.new(BPos.X + SX + 5, BPos.Y + SY - (SY * H))
                            elseif Side == 'Bottom' then
                                data.HealthOutline.From, data.HealthOutline.To = Vector2.new(BPos.X - 1, BPos.Y + SY + 5), Vector2.new(BPos.X + SX + 1, BPos.Y + SY + 5)
                                data.HealthBar.From, data.HealthBar.To = Vector2.new(BPos.X, BPos.Y + SY + 5), Vector2.new(BPos.X + (SX * H), BPos.Y + SY + 5)
                            end
                            data.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), H)
                        end
                        
                        if Toggles.ShowName.Value then
                            data.Name.Visible, data.Name.Text, data.Name.Position = true, Player.Name, Vector2.new(Pos.X, BPos.Y - 16)
                        end
                        
                        if Toggles.ShowDist.Value then
                            local YOff = (Options.HealthBarSide.Value == 'Bottom') and 12 or 2
                            data.Dist.Visible, data.Dist.Text, data.Dist.Position = true, math.floor(Pos.Z) .. "m", Vector2.new(Pos.X, BPos.Y + SY + YOff)
                        end
                        
                        if Toggles.ShowHPText.Value then
                            data.HPText.Visible, data.HPText.Text, data.HPText.Position = true, math.floor(Hum.Health) .. " HP", Vector2.new(BPos.X + SX + 20, BPos.Y + SY / 2)
                        end
                        
                        if Toggles.TracerEnabled.Value then
                            local Origin = Options.TracerOrigin.Value
                            local FromPos = (Origin == 'Top' and Vector2.new(Camera.ViewportSize.X/2, 0)) or (Origin == 'Center' and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)) or (Origin == 'Mouse' and UIS:GetMouseLocation()) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            data.Tracer.Visible, data.Tracer.From, data.Tracer.To, data.Tracer.Color = true, FromPos, Vector2.new(Pos.X, Pos.Y), GetEspColor(Player, Options.TracerColor.Value, Toggles, Options, LP)
                        end
                        
                        if Toggles.ChamsEnabled.Value then
                            data.Highlight.Enabled, data.Highlight.Adornee, data.Highlight.FillColor, data.Highlight.FillTransparency = true, Char, GetEspColor(Player, Options.ChamsColor.Value, Toggles, Options, LP), Options.ChamsTransp.Value
                        end
                    end
                end
            end
        end
    end
end

return EspModule
