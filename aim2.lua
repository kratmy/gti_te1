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
      -- Если у нас уже есть цель, проверяем, жива ли она еще
      if LockedTarget then
        local Char = LockedTarget.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        local Part = Char and Char:FindFirstChild(Options.AimPart.Value)
        local isAlive = true
          
        local visible = IsVisible(Part, Char)
          if not visible and Toggles.WallCheck and Toggles.WallCheck.Value then
            isAlive = false -- Просто используем этот триггер для сброса
          end
          
          -- Проверка: жив ли игрок, если включен Alive Check
          if Toggles.AliveCheck and Toggles.AliveCheck.Value and Hum then
            if Hum.Health <= 0 then isAlive = false end
          end
          
            if not Part or not Hum or not isAlive then
              LockedTarget = nil 
            end
        end

        -- Если цели нет, ищем новую
        if not LockedTarget then
          local Closest = Options.FOVRadius.Value
          local MousePos = UIS:GetMouseLocation()
          
          for _, p in pairs(Players:GetPlayers()) do
              if p ~= LP and p.Character and p.Character:FindFirstChild(Options.AimPart.Value) then
                  local Hum = p.Character:FindFirstChildOfClass("Humanoid")
                  local canTarget = true
                  local Part = p.Character:FindFirstChild(Options.AimPart.Value)
                  
                  if Toggles.AliveCheck and Toggles.AliveCheck.Value and Hum and Hum.Health <= 0 then
                      canTarget = false
                  end
                  
                  if canTarget and Part then
                      local pos, ons = Camera:WorldToViewportPoint(Part.Position)
                  
                      if ons and IsVisible(Part, p.Character) then
                          local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                          if dist < Closest then 
                              LockedTarget = p 
                              Closest = dist 
                          end
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
end

return AimlockModule






