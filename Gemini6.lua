-- TWISTED V6.3: RESTORED MASTER FRAMEWORK (WALL CHECK, TEAM CHECK & VECTOR FOV)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Feature Configurations
local Config = {
    Aimbot = false, 
    AimSmooth = 0, 
    AimFOV = 150,
    WallCheck = true,
    TeamCheck = true, -- EDITED: New team check toggle state configuration
    ShowFOVCircle = true,
    Triggerbot = false,
    TriggerDelay = 0.05,
    ESP = false, 
    ESPNames = true, 
    ESPBoxes = true,
    Speed = 16, 
    Jump = 50,
    SkyIndex = 1
}

local lastTriggerTime = 0

-- Fully Working Skybox Asset Arrays
local SKIES = {
    {N = "🌤 Default", Bk = "rbxassetid://91458024", Ft = "rbxassetid://91458024", Dn = "rbxassetid://91457980", Lf = "rbxassetid://91458024", Rt = "rbxassetid://91458024", Up = "rbxassetid://91458024"},
    {N = "🌌 Space", Bk = "rbxassetid://159454286", Ft = "rbxassetid://159454286", Dn = "rbxassetid://159454286", Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454286", Up = "rbxassetid://159454286"},
    {N = "🌅 Sunset", Bk = "rbxassetid://32584699", Ft = "rbxassetid://32584699", Dn = "rbxassetid://32584699", Lf = "rbxassetid://32584699", Rt = "rbxassetid://32584699", Up = "rbxassetid://32584699"},
    {N = "🔴 Apocalypse", Bk = "rbxassetid://358313209", Ft = "rbxassetid://358313209", Dn = "rbxassetid://358313209", Lf = "rbxassetid://358313209", Rt = "rbxassetid://358313209", Up = "rbxassetid://358313209"}
}

------------------------------------------------------------------------
-- CORE NATIVE INTERFACE & VECTOR FOV RENDERING SYSTEM
------------------------------------------------------------------------
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "TwistedV6"
Screen.IgnoreGuiInset = true 

-- EDITED: Ditched ImageLabels to kill the checkmark bug forever; using pure drawn vectors
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(140, 80, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

-- Main Menu Panel
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true 

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(140, 80, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 38)
Title.Text = "   TWISTED V6.3 [RESTORED RUNTIME]"
Title.TextColor3 = Color3.fromRGB(220, 200, 255)
Title.BackgroundColor3 = Color3.fromRGB(24, 18, 36)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -12, 1, -50)
Container.Position = UDim2.new(0, 6, 0, 44)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 560)
Container.ScrollBarThickness = 2

local List = Instance.new("UIListLayout", Container)
List.Padding = UDim.new(0, 6)

------------------------------------------------------------------------
-- INTERACTION DESIGN SYSTEM (DYNAMIC STATES)
------------------------------------------------------------------------
local function CreateToggleButton(titleText, initialValue, callback)
    local state = initialValue
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local function renderState()
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(120, 50, 220)
            btn.Text = titleText .. " : ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
            btn.Text = titleText .. " : OFF"
            btn.TextColor3 = Color3.fromRGB(180, 160, 200)
        end
    end
    renderState()
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        renderState()
        callback(state)
    end)
    return btn
end

local function CreateActionButton(text, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 210, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

------------------------------------------------------------------------
-- DRAWING ALL MENU ELEMENTS
------------------------------------------------------------------------
CreateToggleButton("Camera Aimbot", Config.Aimbot, function(s) Config.Aimbot = s end)
CreateToggleButton("Aimbot
