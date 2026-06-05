-- TWISTED V6.5: FINAL POLISH (FIXED FOV & HEARTBEAT SPEED)
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
    AimSmooth = 0, -- 0 = Instant Snap
    AimFOV = 150,
    WallCheck = true,
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

-- Skybox Data
local SKIES = {
    {N = "🌤 Default", Bk = "rbxassetid://91458024", Ft = "rbxassetid://91458024", Dn = "rbxassetid://91457980", Lf = "rbxassetid://91458024", Rt = "rbxassetid://91458024", Up = "rbxassetid://91458024"},
    {N = "🌌 Space", Bk = "rbxassetid://159454286", Ft = "rbxassetid://159454286", Dn = "rbxassetid://159454286", Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454286", Up = "rbxassetid://159454286"},
    {N = "🌅 Sunset", Bk = "rbxassetid://32584699", Ft = "rbxassetid://32584699", Dn = "rbxassetid://32584699", Lf = "rbxassetid://32584699", Rt = "rbxassetid://32584699", Up = "rbxassetid://32584699"},
    {N = "🔴 Apocalypse", Bk = "rbxassetid://358313209", Ft = "rbxassetid://358313209", Dn = "rbxassetid://358313209", Lf = "rbxassetid://358313209", Rt = "rbxassetid://358313209", Up = "rbxassetid://358313209"}
}

------------------------------------------------------------------------
-- UI SYSTEM
------------------------------------------------------------------------
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "TwistedV6"
Screen.IgnoreGuiInset = true 

-- FIXED FOV RING (Actually a circle this time!)
local FOVCircle = Instance.new("ImageLabel", Screen)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Image = "rbxassetid://6921370141" -- Clean Hollow Circle Asset
FOVCircle.ImageColor3 = Color3.fromRGB(140, 80, 255)
FOVCircle.ImageTransparency = 0.5
FOVCircle.Visible = Config.ShowFOVCircle

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
Main.Active = true
Main.Draggable = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(140, 80, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 38)
Title.Text = "   TWISTED V6.5 [FIXED]"
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
Container.CanvasSize = UDim2.new(0, 0, 0, 580)
Container.ScrollBarThickness = 0

local List = Instance.new("UIListLayout", Container)
List.Padding = UDim.new(0, 6)

-- Component Helpers
local function CreateToggle(txt, val, cb)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    Instance.new("UICorner", btn)
    
    local function update()
        btn.Text = txt .. (val and " : ON" or " : OFF")
        btn.BackgroundColor3 = val and Color3.fromRGB(120, 50, 220) or Color3.fromRGB(30, 25, 40)
        btn.TextColor3 = val and Color3.new(1,1,1) or Color3.fromRGB(180, 160, 200)
    end
    
    btn.MouseButton1Click:Connect(function() val = not val update() cb(val) end)
    update()
end

local function CreateAction(txt, cb)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = txt
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(cb)
    return btn
end

------------------------------------------------------------------------
-- SETUP BUTTONS
------------------------------------------------------------------------
CreateToggle("Aimbot", Config.Aimbot, function(s) Config.Aimbot = s end)
CreateToggle("Wall Check", Config.WallCheck, function(s) Config.WallCheck = s end)
CreateToggle("FOV Circle", Config.ShowFOVCircle, function(s) Config.ShowFOVCircle = s FOVCircle.Visible = s end)
CreateToggle("Triggerbot", Config.Triggerbot, function(s) Config.Triggerbot = s end)
CreateToggle("ESP Master", Config.ESP, function(s) Config.ESP = s end)

local fovBtn = CreateAction("FOV Size: " .. Config.AimFOV, function()
    Config.AimFOV = (Config.AimFOV >= 350) and 100 or Config.AimFOV + 50
    fovBtn.Text = "FOV Size: " .. Config.AimFOV
    FOVCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
end)

local speedBtn = CreateAction("Speed: " .. Config.Speed, function()
    Config.Speed = (Config.Speed >= 150) and 16 or Config.Speed + 20
    speedBtn.Text = "Speed: " .. Config.Speed
end)

------------------------------------------------------------------------
-- LOGIC ENGINE
------------------------------------------------------------------------
local espBoxes = {}

RunService.Heartbeat:Connect(function()
    -- Character Enforcement
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Config.Speed
        hum.JumpPower = Config.Jump
    end

    -- Aimbot
    if Config.Aimbot then
        local target, lowDist = nil, Config.AimFOV
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if p.Character.Humanoid.Health > 0 then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag < lowDist then
                            -- Simple Wall Check
                            local ray = workspace:Raycast(Camera.CFrame.Position, (p.Character.Head.Position - Camera.CFrame.Position).Unit * 500, RaycastParams.new())
                            if not Config.WallCheck or (ray and ray.Instance:IsDescendantOf(p.Character)) then
                                lowDist = mag; target = p.Character.Head
                            end
                        end
                    end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end

    -- ESP
    if Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if not espBoxes[p] then
                    local b = Instance.new("BoxHandleAdornment", hrp)
                    b.Size = Vector3.new(4, 5, 1); b.AlwaysOnTop = true; b.ZIndex = 5
                    b.Color3 = Color3.new(0.5, 0, 1); b.Transparency = 0.5; b.Adornee = hrp
                    espBoxes[p] = b
                end
            end
        end
    end
end)
