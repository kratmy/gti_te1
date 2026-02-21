local baseUrl = "https://raw.githubusercontent.com/kratmy/gti_te1/main/"
--local files = _G.LunarisSettings

local AimlockModule = loadstring(game:HttpGet(baseUrl .. _G.LunarisLoader.aim))()
local EspModule = loadstring(game:HttpGet(baseUrl ..  _G.LunarisLoader.esp))()

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()


local Window = Library:CreateWindow({
    Title = 'lunarisV9.lua',
    Center = true,
    AutoShow = true,
    TabPadding = 8
    MenuFadeTime = 0.3
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

-- [[ НАПОЛНЕНИЕ AIMLOCK ]]
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

-- [[ НАПОЛНЕНИЕ VISUALS ]]
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

local MainRenderLoop = nil

-- [[ ФУНКЦИЯ ВЫГРУЗКИ ]]
local function Unload()
    if MainRenderLoop then
        MainRenderLoop:Disconnect()
    end
    
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    
    FOV.Visible = false
    FOV:Remove()
    
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
    
    table.clear(Objects)
    table.clear(Connections)
    
    Library:Unload()
end

MiscGroup:AddButton('Unload Script', Unload)
MiscGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightControl', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

-- [[ ЛОГИКА ОБЪЕКТОВ ESP ]]
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

-- Инициализация
for _, p in pairs(Players:GetPlayers()) do AddPlayer(p) end
table.insert(Connections, Players.PlayerAdded:Connect(AddPlayer))
table.insert(Connections, Players.PlayerRemoving:Connect(RemovePlayer))
MainRenderLoop = RS.RenderStepped:Connect(function()
    -- FOV ОБНОВЛЕНИЕ
    if Toggles.ShowFOV and Options.FOVRadius then
        FOV.Visible = Toggles.ShowFOV.Value
        FOV.Radius = Options.FOVRadius.Value
        FOV.Position = UIS:GetMouseLocation()
        
        if Toggles.RainbowFOV and Toggles.RainbowFOV.Value then
            FOV.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        elseif Options.FOVColor then
            FOV.Color = Options.FOVColor.Value
        end
    end
    
    -- Вызов ESP модуля
    if EspModule and EspModule.Run then 
        EspModule.Run(Objects, Toggles, Options, LP, Camera, UIS) 
    end
    
    -- Вызов Aimlock модуля
    if AimlockModule and AimlockModule.Run then 
        AimlockModule.Run(Options, Toggles, LP, Players, Camera, UIS) 
    end
end)

-- [[ МЕНЕДЖЕРЫ ]]
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('lunaris')
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:SetLibrary(Library)
SaveManager:SetFolder('lunaris/configs')
SaveManager:BuildConfigSection(Tabs['UI Settings'])

--игнор бинда меню
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

--цвит
Library.AccentColor = Color3.fromRGB(222, 0, 0)
Library:UpdateColorsUsingRegistry() 
task.spawn(function()
    task.wait(1)
    if Library.AccentColor ~= Color3.fromRGB(222, 0, 0) then
        Library.AccentColor = Color3.fromRGB(222, 0, 0)
        Library:UpdateColorsUsingRegistry()
    end
end)

SaveManager:LoadAutoloadConfig()





