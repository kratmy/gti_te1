-- [[ ЗАГРУЗКА БИБЛИОТЕКИ ]]
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- [[ СОЗДАНИЕ ОКНА ]]
local Window = Library:CreateWindow({
    Title = 'linoria7.lua | aimlock | wh',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Main = Window:AddTab('AimLock'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('Settings'),
}

-- [[ ГРУППЫ ИНТЕРФЕЙСА ]]
local AimLeft = Tabs.Main:AddLeftGroupbox('AimLock')
local AimRight = Tabs.Main:AddRightGroupbox('FOV & Checks')

local EspMain = Tabs.Visuals:AddLeftGroupbox('Visuals')
local EspColors = Tabs.Visuals:AddLeftGroupbox('Colors (Friend/Enemy)')
local EspBoxes = Tabs.Visuals:AddRightGroupbox('Boxes & HP')
local EspText = Tabs.Visuals:AddRightGroupbox('Text Settings')
local EspDetails = Tabs.Visuals:AddRightGroupbox('Extra Visuals')

local MiscGroup = Tabs.Misc:AddLeftGroupbox('Menu Management')

-- [[ НАПОЛНЕНИЕ: AIMBOT ]]
AimLeft:AddToggle('AimEnabled', { Text = 'Enabled', Default = false })
AimLeft:AddLabel('Aim keybind'):AddKeyPicker('AimKeybind', { 
    Default = 'MB2', 
    SyncToggleState = false, 
    Mode = 'Hold', 
    Text = 'Aimlock Keybind', 
    NoUI = false 
})
AimLeft:AddSlider('AimSmooth', { Text = 'Smoothness', Default = 0.7, Min = 0.01, Max = 1, Rounding = 2 })
AimLeft:AddDropdown('AimPart', { Values = { 'Head', 'UpperTorso', 'HumanoidRootPart' }, Default = 1, Text = 'Target Bone' })

AimRight:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = false }):AddColorPicker('FOVColor', { Default = Color3.fromRGB(255, 255, 255) })
AimRight:AddSlider('FOVRadius', { Text = 'Radius', Default = 150, Min = 10, Max = 800, Rounding = 0 })
AimRight:AddToggle('RainbowFOV', { Text = 'Rainbow FOV', Default = false })
AimRight:AddToggle('WallCheck', { Text = 'Wall Check', Default = false })

-- [[ НАПОЛНЕНИЕ: VISUALS ]]
EspMain:AddToggle('EspEnabled', { Text = 'Enabled', Default = false })
EspMain:AddDropdown('GlobalMode', { Values = { 'Static', 'Team Color', 'Friend/Enemy' }, Default = 1, Text = 'Color Mode' })
EspMain:AddToggle('GlobalRainbow', { Text = 'Global Rainbow ESP', Default = false })

EspColors:AddLabel('Friend Color'):AddColorPicker('FriendCol', { Default = Color3.fromRGB(0, 255, 0) })
EspColors:AddLabel('Enemy Color'):AddColorPicker('EnemyCol', { Default = Color3.fromRGB(222, 0, 0) })

EspBoxes:AddToggle('BoxEnabled', { Text = 'Draw Boxes', Default = false }):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255) })
EspBoxes:AddToggle('HealthBar', { Text = 'Health Bar', Default = false })
EspBoxes:AddDropdown('HealthBarSide', { Values = { 'Left', 'Right', 'Bottom' }, Default = 1, Text = 'HP Bar Side' })
EspBoxes:AddToggle('HealthOutline', { Text = 'HP Bar Outline', Default = true })

EspText:AddToggle('ShowName', { Text = 'Show Names', Default = false })
EspText:AddToggle('ShowDist', { Text = 'Show Distance', Default = false })
EspText:AddToggle('ShowHPText', { Text = 'Show HP Text', Default = false })

EspDetails:AddToggle('ChamsEnabled', { Text = 'Chams (Highlights)', Default = false }):AddColorPicker('ChamsColor', { Default = Color3.fromRGB(255, 255, 255) })
EspDetails:AddSlider('ChamsTransp', { Text = 'Transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 1 })
EspDetails:AddToggle('TracerEnabled', { Text = 'Tracers', Default = false }):AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 255, 255) })
EspDetails:AddDropdown('TracerOrigin', { Values = { 'Bottom', 'Center', 'Top', 'Mouse' }, Default = 1, Text = 'Origin' })

-- [[ СИСТЕМНЫЕ ПЕРЕМЕННЫЕ ]]
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Objects = {}
local Connections = {}

local FOV = Drawing.new("Circle")
FOV.Thickness = 1
FOV.NumSides = 64
FOV.Visible = false

-- Глобальная переменная для основного цикла
local MainRenderLoop = nil

-- [[ ФУНКЦИЯ ПОЛНОЙ ВЫГРУЗКИ ]]
local function Unload()
    -- 1. Сразу отключаем основной цикл отрисовки
    if MainRenderLoop then
        MainRenderLoop:Disconnect()
    end
    
    -- 2. Отключаем остальные события (PlayerAdded и т.д.)
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    
    -- 3. Удаляем FOV
    FOV.Visible = false
    FOV:Remove()
    
    -- 4. Перебор всех игроков и ФИЗИЧЕСКОЕ удаление ESP
    for player, data in pairs(Objects) do
        if data.Box then data.Box.Visible = false data.Box:Remove() end
        if data.Tracer then data.Tracer.Visible = false data.Tracer:Remove() end
        if data.Name then data.Name.Visible = false data.Name:Remove() end
        if data.Dist then data.Dist.Visible = false data.Dist:Remove() end
        if data.HPText then data.HPText.Visible = false data.HPText:Remove() end
        if data.HealthBar then data.HealthBar.Visible = false data.HealthBar:Remove() end
        if data.HealthOutline then data.HealthOutline.Visible = false data.HealthOutline:Remove() end
        if data.Highlight then data.Highlight:Destroy() end
    end
    
    -- 5. Очистка таблиц
    table.clear(Objects)
    table.clear(Connections)
    
    -- 6. Выгрузка меню
    Library:Unload()
end

MiscGroup:AddButton('Unload Script', Unload)
MiscGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightControl', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

-- [[ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]]
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

local function AddPlayer(P)
    if P == LP then return end
    
    local d = {}
    d.Box = Drawing.new("Square")
    d.Tracer = Drawing.new("Line")
    d.HealthOutline = Drawing.new("Line")
    d.HealthBar = Drawing.new("Line")
    d.Name = Drawing.new("Text")
    d.Dist = Drawing.new("Text")
    d.HPText = Drawing.new("Text")
    d.Highlight = Instance.new("Highlight")
    
    for _, txt in pairs({d.Name, d.Dist, d.HPText}) do
        txt.Center = true
        txt.Outline = true
        txt.Size = 14
        txt.Color = Color3.new(1, 1, 1)
        txt.Visible = false
    end
    
    d.Box.Visible = false
    d.Tracer.Visible = false
    d.HealthBar.Visible = false
    d.HealthOutline.Visible = false
    d.HealthOutline.Thickness = 3
    d.HealthOutline.Color = Color3.new(0, 0, 0)
    
    d.Highlight.Parent = game:GetService("CoreGui")
    d.Highlight.Enabled = false
    
    Objects[P] = d
end

local function RemovePlayer(P)
    if Objects[P] then
        local data = Objects[P]
        if data.Box then data.Box:Remove() end
        if data.Tracer then data.Tracer:Remove() end
        if data.Name then data.Name:Remove() end
        if data.Dist then data.Dist:Remove() end
        if data.HPText then data.HPText:Remove() end
        if data.HealthBar then data.HealthBar:Remove() end
        if data.HealthOutline then data.HealthOutline:Remove() end
        if data.Highlight then data.Highlight:Destroy() end
        Objects[P] = nil
    end
end

-- Инициализация игроков
for _, p in pairs(Players:GetPlayers()) do AddPlayer(p) end
table.insert(Connections, Players.PlayerAdded:Connect(AddPlayer))
table.insert(Connections, Players.PlayerRemoving:Connect(RemovePlayer))

-- [[ ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ ]]
MainRenderLoop = RS.RenderStepped:Connect(function()
    -- FOV ОБНОВЛЕНИЕ
    if Toggles.ShowFOV and Options.FOVRadius then
        FOV.Visible = Toggles.ShowFOV.Value
        FOV.Radius = Options.FOVRadius.Value
        FOV.Position = UIS:GetMouseLocation()
        if Toggles.RainbowFOV.Value then
            FOV.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            FOV.Color = Options.FOVColor.Value
        end
    end
    
    -- ESP ОБНОВЛЕНИЕ
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
    
    -- [[ AIMBOT LOGIC ]]
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
end)

-- [[ МЕНЕДЖЕРЫ ]]
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:BuildConfigSection(Tabs['UI Settings'])

Library.AccentColor = Color3.fromRGB(222, 0, 0)
Library:UpdateColorsUsingRegistry()