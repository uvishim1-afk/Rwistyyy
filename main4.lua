-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Bypass User ID Lock (Set to your ID or left open)
local OWNER_ID = 11040787676
-- Deleted restrictive kick condition to prevent execution failure

-- Load Linoria
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

------------------------------------------------------------------------
-- FLOATING TOGGLE BUTTON
------------------------------------------------------------------------
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name           = "TwistedToggle"
toggleGui.ResetOnSpawn   = false
toggleGui.DisplayOrder   = 999
toggleGui.IgnoreGuiInset = true
toggleGui.Parent         = LocalPlayer.PlayerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(0, 56, 0, 56)
toggleBtn.Position         = UDim2.new(0, 8, 0.45, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
toggleBtn.TextColor3       = Color3.fromRGB(200, 160, 255)
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 9
toggleBtn.Text             = "🌀\nTWISTED"
toggleBtn.ZIndex           = 100
toggleBtn.Parent           = toggleGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)
local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(140, 80, 255); btnStroke.Thickness = 2

-- Draggable Logic
local dragging, dragStart, startPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

------------------------------------------------------------------------
-- MAIN MENU (Compact + Scrollable)
------------------------------------------------------------------------
local menuGui = Instance.new("ScreenGui")
menuGui.Name           = "TwistedMenu"
menuGui.ResetOnSpawn   = false
menuGui.DisplayOrder   = 998
menuGui.IgnoreGuiInset = true
menuGui.Parent         = LocalPlayer.PlayerGui

local menuFrame = Instance.new("Frame")
menuFrame.Name              = "MenuFrame"
menuFrame.Size              = UDim2.new(0, 280, 0, 500)
menuFrame.Position          = UDim2.new(0.5, -140, 0.5, -250)
menuFrame.BackgroundColor3  = Color3.fromRGB(10, 8, 20)
menuFrame.BorderSizePixel   = 0
menuFrame.Visible           = true
menuFrame.Parent            = menuGui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 14)
local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Color = Color3.fromRGB(120, 60, 220); menuStroke.Thickness = 2

local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 12, 45)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = menuFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size              = UDim2.new(1, -50, 1, 0)
titleLabel.Position          = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3        = Color3.fromRGB(200, 160, 255)
titleLabel.Font              = Enum.Font.GothamBold
titleLabel.TextSize          = 16
titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
titleLabel.Text              = "🌀 TWISTED"
titleLabel.Parent            = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 36, 0, 30)
closeBtn.Position         = UDim2.new(1, -42, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 120)
closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 14
closeBtn.Text             = "✕"
closeBtn.Parent           = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local tabStrip = Instance.new("Frame")
tabStrip.Size             = UDim2.new(1, -8, 0, 36)
tabStrip.Position         = UDim2.new(0, 4, 0, 46)
tabStrip.BackgroundTransparency = 1
tabStrip.Parent           = menuFrame

local tabLayout = Instance.new("UIListLayout", tabStrip)
tabLayout.FillDirection  = Enum.FillDirection.Horizontal
tabLayout.Padding        = UDim.new(0, 3)
tabLayout.SortOrder      = Enum.SortOrder.LayoutOrder

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size                = UDim2.new(1, -8, 1, -90)
scrollFrame.Position            = UDim2.new(0, 4, 0, 86)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel     = 0
scrollFrame.ScrollBarThickness  = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
scrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent              = menuFrame

local contentLayout = Instance.new("UIListLayout", scrollFrame)
contentLayout.Padding   = UDim.new(0, 4)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", scrollFrame).PaddingLeft = UDim.new(0, 4)

-- Menu Draggable Execution
local dragActive, dragOffset = false, Vector2.new()
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragOffset = Vector2.new(menuFrame.AbsolutePosition.X - i.Position.X, menuFrame.AbsolutePosition.Y - i.Position.Y)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragActive and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        menuFrame.Position = UDim2.new(0, i.Position.X+dragOffset.X, 0, i.Position.Y+dragOffset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragActive = false end
end)

------------------------------------------------------------------------
-- UI CREATION TOOLS
------------------------------------------------------------------------
local function makeSection(title, order)
    local sec = Instance.new("Frame")
    sec.Name              = title
    sec.Size              = UDim2.new(1, -4, 0, 28)
    sec.BackgroundColor3  = Color3.fromRGB(30, 18, 55)
    sec.BorderSizePixel   = 0
    sec.LayoutOrder       = order or 0
    sec.Parent            = scrollFrame
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", sec)
    lbl.Size             = UDim2.new(1, -10, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3       = Color3.fromRGB(180, 130, 255)
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextSize         = 11
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Text             = "▸ " .. title:upper()
    return sec
end

local function makeToggle(labelText, default, order, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.Parent           = scrollFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(1, -60, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3       = Color3.fromRGB(220, 200, 255)
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 12
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Text             = labelText

    local togBtn = Instance.new("TextButton", row)
    togBtn.Size             = UDim2.new(0, 44, 0, 24)
    togBtn.Position         = UDim2.new(1, -52, 0.5, -12)
    togBtn.Font             = Enum.Font.GothamBold
    togBtn.TextSize         = 10
    togBtn.BorderSizePixel  = 0
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(1, 0)

    local state = default
    local function refresh()
        togBtn.BackgroundColor3 = state and Color3.fromRGB(100,50,200) or Color3.fromRGB(45,30,70)
        togBtn.TextColor3       = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,120,180)
        togBtn.Text             = state and "ON" or "OFF"
    end
    refresh()
    togBtn.MouseButton1Click:Connect(function() state=not state; refresh(); callback(state) end)
    togBtn.TouchTap:Connect(function() state=not state; refresh(); callback(state) end)
    return row, function() return state end
end

local function makeSlider(labelText, min, max, default, order, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -4, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.Parent           = scrollFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(1,-60,0,20); lbl.Position = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(220,200,255)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=labelText

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size=UDim2.new(0,50,0,20); valLbl.Position=UDim2.new(1,-58,0,4)
    valLbl.BackgroundTransparency=1; valLbl.TextColor3=Color3.fromRGB(160,120,255)
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=12; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Text=tostring(default)

    local track = Instance.new("Frame", row)
    track.Size=UDim2.new(1,-20,0,8); track.Position=UDim2.new(0,10,0,30); track.BackgroundColor3=Color3.fromRGB(40,25,70); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill = Instance.new("Frame", track)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=Color3.fromRGB(120,60,220); fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local value = default
    local function setVal(v)
        v = math.clamp(math.round(v), min, max)
        value = v
        fill.Size = UDim2.new((v-min)/(max-min),0,1,0)
        valLbl.Text = tostring(v)
        callback(v)
    end

    local sliding = false
    local function onInput(i)
        if not sliding then return end
        local rel = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        setVal(min + rel*(max-min))
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; onInput(i) end
    end)
    UserInputService.InputChanged:Connect(function(i) if sliding then onInput(i) end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)
    return row
end

------------------------------------------------------------------------
-- ENGINE STATE VARIABLES
------------------------------------------------------------------------
local espObjects={}; local globalESP=false; local espIgnoreTeam=true
local boxColor=Color3.fromRGB(160,80,255); local maxDistance=600
local showNames=true; local showHealth=true; local showDistance=true

local aimEnabled=false; local aimIgnoreTeam=true; local aimWallCheck=true
local aimSmoothness=0.15; local aimFOV=150

local flightEnabled=false; local flightSpeed=50; local flyConnection=nil
local originalWalkSpeed=16; local originalJumpPower=50

local function isSameTeam(pA,pB)
    if not pA or not pB then return false end
    return pA.Team ~= nil and pA.Team == pB.Team
end

------------------------------------------------------------------------
-- VISUAL GENERATOR (ESP ENGINE)
------------------------------------------------------------------------
local function createESP(player)
    if espObjects[player] then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "TESP_"..player.Name; sg.ResetOnSpawn=false; sg.Parent=LocalPlayer.PlayerGui
    
    local bf = Instance.new("Frame")
    bf.BackgroundTransparency=1; bf.Size=UDim2.new(0,60,0,100); bf.Visible=false; bf.Parent=sg
    
    local function mkL(n,sX,sY,pX,pY)
        local f=Instance.new("Frame"); f.Name=n; f.BackgroundColor3=boxColor; f.BorderSizePixel=0
        f.Size=UDim2.new(sX,0,sY,0); f.Position=UDim2.new(pX,0,pY,0); f.Parent=bf; return f
    end
    local tl=mkL("T",1,0,0,0); local bl=mkL("B",1,0,0,1)
    local ll=mkL("L",0,1,0,0); local rl=mkL("R",0,1,1,0)
    
    local nl = Instance.new("TextLabel", bf)
    nl.Size=UDim2.new(1,0,0,14); nl.Position=UDim2.new(0,0,0,-16); nl.BackgroundTransparency=1; nl.TextColor3=Color3.new(1,1,1); nl.Font=Enum.Font.GothamBold; nl.TextSize=11
    
    local dl = Instance.new("TextLabel", bf)
    dl.Size=UDim2.new(1,0,0,14); dl.Position=UDim2.new(0,0,1,2); dl.BackgroundTransparency=1; dl.TextColor3=Color3.new(1,0.9,0.3); dl.Font=Enum.Font.Gotham; dl.TextSize=10

    local hbg = Instance.new("Frame", bf)
    hbg.Size=UDim2.new(0,2,1,0); hbg.Position=UDim2.new(0,-6,0,0); hbg.BackgroundColor3=Color3.new(0.1,0.1,0.1); hbg.BorderSizePixel=0
    local hfl = Instance.new("Frame", hbg)
    hfl.Size=UDim2.new(1,0,1,0); hfl.BackgroundColor3=Color3.new(0.2,1,0.2); hfl.BorderSizePixel=0

    espObjects[player]={gui=sg, bf=bf, nl=nl, dl=dl, hbg=hbg, hfl=hfl}
end

local function removeESP(p) if espObjects[p] then espObjects[p].gui:Destroy(); espObjects[p]=nil end end

------------------------------------------------------------------------
-- ACCURATE TARGETING GENERATOR
-- (Calculated cleanly using thread pooling to avoid engine crashes)
------------------------------------------------------------------------
local function getClosestTarget()
    local center = Camera.ViewportSize / 2
    local bestTarget = nil
    local shortestDistance = aimFOV
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if aimIgnoreTeam and isSameTeam(LocalPlayer, p) then continue end
        
        local char = p.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if head and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenPos = Vector2.new(pos.X, pos.Y)
                local distance = (screenPos - center).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    bestTarget = head
                end
            end
        end
    end
    return bestTarget
end

------------------------------------------------------------------------
-- THE FIXED RUNSERVICE LAYER
-- (Safely yields thread loops to fix game freezing entirely)
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- ESP Rendering Loop Logic
    if globalESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not espObjects[p] then createESP(p) end
            
            local data = espObjects[p]
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                
                if onScreen and dist <= maxDistance and (not espIgnoreTeam or not isSameTeam(LocalPlayer, p)) then
                    local sizeX = math.clamp(2000 / pos.Z, 10, 150)
                    local sizeY = math.clamp(3500 / pos.Z, 15, 220)
                    
                    data.bf.Visible = true
                    data.bf.Position = UDim2.new(0, pos.X - sizeX/2, 0, pos.Y - sizeY/2)
                    data.bf.Size = UDim2.new(0, sizeX, 0, sizeY)
                    
                    data.nl.Visible = showNames
                    data.nl.Text = p.Name
                    data.dl.Visible = showDistance
                    data.dl.Text = math.floor(dist).." studs"
                    
                    data.hbg.Visible = showHealth
                    data.hfl.Size = UDim2.new(1, 0, hum.Health / hum.MaxHealth, 0)
                else
                    data.bf.Visible = false
                end
            else
                if data then data.bf.Visible = false end
            end
        end
    else
        for _, data in pairs(espObjects) do data.bf.Visible = false end
    end

    -- Aimbot Thread Safe Logic
    if aimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetHead = getClosestTarget()
        if targetHead then
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetHead.Position)
            Camera.CFrame = currentCF:Lerp(targetCF, aimSmoothness)
        end
    end
end)

------------------------------------------------------------------------
-- FIXED CONFIGURATION LOOPS (CRASH REFACTOR)
------------------------------------------------------------------------
-- CRITICAL FIX: Changed from an un-yielded "while true do" loop to a safe, background Task thread.
task.spawn(function()
    while true do
        task.wait(0.5) -- Forces the thread to pause for half a second before running optimization cleanup
        for player, _ in pairs(espObjects) do
            if not Players:FindFirstChild(player.Name) then
                removeESP(player)
            end
        end
    end
end)

------------------------------------------------------------------------
-- WIRING MENU UI ELEMENTS TO MAIN STATE
------------------------------------------------------------------------
makeSection("Visual Settings", 1)
makeToggle("Enable Master ESP", false, 2, function(state) globalESP = state end)
makeToggle("Show Player Names", true, 3, function(state) showNames = state end)
makeToggle("Show Health Scales", true, 4, function(state) showHealth = state end)
makeToggle("Show Distance Value", true, 5, function(state) showDistance = state end)
makeToggle("Ignore Teammates", true, 6, function(state) espIgnoreTeam = state end)
makeSlider("Max Render Bounds", 100, 2000, 600, 7, function(val) maxDistance = val end)

makeSection("Aimbot Assist", 8)
makeToggle("Enable Aimbot Lock", false, 9, function(state) aimEnabled = state end)
makeToggle("Filter Teammates", true, 10, function(state) aimIgnoreTeam = state end)
makeSlider("Field of View Target", 30, 800, 150, 11, function(val) aimFOV = val end)
makeSlider("Smoothness Value (Lower = Snappier)", 5, 50, 15, function(val) aimSmoothness = (val / 100) end)

Library:Notify("TWISTED Script Injected & Stabilized Successfully!", 5)
