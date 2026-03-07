local AimlockModule = {}

local LockedTarget = nil

function AimlockModule.Run(Options, Toggles, LP, Players, Camera, UIS)
    local function IsVisible(Part, Char)
        if not Toggles.WallCheck or not Toggles.WallCheck.Value then 
            return true 
        end
        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Exclude
        Params.FilterDescendantsInstances = {LP.Character, Char, Camera}
        local Res = workspace:Raycast(Camera.CFrame.Position, (Part.Position - Camera.CFrame.Position).Unit * 500, Params)
        return Res == nil
    end

    local AimKey = Options.AimKeybind.Value
    local IsPressed = (AimKey == 'MB2' and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or 
                      (AimKey == 'MB1' and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) or 
                      (pcall(function() return UIS:IsKeyDown(Enum.KeyCode[AimKey]) end) and UIS:IsKeyDown(Enum.KeyCode[AimKey]))
    
    if Toggles.AimEnabled and Toggles.AimEnabled.Value and IsPressed then
        local Target = nil
        local Closest = Options.FOVRadius.Value
if Toggles.AimEnabled and Toggles.AimEnabled.Value and IsPressed then
        -- Если у нас уже есть цель, проверяем, жива ли она еще
        if LockedTarget then
            if not LockedTarget.Character or not LockedTarget.Character:FindFirstChild(Options.AimPart.Value) or not LockedTarget.Character:FindFirstChildOfClass("Humanoid") or LockedTarget.Character.Humanoid.Health <= 0 then
                LockedTarget = nil -- Сбрасываем, если цель умерла или вышла из игры
            end
        end

        -- Если цели нет, ищем новую
        if not LockedTarget then
            local Closest = Options.FOVRadius.Value
            local MousePos = UIS:GetMouseLocation()

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild(Options.AimPart.Value) then
                    local Part = p.Character[Options.AimPart.Value]
                    local pos, ons = Camera:WorldToViewportPoint(Part.Position)
                    
                    if ons and IsVisible(Part, p.Character) then
                        local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if dist < Closest then 
                            LockedTarget = p -- Фиксируем цель
                            Closest = dist 
                        end
                    end
                end
            end
        end
        
        -- Если цель зафиксирована (старая или новая), наводимся
        if LockedTarget then 
            local TargetPart = LockedTarget.Character[Options.AimPart.Value]
            local LookAt = CFrame.new(Camera.CFrame.Position, TargetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(LookAt, Options.AimSmooth.Value) 
        end
    else
        LockedTarget = nil -- Сбрасываем цель, когда отпускаем кнопку
    end
        
        if Target then 
            local TargetPart = Target.Character[Options.AimPart.Value]
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPart.Position), Options.AimSmooth.Value) 
        end
    end
end

return AimlockModule


