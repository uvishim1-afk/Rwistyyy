-- TWISTED V6.3: RESTORED MASTER FRAMEWORK (WALL CHECK & VISUAL FOV)
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
    AimSmooth = 0, -- EDITED: Force smooth factor to 0 for instantaneous snapping
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

-- Fully Working Skybox Asset Arrays
local SKIES = {
    {N = "🌤 Default", Bk = "rbxassetid://91458024", Ft = "rbxassetid://91458024", Dn = "rbxassetid://91457980", Lf = "rbxassetid://91458024", Rt = "rbxassetid://91458024", Up = "rbxassetid://91458024"},
    {N = "🌌 Space", Bk = "rbxassetid://159454286", Ft = "rbxassetid://159454286", Dn = "rbxassetid://159454286", Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454286", Up = "rbxassetid://159454286"},
    {N = "🌅 Sunset", Bk = "rbxassetid://32584699", Ft = "rbxassetid://32584699", Dn = "rbxassetid://32584699", Lf = "rbxassetid://32584699", Rt = "rbxassetid://32584699", Up = "rbxassetid://32584699"},
    {N = "🔴 Apocalypse", Bk = "rbxassetid://358313209", Ft = "rbxassetid://358313209", Dn = "rbxassetid://358313209", Lf = "rbxassetid://358313209", Rt = "rbxassetid://358313209", Up = "rbxassetid://358313209"}
}

------------------------------------------------------------------------
-- CORE NATIVE INTERFACE & STATIC FOV SYSTEM
------------------------------------------------------------------------
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "TwistedV6"
Screen.IgnoreGuiInset = true 

-- Native UI FOV Ring Framework
local FOVCircle = Instance.new("ImageLabel", Screen)
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Image = "rbxassetid://12322420427" 
FOVCircle.ImageColor3 = Color3.fromRGB(140, 80, 255)
FOVCircle.ImageTransparency = 0.4
FOVCircle.Visible = Config.ShowFOVCircle

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
CreateToggleButton("Aimbot Wall Check", Config.WallCheck, function(s) Config.WallCheck = s end)
CreateToggleButton("Show FOV Ring", Config.ShowFOVCircle, function(s) Config.ShowFOVCircle = s; FOVCircle.Visible = s end)
CreateToggleButton("Active Triggerbot", Config.Triggerbot, function(s) Config.Triggerbot = s end)
CreateToggleButton("Master ESP System", Config.ESP, function(s) Config.ESP = s end)
CreateToggleButton("ESP Player Names", Config.ESPNames, function(s) Config.ESPNames = s end)
CreateToggleButton("ESP Wireframe Boxes", Config.ESPBoxes, function(s) Config.ESPBoxes = s end)

local fovBtn
fovBtn = CreateActionButton("Aimbot FOV Range (" .. Config.AimFOV .. ")", function()
    Config.AimFOV = Config.AimFOV + 50
    if Config.AimFOV > 350 then Config.AimFOV = 100 end
    fovBtn.Text = "Aimbot FOV Range (" .. Config.AimFOV .. ")"
    FOVCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
end)

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
    Config.Speed = Config.Speed + 20
    if Config.Speed > 150 then Config.Speed = 16 end
    speedBtn.Text = "Speed Modifier (" .. Config.Speed .. ")"
end)

local jumpBtn
jumpBtn = CreateActionButton("Jump Modifier (" .. Config.Jump .. ")", function()
    Config.Jump = Config.Jump + 25
    if Config.Jump > 250 then Config.Jump = 50 end
    jumpBtn.Text = "Jump Modifier (" .. Config.Jump .. ")"
end)

CreateActionButton("Reset Speed & Jump", function()
    Config.Speed = 16
    Config.Jump = 50
    speedBtn.Text = "Speed Modifier (16)"
    jumpBtn.Text = "Jump Modifier (50)"
end)

------------------------------------------------------------------------
-- UTILITY: POSITION ACCESSIBILITY & WALL CHECK CORES
------------------------------------------------------------------------
local function isPartVisible(targetPart, character)
    if not Config.WallCheck then return true end
    local ignoreList = {LocalPlayer.Character, character}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList

    local rayDirection = targetPart.Position - Camera.CFrame.Position
    local raycastResult = workspace:Raycast(Camera.CFrame.Position, rayDirection, raycastParams)
    
    if raycastResult then
        return false 
    end
    return true
end

local espBoxes = {}
local espNames = {}

local function cleanESP(p)
    if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
    if espNames[p] then espNames[p]:Destroy(); espNames[p] = nil end
end

------------------------------------------------------------------------
-- CORE REALTIME RENDERING LAYER RUNLOOP
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Character Property Anti-Reset Enforcement
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed ~= Config.Speed then hum.WalkSpeed = Config.Speed end
                if hum.JumpPower ~= Config.Jump then hum.JumpPower = Config.Jump end
                hum.UseJumpPower = true 
            end
        end
    end)

    -- Camera Aimbot Tracking Engine
    if Config.Aimbot then
        local target = nil
        local maxDist = Config.AimFOV
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mouseDist < maxDist then
                            if isPartVisible(p.Character.Head, p.Character) then
                                maxDist = mouseDist
                                target = p.Character.Head
                            end
                        end
                    end
                end
            end
        end
        if target then
            -- EDITED: Swapped out Lerp interpolation to force a hard, instant frame-snap alignment
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Precision Raycast Triggerbot
    if Config.Triggerbot and tick() - lastTriggerTime > Config.TriggerDelay then
        local centerScreen = Camera.ViewportSize / 2
        local unitRay = Camera:ViewportPointToRay(centerScreen.X, centerScreen.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
        if raycastResult and raycastResult.Instance then
            local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
            local targetPlayer = model and Players:GetPlayerFromCharacter(model)
            
            if targetPlayer and targetPlayer ~= LocalPlayer then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    if typeof(mouse1click) == "function" then
                        mouse1click()
                    else
                        mouse1press(); task.wait(); mouse1release()
                    end
                    lastTriggerTime = tick()
                end
            end
        end
    end

    -- Premium Upgrade ESP Processing Engine
    if Config.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
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
                            box.Transparency = 0.6
                            box.ZIndex = 6
                            box.Color3 = Color3.fromRGB(140, 80, 255)
                            espBoxes[p] = box
                        end
                        espBoxes[p].Adornee = hrp; espBoxes[p].Parent = hrp
                    else
                        if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
                    end

                    if Config.ESPNames then
                        if not espNames[p] then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "TwistedESPName"
                            bb.Size = UDim2.new(0, 160, 0, 40)
                            bb.AlwaysOnTop = true
                            bb.StudsOffset = Vector3.new(0, 3.5, 0)
                            
                            local label = Instance.new("TextLabel", bb)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 10
                            label.Text = p.Name
                            
                            espNames[p] = bb
                        end
                        espNames[p].Adornee = hrp; espNames[p].Parent = hrp
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
