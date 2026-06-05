-- Save this directly over your GitHub file to fix the crash
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Twisted',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:CreateTab('Main'),
    Visuals = Window:CreateTab('Visuals'),
    ['UI Settings'] = Window:CreateTab('UI Settings'),
}

local LeftGroupBox = Tabs.Main:CreateLeftGroupbox('Aimbot')

LeftGroupBox:AddToggle('MyToggle', {
    Text = 'Aimbot',
    Default = false,
    Tooltip = 'Locks onto players',

    Callback = function(Value)
        _G.Aimbot = Value
    end
})

LeftGroupBox:AddSlider('MySlider', {
    Text = 'Smoothness',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        _G.Smoothness = Value
    end
})

local RightGroupBox = Tabs.Main:CreateRightGroupbox('Triggerbot')

RightGroupBox:AddToggle('TriggerbotToggle', {
    Text = 'Triggerbot',
    Default = false,
    Tooltip = 'Automatically shoots when hovering over a player',

    Callback = function(Value)
        _G.Triggerbot = Value
    end
})

RightGroupBox:AddSlider('TriggerbotDelay', {
    Text = 'Delay (ms)',
    Default = 0,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        _G.TriggerbotDelay = Value / 1000
    end
})

local VisualsLeftGroupBox = Tabs.Visuals:CreateLeftGroupbox('ESP Settings')

VisualsLeftGroupBox:AddToggle('ESPToggle', {
    Text = 'Enable ESP',
    Default = false,
    Tooltip = 'Shows players through walls',

    Callback = function(Value)
        _G.ESP = Value
    end
})

VisualsLeftGroupBox:AddToggle('ESPNames', {
    Text = 'Show Names',
    Default = false,

    Callback = function(Value)
        _G.ESPNames = Value
    end
})

VisualsLeftGroupBox:AddToggle('ESPBoxes', {
    Text = 'Show Boxes',
    Default = false,

    Callback = function(Value)
        _G.ESPBoxes = Value
    end
})

local VisualsRightGroupBox = Tabs.Visuals:CreateRightGroupbox('Environment Settings')

VisualsRightGroupBox:AddDropdown('SkyboxDropdown', {
    Values = {'Default', 'Purple Nebula', 'Deep Space', 'Sunset', 'Apocalypse'},
    Default = 1,
    Multi = false,
    Text = 'Skybox Changer',
    Tooltip = 'Changes the map skybox',

    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        
        if Value == 'Default' then
            sky.SkyboxBk = "rbxassetid://91458024"
            sky.SkyboxDn = "rbxassetid://91457980"
            sky.SkyboxFt = "rbxassetid://91458024"
            sky.SkyboxLf = "rbxassetid://91458024"
            sky.SkyboxRt = "rbxassetid://91458024"
            sky.SkyboxUp = "rbxassetid://91458024"
        elseif Value == 'Purple Nebula' then
            sky.SkyboxBk = "rbxassetid://159454286"
            sky.SkyboxDn = "rbxassetid://159454286"
            sky.SkyboxFt = "rbxassetid://159454286"
            sky.SkyboxLf = "rbxassetid://159454286"
            sky.SkyboxRt = "rbxassetid://159454286"
            sky.SkyboxUp = "rbxassetid://159454286"
        elseif Value == 'Deep Space' then
            sky.SkyboxBk = "rbxassetid://252760981"
            sky.SkyboxDn = "rbxassetid://252763665"
            sky.SkyboxFt = "rbxassetid://252761439"
            sky.SkyboxLf = "rbxassetid://252762331"
            sky.SkyboxRt = "rbxassetid://252762773"
            sky.SkyboxUp = "rbxassetid://252763261"
        elseif Value == 'Sunset' then
            sky.SkyboxBk = "rbxassetid://32584699"
            sky.SkyboxDn = "rbxassetid://32584699"
            sky.SkyboxFt = "rbxassetid://32584699"
            sky.SkyboxLf = "rbxassetid://32584699"
            sky.SkyboxRt = "rbxassetid://32584699"
            sky.SkyboxUp = "rbxassetid://32584699"
        elseif Value == 'Apocalypse' then
            sky.SkyboxBk = "rbxassetid://358313209"
            sky.SkyboxDn = "rbxassetid://358313209"
            sky.SkyboxFt = "rbxassetid://358313209"
            sky.SkyboxLf = "rbxassetid://358313209"
            sky.SkyboxRt = "rbxassetid://358313209"
            sky.SkyboxUp = "rbxassetid://358313209"
        end
    end
})

local MiscGroupBox = Tabs.Main:CreateLeftGroupbox('Movement')

MiscGroupBox:AddSlider('WalkSpeedSlider', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        _G.WalkSpeed = Value
    end
})

MiscGroupBox:AddSlider('JumpPowerSlider', {
    Text = 'JumpPower',
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        _G.JumpPower = Value
    end
})

-- Functional Backends
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function getClosestPlayer()
    local closest, maxDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < maxDist then closest = p.Character.Head; maxDist = dist end
            end
        end
    end
    return closest
end

local espBoxes = {}
local espNames = {}

local function createESP(p)
    if espBoxes[p] or espNames[p] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5.5, 1)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(140, 80, 255)
    box.Transparency = 0.5
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = p.Name

    espBoxes[p] = box
    espNames[p] = billboard
end

local function removeESP(p)
    if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
    if espNames[p] then espNames[p]:Destroy(); espNames[p] = nil end
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.WalkSpeed then hum.WalkSpeed = _G.WalkSpeed end
        if _G.JumpPower then hum.JumpPower = _G.JumpPower end
    end

    if _G.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target then
            local smooth = _G.Smoothness or 1
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 / smooth)
        end
    end

    if _G.Triggerbot and tick() - _G.lastTriggerTime > (_G.TriggerbotDelay or 0) then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local res = workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if res and res.Instance then
            local model = res.Instance:FindFirstAncestorOfClass("Model")
            local hitP = model and Players:GetPlayerFromCharacter(model)
            if hitP and hitP ~= LocalPlayer then
                if typeof(mouse1click) == "function" then mouse1click() else mouse1press(); task.wait(); mouse1release() end
                _G.lastTriggerTime = tick()
            end
        end
    end

    if _G.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                createESP(p)
                local hrp = p.Character.HumanoidRootPart
                if espBoxes[p] then
                    espBoxes[p].Adornee = hrp
                    espBoxes[p].Parent = _G.ESPBoxes and hrp or nil
                end
                if espNames[p] then
                    espNames[p].Adornee = hrp
                    espNames[p].Parent = _G.ESPNames and hrp or nil
                end
            else
                removeESP(p)
            end
        end
    else
        for p, _ in pairs(espBoxes) do removeESP(p) end
    end
end)

_G.lastTriggerTime = tick()

Players.PlayerRemoving:Connect(removeESP)

-- Theme and Save Managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor' })
ThemeManager:SetFolder('TwistedMenu')
SaveManager:SetFolder('TwistedMenu/Config')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

------------------------------------------------------------------------
-- THE CRITICAL STABILITY PATCH
------------------------------------------------------------------------
-- FIX: Changed from unyielded while loop to a safe Background Task Thread
task.spawn(function()
    while true do
        task.wait(0.2) -- Safe execution yield stops the mobile executor from freezing
        if Library.Unloaded then break end
    end
end)
