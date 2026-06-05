-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

------------------------------------------------------------------------
-- ENGINE STATE MANAGEMENT
------------------------------------------------------------------------
local espObjects = {}
local globalESP = false
local espIgnoreTeam = true
local boxColor = Color3.fromRGB(160, 80, 255)
local teamBoxColor = Color3.fromRGB(50, 255, 100)
local maxDistance = 600
local showNames = true
local showHealth = true
local showDistance = true

local aimEnabled = false
local aimIgnoreTeam = true
local aimSmoothness = 0.15
local aimFOV = 150

local triggerEnabled = false
local triggerIgnoreTeam = true
local triggerDelay = 0.05
local lastTriggerTime = 0

local walkSpeedModifier = 16
local jumpPowerModifier = 50

local SKYBOX_PRESETS = {
    {Name = "🌤 Default", Bk = "rbxassetid://91458024", Dn = "rbxassetid://91457980", Ft = "rbxassetid://91458024", Lf = "rbxassetid://91458024", Rt = "rbxassetid://91458024", Up = "rbxassetid://91458024", Stars = 3000, Celestial = true},
    {Name = "🌌 Deep Space", Bk = "rbxassetid://159454286", Dn = "rbxassetid://159454286", Ft = "rbxassetid://159454286", Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454286", Up = "rbxassetid://159454286", Stars = 10000, Celestial = false},
    {Name = "🌅 Sunset", Bk = "rbxassetid://32584699", Dn = "rbxassetid://32584699", Ft = "rbxassetid://32584699", Lf = "rbxassetid://32584699", Rt = "rbxassetid://32584699", Up = "rbxassetid://32584699", Stars = 0, Celestial = true},
    {Name = "🔴 Apocalypse", Bk = "rbxassetid://358313209", Dn = "rbxassetid://358313209", Ft = "rbxassetid://358313209", Lf = "rbxassetid://358313209", Rt = "rbxassetid://358313209", Up = "rbxassetid://358313209", Stars = 0, Celestial = false},
    {Name = "❄️ Arctic", Bk = "rbxassetid://159195142", Dn = "rbxassetid://159195142", Ft = "rbxassetid://159195142", Lf = "rbxassetid://159195142", Rt = "rbxassetid://159195142", Up = "rbxassetid://159195142", Stars = 500, Celestial = true}
}
local currentSkyIndex = 1

local function isSameTeam(pA, pB)
    if not pA or not pB then return false end
    return pA.Team ~= nil and pA.Team == pB.Team
end

------------------------------------------------------------------------
-- CORE MOBILE NAVIGATION ENGINE
------------------------------------------------------------------------
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "TwistedUnifiedMenu"
menuGui.ResetOnSpawn = false
menuGui.DisplayOrder = 999
menuGui.IgnoreGuiInset = true
menuGui.Parent = LocalPlayer.PlayerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
toggleBtn.TextColor3 = Color3.fromRGB(200, 160, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 10
toggleBtn.Text = "🌀\nMENU"
toggleBtn.Active = true
toggleBtn.ZIndex = 1000
toggleBtn.Parent = menuGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 14)
local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(140, 80, 255)
btnStroke.Thickness = 2

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 290, 0, 420)
menuFrame.Position = UDim2.new(0.5, -145, 0.5, -210)
menuFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
menuFrame.Visible = true
menuFrame.Active = true
menuFrame.ZIndex = 10
menuFrame.Parent = menuGui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 16)
local frameStroke = Instance.new("UIStroke", menuFrame)
frameStroke.Color = Color3.fromRGB(100, 50, 220)
frameStroke.Thickness = 2

local dragging, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = toggleBtn.Position
    end
end)
menuFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y < menu
