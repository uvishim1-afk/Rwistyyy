-- TWISTED V6.7: STABLE BASE RESTORATION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Feature Configurations
local Config = {
    Aimbot = false, 
    AimStrength = 5,
    AimFOV = 150,
    WallCheck = true,
    ShowFOVCircle = false,
    Triggerbot = false,
    ESP = false, 
    ESPNames = true, 
    ESPBoxes = true,
    Speed = 16, 
    Jump = 50,
    SkyIndex = 1
}

-- Fully Working Skybox Asset Arrays
local SKIES = {
    {N = "🌤 Default", Bk = "rbxassetid://91458024", Ft = "rbxassetid://91458024", Dn = "rbxassetid://91457980", Lf = "rbxassetid://91458024", Rt = "rbxassetid://91458024", Up = "rbxassetid://91458024"},
    {N = "🌌 Space", Bk = "rbxassetid://159454286", Ft = "rbxassetid://159454286", Dn = "rbxassetid://159454286", Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454286", Up = "rbxassetid://159454286"},
    {N = "🌅 Sunset", Bk = "rbxassetid://32584699", Ft = "rbxassetid://32584699", Dn = "rbxassetid://32584699", Lf = "rbxassetid://32584699", Rt = "rbxassetid://32584699", Up = "rbxassetid://32584699"},
    {N = "🔴 Apocalypse", Bk = "rbxassetid://358313209", Ft = "rbxassetid://358313209", Dn = "rbxassetid://358313209", Lf = "rbxassetid://358313209", Rt = "rbxassetid://358313209", Up = "rbxassetid://358313209"}
}

------------------------------------------------------------------------
-- CORE INTERFACE
------------------------------------------------------------------------
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "TwistedV6"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 360)
Main.Position = UDim2.new(0.5, -130, 0.5, -180)
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
Title.Text = "   TWISTED V6.7 [RESTORED BASE]"
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
Container.CanvasSize = UDim2.new(0, 0, 0, 500)
Container.ScrollBarThickness = 2

local List = Instance.new("UIListLayout", Container)
List.Padding = UDim.new(0, 6)

------------------------------------------------------------------------
-- DYNAMIC INTERACTION BUTTON DESIGN
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
-- DRAW BUTTONS
------------------------------------------------------------------------
CreateToggleButton("Master ESP System", Config.ESP, function(s) Config.ESP = s end)
CreateToggleButton("ESP Player Names", Config.ESPNames, function(s) Config.ESPNames = s end)
CreateToggleButton("ESP Wireframe Boxes", Config.ESPBoxes, function(s) Config.ESPBoxes = s end)

local skyBtn
skyBtn = CreateActionButton("Skybox: 🌤 Default", function()
    Config.SkyIndex = (Config.SkyIndex % #SKIES) + 1
    local data = SKIES[Config.SkyIndex]
    skyBtn.Text = "Skybox: " .. data.N
    
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
    sky.SkyboxBk = data.Bk; sky.SkyboxDn = data.Dn; sky.SkyboxFt = data.Ft
    sky.SkyboxLf = data.Lf; sky.SkyboxRt = data.Rt; sky.SkyboxUp = data.Up
end)

local speedBtn
speedBtn = CreateActionButton("Speed Modifier (" .. Config.Speed .. ")", function()
    Config.Speed = Config.Speed + 15
    if Config.Speed > 120 then Config.Speed = 16 end
    speedBtn.Text = "Speed Modifier (" .. Config.Speed .. ")"
end)

local jumpBtn
jumpBtn = CreateActionButton("Jump Modifier (" .. Config.Jump .. ")", function()
    Config.Jump = Config.Jump + 15
    if Config.Jump > 200 then Config.Jump = 50 end
    jumpBtn.Text = "Jump Modifier (" .. Config.Jump .. ")"
end)

------------------------------------------------------------------------
-- ESP TRACKING CORE ENGINE
------------------------------------------------------------------------
local espBoxes = {}
local espNames = {}

local function cleanESP(p)
    if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
    if espNames[p] then espNames[p]:Destroy(); espNames[p] = nil end
end

RunService.RenderStepped:Connect(function()
    -- Native WalkSpeed / Jump Adjuster
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char.Humanoid
            hum.WalkSpeed = Config.Speed
            hum.JumpPower = Config.Jump
        end
    end)

    -- Stable ESP Process Loop
    if Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 then
                    if Config.ESPBoxes then
                        if not espBoxes[p] then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "TwistedESPBox"
                            box.Size = Vector3.new(4, 5.5, 1)
                            box.AlwaysOnTop = true
                            box.Transparency = 0.65
                            box.ZIndex = 6
                            box.Color3 = Color3.fromRGB(140, 80, 255)
                            espBoxes[p] = box
                        end
                        espBoxes[p].Adornee = hrp
                        espBoxes[p].Parent = hrp
                    else
                        if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
                    end

                    if Config.ESPNames then
                        if not espNames[p] then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "TwistedESPName"
                            bb.Size = UDim2.new(0, 160, 0, 40)
                            bb.AlwaysOnTop = true
                            bb.Value = Vector3.new(0, 3.5, 0)
                            
                            local label = Instance.new("TextLabel", bb)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 11
                            label.Text = p.Name
                            
                            espNames[p] = bb
                        end
                        espNames[p].Adornee = hrp
                        espNames[p].Parent = hrp
                    else
                        if espNames[p] then espNames[p]:Destroy(); espNames[p] = nil end
                    end
                else
                    cleanESP(p)
                end
            else
                cleanESP(p)
            end
        end
    else
        for p, _ in pairs(espBoxes) do cleanESP(p) end
    end
end)

Players.PlayerRemoving:Connect(cleanESP)
