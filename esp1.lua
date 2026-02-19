local AimlockModule = {}

-- Передаем все зависимости (Options, Toggles и т.д.) внутрь функции
function AimlockModule.Run(Options, Toggles, LP, Players, Camera, UIS)
    
    -- 1. Вспомогательная функция (теперь внутри модуля)
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

    -- 2. Логика проверки нажатия и поиска цели
    local AimKey = Options.AimKeybind.Value
    local IsPressed = (AimKey == 'MB2' and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or 
                      (AimKey == 'MB1' and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) or 
                      (pcall(function() return UIS:IsKeyDown(Enum.KeyCode[AimKey]) end) and UIS:IsKeyDown(Enum.KeyCode[AimKey]))
    
    if Toggles.AimEnabled and Toggles.AimEnabled.Value and IsPressed then
        local Target = nil
        local Closest = Options.FOVRadius.Value

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild(Options.AimPart.Value) then
                local Part = p.Character[Options.AimPart.Value]
                local pos, ons = Camera:WorldToViewportPoint(Part.Position)
                
                if ons and IsVisible(Part, p.Character) then
                    local dist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if dist < Closest then 
                        Target = p
                        Closest = dist 
                    end
                end
            end
        end
        
        if Target then 
            local TargetPart = Target.Character[Options.AimPart.Value]
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPart.Position), Options.AimSmooth.Value) 
        end
    end
end

return AimlockModule