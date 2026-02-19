local baseUrl = "https://raw.githubusercontent.com/kratmy/gti_te1/main/"
local AimlockModule = loadstring(game:HttpGet(baseUrl .. "aim1.lua"))()
local EspModule = loadstring(game:HttpGet(baseUrl .. "esp1.lua"))() -- Загрузка ESP

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

-- [[ НАПОЛНЕНИЕ: AIMLOCK ]]
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
        EspModule.Run(Objects, Toggles, Options, LP, Camera) 
    end
    
    -- Вызов Aimlock модуля
    if AimlockModule and AimlockModule.Run then 
        AimlockModule.Run(Options, Toggles, LP, Players, Camera, UIS) 
    end
end)

-- [[ МЕНЕДЖЕРЫ ]]
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:BuildConfigSection(Tabs['UI Settings'])

Library.AccentColor = Color3.fromRGB(222, 0, 0)
Library:UpdateColorsUsingRegistry()
