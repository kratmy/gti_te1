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
        local Char = Player.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        local IsSelf = (Player == LP) -- Определяем, ты ли это

        -- 1. СБРОС (Чистим экран перед отрисовкой)
        data.Box.Visible = false
        data.Tracer.Visible = false
        data.Name.Visible = false
        data.Dist.Visible = false
        data.HPText.Visible = false
        data.HealthBar.Visible = false
        data.HealthOutline.Visible = false
        data.Highlight.Enabled = false
        if data.Corners then for _, l in pairs(data.Corners) do l.Visible = false end end

        -- 2. ГЛАВНОЕ УСЛОВИЕ (Тот самый выбор: Self настройки или обычные)
        local IsEspActive = IsSelf and Toggles.SelfEspEnabled.Value or Toggles.EspEnabled.Value

        if IsEspActive and Char and Hum and Hum.Health > 0 then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if Root then
                local Pos, OnS = Camera:WorldToViewportPoint(Root.Position)
                
                if OnS then
                    -- Расчеты размеров бокса
                    local Color = IsSelf and Options.SelfBoxCol.Value or GetEspColor(Player, Options.BoxColor.Value)
                    local SX = 2000 / Pos.Z
                    local SY = 3000 / Pos.Z
                    local BPos = Vector2.new(Pos.X - SX/2, Pos.Y - SY/2)
                    
                    -- [[ БОКС: FULL ИЛИ CORNERS ]]
                    local ShowBox = IsSelf and Toggles.SelfBox.Value or Toggles.BoxEnabled.Value
                    if ShowBox then
                        if not IsSelf and Options.BoxType.Value == "Corners" then
                            -- Логика отрисовки 8 линий для уголков
                            local L = SX / 4
                            local function draw(i, f, t)
                                local l = data.Corners[i]
                                l.Visible = true; l.From = f; l.To = t; l.Color = Color; l.Thickness = Options.BoxThickness.Value
                            end
                            -- Математика углов
                            draw(1, BPos, BPos + Vector2.new(L, 0)) -- Левый верх
                            draw(2, BPos, BPos + Vector2.new(0, L))
                            draw(3, BPos + Vector2.new(SX, 0), BPos + Vector2.new(SX - L, 0)) -- Правый верх
                            draw(4, BPos + Vector2.new(SX, 0), BPos + Vector2.new(SX, L))
                            draw(5, BPos + Vector2.new(0, SY), BPos + Vector2.new(L, SY)) -- Левый низ
                            draw(6, BPos + Vector2.new(0, SY), BPos + Vector2.new(0, SY - L))
                            draw(7, BPos + Vector2.new(SX, SY), BPos + Vector2.new(SX - L, SY)) -- Правый низ
                            draw(8, BPos + Vector2.new(SX, SY), BPos + Vector2.new(SX, SY - L))
                        else
                            -- Обычный полный бокс
                            data.Box.Visible = true
                            data.Box.Position = BPos
                            data.Box.Size = Vector2.new(SX, SY)
                            data.Box.Color = Color
                            data.Box.Thickness = Options.BoxThickness.Value
                        end
                    end
                    
                    -- [[ ТРЕЙСЕРЫ С ВЫБОРОМ ЦЕЛИ ]]
                    local ShowTracer = IsSelf and Toggles.SelfTracers.Value or Toggles.TracerEnabled.Value
                    if ShowTracer then
                        local TargetPart = Char:FindFirstChild(Options.TracerTarget.Value) or Root
                        local TPos = Camera:WorldToViewportPoint(TargetPart.Position)
                        local Origin = Options.TracerOrigin.Value
                        local FromPos = (Origin == 'Top' and Vector2.new(Camera.ViewportSize.X/2, 0)) or 
                                        (Origin == 'Center' and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)) or
                                        (Origin == 'Mouse' and UIS:GetMouseLocation()) or 
                                        Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        
                        data.Tracer.Visible = true
                        data.Tracer.From = FromPos
                        data.Tracer.To = Vector2.new(TPos.X, TPos.Y)
                        data.Tracer.Color = IsSelf and Options.SelfTracerCol.Value or GetEspColor(Player, Options.TracerColor.Value)
                    end
                    
                    -- [[ ТЕКСТ: ИМЯ И ДИСТАНЦИЯ ]]
                    local ShowText = IsSelf and Toggles.SelfText.Value or (Toggles.ShowName.Value or Toggles.ShowDist.Value)
                    if ShowText then
                        data.Name.Visible = true
                        data.Name.Text = IsSelf and "[ YOU ]" or Player.Name .. " [" .. math.floor(Pos.Z) .. "m]"
                        data.Name.Position = Vector2.new(Pos.X, BPos.Y - 16)
                    end

                    -- [[ CHAMS ]]
                    local ShowChams = IsSelf and Toggles.SelfChams.Value or Toggles.ChamsEnabled.Value
                    if ShowChams then
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
