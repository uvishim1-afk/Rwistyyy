-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- !! Replace with your Roblox User ID !!
local OWNER_ID = 11040787676
if LocalPlayer.UserId ~= OWNER_ID then return end

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

-- Draggable
local dragging, dragStart, startPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

------------------------------------------------------------------------
-- MAIN MENU (compact + scrollable)
------------------------------------------------------------------------
local menuGui = Instance.new("ScreenGui")
menuGui.Name           = "TwistedMenu"
menuGui.ResetOnSpawn   = false
menuGui.DisplayOrder   = 998
menuGui.IgnoreGuiInset = true
menuGui.Parent         = LocalPlayer.PlayerGui

-- Background frame
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

-- Title bar
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

-- Close / minimise button
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

-- Tab strip
local tabStrip = Instance.new("Frame")
tabStrip.Size             = UDim2.new(1, -8, 0, 36)
tabStrip.Position         = UDim2.new(0, 4, 0, 46)
tabStrip.BackgroundTransparency = 1
tabStrip.Parent           = menuFrame

local tabLayout = Instance.new("UIListLayout", tabStrip)
tabLayout.FillDirection  = Enum.FillDirection.Horizontal
tabLayout.Padding        = UDim.new(0, 3)
tabLayout.SortOrder      = Enum.SortOrder.LayoutOrder

-- Scrollable content area
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

-- Draggable title bar
local dragFrame = titleBar
local dragActive, dragOffset = false, Vector2.new()
dragFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragOffset = Vector2.new(menuFrame.AbsolutePosition.X - i.Position.X,
                                  menuFrame.AbsolutePosition.Y - i.Position.Y)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragActive and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        menuFrame.Position = UDim2.new(0, i.Position.X+dragOffset.X, 0, i.Position.Y+dragOffset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)

------------------------------------------------------------------------
-- UI HELPER FUNCTIONS
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
    lbl.Size             = UDim2.new(1,-60,0,20)
    lbl.Position         = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1
    lbl.TextColor3       = Color3.fromRGB(220,200,255)
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 12
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Text             = labelText

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size          = UDim2.new(0,50,0,20)
    valLbl.Position      = UDim2.new(1,-58,0,4)
    valLbl.BackgroundTransparency=1
    valLbl.TextColor3    = Color3.fromRGB(160,120,255)
    valLbl.Font          = Enum.Font.GothamBold
    valLbl.TextSize      = 12
    valLbl.TextXAlignment= Enum.TextXAlignment.Right
    valLbl.Text          = tostring(default)

    local track = Instance.new("Frame", row)
    track.Size           = UDim2.new(1,-20,0,8)
    track.Position       = UDim2.new(0,10,0,30)
    track.BackgroundColor3=Color3.fromRGB(40,25,70)
    track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill = Instance.new("Frame", track)
    fill.Size            = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3= Color3.fromRGB(120,60,220)
    fill.BorderSizePixel = 0
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
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            sliding=true; onInput(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding then onInput(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            sliding=false
        end
    end)
    return row
end

local function makeButton(labelText, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-4,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(70,30,130)
    btn.TextColor3       = Color3.fromRGB(230,210,255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.Text             = labelText
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order
    btn.Parent           = scrollFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    btn.MouseButton1Click:Connect(callback)
    btn.TouchTap:Connect(callback)
    return btn
end

local function makeDropdown(labelText, values, order, callback)
    local container = Instance.new("Frame")
    container.Size           = UDim2.new(1,-4,0,40)
    container.BackgroundColor3=Color3.fromRGB(18,12,35)
    container.BorderSizePixel=0
    container.LayoutOrder    = order
    container.Parent         = scrollFrame
    Instance.new("UICorner",container).CornerRadius=UDim.new(0,8)

    local lbl=Instance.new("TextLabel",container)
    lbl.Size=UDim2.new(0.45,0,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(220,200,255)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Text=labelText

    local selected = values[1] or ""
    local ddBtn=Instance.new("TextButton",container)
    ddBtn.Size=UDim2.new(0.5,0,0,28); ddBtn.Position=UDim2.new(0.48,0,0.5,-14)
    ddBtn.BackgroundColor3=Color3.fromRGB(50,25,90); ddBtn.TextColor3=Color3.fromRGB(200,170,255)
    ddBtn.Font=Enum.Font.Gotham; ddBtn.TextSize=11; ddBtn.Text=selected; ddBtn.BorderSizePixel=0
    Instance.new("UICorner",ddBtn).CornerRadius=UDim.new(0,6)

    -- Simple cycling dropdown (mobile-friendly, no popup)
    local idx=1
    local function cycle()
        idx = idx%#values+1; selected=values[idx]; ddBtn.Text=selected; callback(selected)
    end
    ddBtn.MouseButton1Click:Connect(cycle)
    ddBtn.TouchTap:Connect(cycle)

    return container, function(v) selected=v; ddBtn.Text=v end
end

------------------------------------------------------------------------
-- TAB SYSTEM
------------------------------------------------------------------------
local tabDefs = {"ESP","Aim","Trigger","Flight","Skybox","Currency","Perks"}
local activeTab = "ESP"
local tabButtons = {}
local tabSections = {} -- [tabName] = list of row frames

-- We'll show/hide rows by tab tag
local rowTags = {} -- [frame] = tabName

local function tagRow(frame, tab)
    rowTags[frame] = tab
    frame.Visible = (tab == activeTab)
end

local function switchTab(name)
    activeTab = name
    for frame, tag in pairs(rowTags) do
        frame.Visible = (tag == name)
    end
    for t, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = t==name and Color3.fromRGB(100,50,200) or Color3.fromRGB(28,18,55)
        btn.TextColor3       = t==name and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,130,210)
    end
end

for _, tabName in ipairs(tabDefs) do
    local short = tabName:sub(1,4):upper()
    local tb = Instance.new("TextButton", tabStrip)
    tb.Size             = UDim2.new(0, 34, 1, 0)
    tb.BackgroundColor3 = Color3.fromRGB(28,18,55)
    tb.TextColor3       = Color3.fromRGB(160,130,210)
    tb.Font             = Enum.Font.GothamBold
    tb.TextSize         = 9
    tb.Text             = short
    tb.BorderSizePixel  = 0
    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
    tabButtons[tabName]=tb
    tb.MouseButton1Click:Connect(function() switchTab(tabName) end)
    tb.TouchTap:Connect(function() switchTab(tabName) end)
end

local function addRow(frame, tab)
    tagRow(frame, tab)
end

------------------------------------------------------------------------
-- TOGGLE BUTTON WIRING
------------------------------------------------------------------------
local menuVisible = true
closeBtn.MouseButton1Click:Connect(function()
    menuVisible=false; menuFrame.Visible=false
    toggleBtn.Text="🌀\nOPEN"; toggleBtn.BackgroundColor3=Color3.fromRGB(30,10,50)
end)
closeBtn.TouchTap:Connect(function()
    menuVisible=false; menuFrame.Visible=false
    toggleBtn.Text="🌀\nOPEN"; toggleBtn.BackgroundColor3=Color3.fromRGB(30,10,50)
end)
toggleBtn.MouseButton1Click:Connect(function()
    if dragging then return end
    menuVisible=not menuVisible; menuFrame.Visible=menuVisible
    toggleBtn.Text=menuVisible and "🌀\nTWISTED" or "🌀\nOPEN"
    toggleBtn.BackgroundColor3=menuVisible and Color3.fromRGB(15,10,30) or Color3.fromRGB(30,10,50)
end)

------------------------------------------------------------------------
-- STATE
------------------------------------------------------------------------
local espObjects={};local trackedPlayers={};local globalESP=false;local espIgnoreTeam=true
local boxColor=Color3.fromRGB(160,80,255);local nameColor=Color3.fromRGB(255,255,255)
local distColor=Color3.fromRGB(255,220,50);local teamBoxColor=Color3.fromRGB(50,200,255)
local maxDistance=500;local showNames=true;local showHealth=true;local showDistance=true

local aimEnabled=false;local aimIgnoreTeam=true;local aimWallCheck=true
local aimStrength=1;local aimSmoothness=0.2;local aimFOV=120;local aimTarget=nil
local mobileAiming=false

local triggerEnabled=false;local triggerIgnoreTeam=true;local triggerDelay=0.05
local triggerWallCheck=true;local triggerHitPct=0.15 -- crosshair within % of screen
local lastTriggerTime=0

local flightEnabled=false;local flightSpeed=50;local flyConnection=nil
local originalWalkSpeed=16;local originalJumpPower=50

local function isSameTeam(pA,pB)
    if not pA or not pB then return false end
    local tA,tB=pA.Team,pB.Team; return tA~=nil and tB~=nil and tA==tB
end

------------------------------------------------------------------------
-- MOBILE FLIGHT PAD
------------------------------------------------------------------------
local flightGui=Instance.new("ScreenGui")
flightGui.Name="TwistedFlight"; flightGui.ResetOnSpawn=false
flightGui.DisplayOrder=997; flightGui.IgnoreGuiInset=true
flightGui.Enabled=false; flightGui.Parent=LocalPlayer.PlayerGui

local function mkPadBtn(parent,text,pos,size,col)
    local b=Instance.new("TextButton")
    b.Size=size or UDim2.new(0,64,0,64); b.Position=pos
    b.BackgroundColor3=col or Color3.fromRGB(25,15,50)
    b.BackgroundTransparency=0.2; b.TextColor3=Color3.fromRGB(220,200,255)
    b.Font=Enum.Font.GothamBold; b.TextSize=20; b.Text=text
    b.AutoButtonColor=false; b.BorderSizePixel=0; b.ZIndex=50; b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,12)
    Instance.new("UIStroke",b).Color=Color3.fromRGB(100,50,200)
    return b
end

local pad=Instance.new("Frame",flightGui)
pad.Size=UDim2.new(0,210,0,210); pad.Position=UDim2.new(0,8,1,-220)
pad.BackgroundTransparency=1; pad.ZIndex=49

local btnFwd    = mkPadBtn(pad,"⬆",UDim2.new(0.5,-32,0,0))
local btnBwd    = mkPadBtn(pad,"⬇",UDim2.new(0.5,-32,1,-64))
local btnLft    = mkPadBtn(pad,"←",UDim2.new(0,0,0.5,-32))
local btnRgt    = mkPadBtn(pad,"→",UDim2.new(1,-64,0.5,-32))
local btnRise   = mkPadBtn(flightGui,"🔼",UDim2.new(1,-140,1,-150),UDim2.new(0,130,0,56),Color3.fromRGB(20,50,70))
local btnDescend= mkPadBtn(flightGui,"🔽",UDim2.new(1,-140,1,-86), UDim2.new(0,130,0,56),Color3.fromRGB(50,20,70))
local btnBoost  = mkPadBtn(flightGui,"⚡",UDim2.new(1,-140,1,-220),UDim2.new(0,130,0,56),Color3.fromRGB(70,50,0))

local mobileHeld={forward=false,back=false,left=false,right=false,up=false,down=false,boost=false}
local function wireHold(btn,key)
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then mobileHeld[key]=true end end)
    btn.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.Touch then mobileHeld[key]=false end end)
    btn.MouseButton1Down:Connect(function() mobileHeld[key]=true end)
    btn.MouseButton1Up:Connect(function()   mobileHeld[key]=false end)
end
wireHold(btnFwd,"forward"); wireHold(btnBwd,"back")
wireHold(btnLft,"left");    wireHold(btnRgt,"right")
wireHold(btnRise,"up");     wireHold(btnDescend,"down"); wireHold(btnBoost,"boost")

-- Mobile aim button
local aimGui=Instance.new("ScreenGui")
aimGui.Name="TwistedAim"; aimGui.ResetOnSpawn=false
aimGui.DisplayOrder=996; aimGui.IgnoreGuiInset=true; aimGui.Parent=LocalPlayer.PlayerGui
local aimBtn=mkPadBtn(aimGui,"🎯",UDim2.new(1,-76,0,16),UDim2.new(0,60,0,60),Color3.fromRGB(80,10,10))
aimBtn.Visible=false
aimBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then mobileAiming=true; aimBtn.BackgroundColor3=Color3.fromRGB(160,30,30) end end)
aimBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then mobileAiming=false; aimTarget=nil; aimBtn.BackgroundColor3=Color3.fromRGB(80,10,10) end end)

------------------------------------------------------------------------
-- SKYBOX PRESETS
------------------------------------------------------------------------
local SKYBOXES={
    {Name="🌤 Default",   Bk="rbxassetid://91458024",   Dn="rbxassetid://91457980",   Ft="rbxassetid://91458024",   Lf="rbxassetid://91458024",   Rt="rbxassetid://91458024",   Up="rbxassetid://91458024",   Stars=3000,  Celestial=true},
    {Name="🌌 Deep Space",Bk="rbxassetid://159454286",  Dn="rbxassetid://159454286",  Ft="rbxassetid://159454286",  Lf="rbxassetid://159454286",  Rt="rbxassetid://159454286",  Up="rbxassetid://159454286",  Stars=10000, Celestial=false},
    {Name="🌃 City Night",Bk="rbxassetid://144943495",  Dn="rbxassetid://144943495",  Ft="rbxassetid://144943495",  Lf="rbxassetid://144943495",  Rt="rbxassetid://144943495",  Up="rbxassetid://144943495",  Stars=5000,  Celestial=true},
    {Name="🌅 Sunset",    Bk="rbxassetid://32584699",   Dn="rbxassetid://32584699",   Ft="rbxassetid://32584699",   Lf="rbxassetid://32584699",   Rt="rbxassetid://32584699",   Up="rbxassetid://32584699",   Stars=0,     Celestial=true},
    {Name="🌊 Ocean",     Bk="rbxassetid://1012890",    Dn="rbxassetid://1012891",    Ft="rbxassetid://1012890",    Lf="rbxassetid://1012890",    Rt="rbxassetid://1012890",    Up="rbxassetid://1012890",    Stars=1000,  Celestial=true},
    {Name="🔴 Apocalypse",Bk="rbxassetid://358313209",  Dn="rbxassetid://358313209",  Ft="rbxassetid://358313209",  Lf="rbxassetid://358313209",  Rt="rbxassetid://358313209",  Up="rbxassetid://358313209",  Stars=0,     Celestial=false},
    {Name="❄️ Arctic",    Bk="rbxassetid://159195142",  Dn="rbxassetid://159195142",  Ft="rbxassetid://159195142",  Lf="rbxassetid://159195142",  Rt="rbxassetid://159195142",  Up="rbxassetid://159195142",  Stars=500,   Celestial=true},
    {Name="🌙 Midnight",  Bk="rbxassetid://144933338",  Dn="rbxassetid://144931530",  Ft="rbxassetid://144933262",  Lf="rbxassetid://144933244",  Rt="rbxassetid://144933299",  Up="rbxassetid://144931564",  Stars=8000,  Celestial=true},
    {Name="🔥 Lava",      Bk="rbxassetid://10258337305",Dn="rbxassetid://10258337305",Ft="rbxassetid://10258337305",Lf="rbxassetid://10258337305",Rt="rbxassetid://10258337305",Up="rbxassetid://10258337305",Stars=0,     Celestial=false},
    {Name="✨ Custom",     Bk="",Dn="",Ft="",Lf="",Rt="",Up="",Stars=3000,Celestial=true},
}
local skyboxNames={}; for _,s in ipairs(SKYBOXES) do table.insert(skyboxNames,s.Name) end
local currentSkyPreset=1; local customIDs={Bk="",Dn="",Ft="",Lf="",Rt="",Up=""}

local function getSky() local s=Lighting:FindFirstChildOfClass("Sky"); if not s then s=Instance.new("Sky"); s.Parent=Lighting end return s end
local function applySkybox(p)
    local sky=getSky(); local pr=SKYBOXES[p]; if not pr then return end
    local function id(f) local r=(p==#SKYBOXES and customIDs[f]~="") and customIDs[f] or pr[f]
        if r=="" then return "" end; if r:match("^rbxassetid://") then return r end; return "rbxassetid://"..r end
    sky.SkyboxBk=id("Bk");sky.SkyboxDn=id("Dn");sky.SkyboxFt=id("Ft")
    sky.SkyboxLf=id("Lf");sky.SkyboxRt=id("Rt");sky.SkyboxUp=id("Up")
    sky.StarCount=pr.Stars;sky.CelestialBodiesShown=pr.Celestial
end
local function removeSkybox() local s=Lighting:FindFirstChildOfClass("Sky"); if s then s:Destroy() end end

------------------------------------------------------------------------
-- FLIGHT HELPERS
------------------------------------------------------------------------
local function getCharacter() return LocalPlayer.Character end
local function getHumanoid() local c=getCharacter(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c=getCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end

local function enableFlight()
    local char=getCharacter();local hrp=getHRP();local hum=getHumanoid()
    if not char or not hrp or not hum then return end
    originalWalkSpeed=hum.WalkSpeed;originalJumpPower=hum.JumpPower
    hum.WalkSpeed=0;hum.JumpPower=0;hrp.Velocity=Vector3.zero
    local bv=hrp:FindFirstChild("TwistedBV") or Instance.new("BodyVelocity")
    bv.Name="TwistedBV";bv.MaxForce=Vector3.new(1e5,1e5,1e5);bv.Velocity=Vector3.zero;bv.Parent=hrp
    local bg=hrp:FindFirstChild("TwistedBG") or Instance.new("BodyGyro")
    bg.Name="TwistedBG";bg.MaxTorque=Vector3.new(1e5,1e5,1e5);bg.D=100;bg.CFrame=hrp.CFrame;bg.Parent=hrp
    flightGui.Enabled=true
    flyConnection=RunService.RenderStepped:Connect(function()
        local h=getHRP(); local bv2=h and h:FindFirstChild("TwistedBV"); local bg2=h and h:FindFirstChild("TwistedBG")
        if not h or not bv2 or not bg2 then return end
        local cam=Camera.CFrame; local md=Vector3.zero
        local boost=(mobileHeld.boost or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) and 2.5 or 1
        local spd=flightSpeed*boost
        if mobileHeld.forward  or UserInputService:IsKeyDown(Enum.KeyCode.W) then md=md+cam.LookVector  end
        if mobileHeld.back     or UserInputService:IsKeyDown(Enum.KeyCode.S) then md=md-cam.LookVector  end
        if mobileHeld.right    or UserInputService:IsKeyDown(Enum.KeyCode.D) then md=md+cam.RightVector end
        if mobileHeld.left     or UserInputService:IsKeyDown(Enum.KeyCode.A) then md=md-cam.RightVector end
        if mobileHeld.up       or UserInputService:IsKeyDown(Enum.KeyCode.Space) then md=md+Vector3.new(0,1,0) end
        if mobileHeld.down     or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then md=md-Vector3.new(0,1,0) end
        bv2.Velocity=md.Magnitude>0 and md.Unit*spd or bv2.Velocity*0.75
        bg2.CFrame=CFrame.new(h.Position,h.Position+cam.LookVector)
    end)
end

local function disableFlight()
    if flyConnection then flyConnection:Disconnect();flyConnection=nil end
    local hrp=getHRP()
    if hrp then
        local bv=hrp:FindFirstChild("TwistedBV");local bg=hrp:FindFirstChild("TwistedBG")
        if bv then bv:Destroy() end;if bg then bg:Destroy() end;hrp.Velocity=Vector3.zero
    end
    local hum=getHumanoid()
    if hum then hum.WalkSpeed=originalWalkSpeed;hum.JumpPower=originalJumpPower end
    flightGui.Enabled=false
end

LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if flightEnabled then enableFlight() end end)

------------------------------------------------------------------------
-- WALL CHECK
------------------------------------------------------------------------
local function isVisible(part)
    if not part then return false end
    local origin=Camera.CFrame.Position; local dir=part.Position-origin
    local p=RaycastParams.new(); p.FilterType=Enum.RaycastFilterType.Exclude
    local ig={}; local lc=LocalPlayer.Character; if lc then table.insert(ig,lc) end
    local tc=part.Parent; if tc then table.insert(ig,tc) end
    p.FilterDescendantsInstances=ig
    return workspace:Raycast(origin,dir.Unit*dir.Magnitude,p)==nil
end

------------------------------------------------------------------------
-- ESP
------------------------------------------------------------------------
local function createESP(player)
    if espObjects[player] then return end
    local sg=Instance.new("ScreenGui"); sg.Name="TESP_"..player.Name
    sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=LocalPlayer.PlayerGui
    local bf=Instance.new("Frame"); bf.Name="Box";bf.BackgroundTransparency=1
    bf.BorderSizePixel=0;bf.Size=UDim2.new(0,60,0,100);bf.Visible=false;bf.Parent=sg
    local function mkL(n,aX,aY,sX,sY,pX,pY)
        local f=Instance.new("Frame");f.Name=n;f.BackgroundColor3=boxColor;f.BorderSizePixel=0
        f.AnchorPoint=Vector2.new(aX,aY);f.Size=UDim2.new(sX,0,sY,0);f.Position=UDim2.new(pX,0,pY,0);f.ZIndex=5;f.Parent=bf;return f
    end
    local tl=mkL("T",0,0,1,0,2,0,0,0);local bl=mkL("B",0,1,1,0,2,0,1,0)
    local ll=mkL("L",0,0,0,2,1,0,0,0);local rl=mkL("R",1,0,0,2,1,1,0,0)
    local function mkLbl(n,sz,anc,pos,font,ts,col)
        local l=Instance.new("TextLabel");l.Name=n;l.BackgroundTransparency=1
        l.TextColor3=col;l.TextStrokeColor3=Color3.new(0,0,0);l.TextStrokeTransparency=0.4
        l.Font=font;l.TextSize=ts;l.Size=sz;l.AnchorPoint=anc;l.Position=pos;l.ZIndex=6;l.Text="";l.Visible=false;l.Parent=bf;return l
    end
    local nl=mkLbl("N",UDim2.new(1,40,0,18),Vector2.new(0.5,1),UDim2.new(0.5,0,0,-4), Enum.Font.GothamBold,13,nameColor)
    local dl=mkLbl("D",UDim2.new(1,40,0,16),Vector2.new(0.5,0),UDim2.new(0.5,0,1,4),  Enum.Font.Gotham,    11,distColor)
    local tml=mkLbl("TM",UDim2.new(1,40,0,14),Vector2.new(0.5,1),UDim2.new(0.5,0,0,-20),Enum.Font.Gotham,  10,Color3.fromRGB(180,230,255))
    local hbg=Instance.new("Frame");hbg.BackgroundColor3=Color3.fromRGB(30,30,30);hbg.BorderSizePixel=0
    hbg.AnchorPoint=Vector2.new(0,0);hbg.Size=UDim2.new(0,4,1,0);hbg.Position=UDim2.new(1,5,0,0);hbg.ZIndex=5;hbg.Visible=false;hbg.Parent=bf
    local hfl=Instance.new("Frame",hbg);hfl.BackgroundColor3=Color3.fromRGB(50,255,100);hfl.BorderSizePixel=0
    hfl.AnchorPoint=Vector2.new(0,1);hfl.Size=UDim2.new(1,0,1,0);hfl.Position=UDim2.new(0,0,1,0);hfl.ZIndex=6
    espObjects[player]={gui=sg,bf=bf,tl=tl,bl=bl,ll=ll,rl=rl,nl=nl,dl=dl,tml=tml,hbg=hbg,hfl=hfl}
end
local function removeESP(p) local o=espObjects[p]; if o then o.gui:Destroy();espObjects[p]=nil end end
local function removeAllESP() for p in pairs(espObjects) do removeESP(p) end end

------------------------------------------------------------------------
-- AIM / TRIGGER TARGET
------------------------------------------------------------------------
local function getClosestTarget()
    local center=Camera.ViewportSize/2;local best=nil;local bestDist=aimFOV
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl==LocalPlayer then continue end
        if aimIgnoreTeam and isSameTeam(LocalPlayer,pl) then continue end
        local char=pl.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        local ap=char:FindFirstChild("Head") or hrp
        local sp,on=Camera:WorldToViewportPoint(ap.Position)
        if not on then continue end
        if aimWallCheck and not isVisible(ap) then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<bestDist then bestDist=d;best=char end
    end
    return best
end

-- Triggerbot: checks if crosshair is over a valid enemy
local function getTriggerTarget()
    local vp=Camera.ViewportSize; local center=Vector2.new(vp.X/2,vp.Y/2)
    local hitRadius=math.min(vp.X,vp.Y)*triggerHitPct
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl==LocalPlayer then continue end
        if triggerIgnoreTeam and isSameTeam(LocalPlayer,pl) then continue end
        local char=pl.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        -- Check head and torso
        for _,partName in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart"}) do
            local part=char:FindFirstChild(partName)
            if not part then continue end
            local sp,on=Camera:WorldToViewportPoint(part.Position)
            if not on then continue end
            if triggerWallCheck and not isVisible(part) then continue end
            if (Vector2.new(sp.X,sp.Y)-center).Magnitude <= hitRadius then
                return pl
            end
        end
    end
    return nil
end

------------------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------------------
local fovCircle=Drawing.new("Circle")
fovCircle.Visible=false;fovCircle.Radius=aimFOV
fovCircle.Color=Color3.fromRGB(160,80,255);fovCircle.Thickness=1
fovCircle.Filled=false;fovCircle.Position=Camera.ViewportSize/2

------------------------------------------------------------------------
-- RENDER LOOP
------------------------------------------------------------------------
local BORDER=2
RunService.RenderStepped:Connect(function(dt)
    local localChar=LocalPlayer.Character
    local localHRP=localChar and localChar:FindFirstChild("HumanoidRootPart")
    local center=Camera.ViewportSize/2
    fovCircle.Position=center;fovCircle.Radius=aimFOV

    -- ESP
    for player,obj in pairs(espObjects) do
        local character=player.Character
        local hrp=character and character:FindFirstChild("HumanoidRootPart")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local isTeammate=isSameTeam(LocalPlayer,player)
        local function hideAll()
            obj.bf.Visible=false;obj.nl.Visible=false;obj.dl.Visible=false
            obj.hbg.Visible=false;obj.tml.Visible=false
        end
        if espIgnoreTeam and isTeammate and not trackedPlayers[player.Name] then hideAll();continue end
        if not hrp or not humanoid or humanoid.Health<=0 then hideAll();continue end
        local dist=localHRP and (localHRP.Position-hrp.Position).Magnitude or 0
        if dist>maxDistance then hideAll();continue end
        local cf=hrp.CFrame;local s=Vector3.new(2,3,0)
        local pts={cf*Vector3.new(s.X,s.Y*1.2,0),cf*Vector3.new(-s.X,s.Y*1.2,0),
                   cf*Vector3.new(s.X,-s.Y*1.1,0),cf*Vector3.new(-s.X,-s.Y*1.1,0)}
        local mnX,mnY,mxX,mxY=math.huge,math.huge,-math.huge,-math.huge
        for _,w in ipairs(pts) do
            local sc=Camera:WorldToViewportPoint(w)
            mnX=math.min(mnX,sc.X);mnY=math.min(mnY,sc.Y)
            mxX=math.max(mxX,sc.X);mxY=math.max(mxY,sc.Y)
        end
        local vp=Camera.ViewportSize
        if mxX<0 or mnX>vp.X or mxY<0 or mnY>vp.Y then hideAll();continue end
        obj.bf.Position=UDim2.new(0,mnX,0,mnY)
        obj.bf.Size=UDim2.new(0,math.max(mxX-mnX,10),0,math.max(mxY-mnY,10))
        obj.bf.Visible=true
        local col=isTeammate and teamBoxColor or boxColor
        for _,ln in ipairs({obj.tl,obj.bl,obj.ll,obj.rl}) do ln.BackgroundColor3=col end
        obj.tl.Size=UDim2.new(1,0,0,BORDER);obj.bl.Size=UDim2.new(1,0,0,BORDER)
        obj.ll.Size=UDim2.new(0,BORDER,1,0);obj.rl.Size=UDim2.new(0,BORDER,1,0)
        obj.nl.Visible=showNames;obj.nl.TextColor3=nameColor;obj.nl.Text=player.Name
        obj.dl.Visible=showDistance;obj.dl.TextColor3=distColor
        obj.dl.Text=string.format("[%dm]",math.floor(dist))
        obj.hbg.Visible=showHealth
        if showHealth then
            local pct=math.clamp(humanoid.Health/humanoid.MaxHealth,0,1)
            obj.hfl.Size=UDim2.new(1,0,pct,0)
            obj.hfl.BackgroundColor3=Color3.new(math.clamp(2*(1-pct),0,1),math.clamp(2*pct,0,1),0.1)
        end
        local team=player.Team
        if team then obj.tml.Text="["..team.Name.."]";obj.tml.TextColor3=team.TeamColor.Color;obj.tml.Visible=showNames
        else obj.tml.Visible=false end
    end

    -- Aim Assist
    if aimEnabled then
        local isAiming=mobileAiming or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if not isAiming then aimTarget=nil
        else
            if not aimTarget then aimTarget=getClosestTarget()
            else
                local hrp=aimTarget:FindFirstChild("HumanoidRootPart")
                local hum=aimTarget:FindFirstChildOfClass("Humanoid")
                local op=Players:GetPlayerFromCharacter(aimTarget)
                if not hrp or not hum or hum.Health<=0
                    or(aimIgnoreTeam and isSameTeam(LocalPlayer,op))
                    or(aimWallCheck and not isVisible(aimTarget:FindFirstChild("Head") or hrp))
                then aimTarget=getClosestTarget() end
            end
            if aimTarget then
                local ap=aimTarget:FindFirstChild("Head") or aimTarget:FindFirstChild("HumanoidRootPart")
                if ap then
                    local _,on=Camera:WorldToViewportPoint(ap.Position)
                    if on then
                        local lf=math.clamp(dt*(1/aimSmoothness)*aimStrength,0,1)
                        Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,ap.Position),lf)
                    else aimTarget=nil end
                end
            end
        end
    end

    -- Triggerbot
    if triggerEnabled then
        local now=tick()
        if now-lastTriggerTime >= triggerDelay then
            local target=getTriggerTarget()
            if target then
                lastTriggerTime=now
                -- Fire a fake click via VirtualInputManager (works in most executors)
                local vim=game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(0,0,0,true,game,0)
                task.delay(0.05,function()
                    vim:SendMouseButtonEvent(0,0,0,false,game,0)
                end)
            end
        end
    end
end)

------------------------------------------------------------------------
-- BUILD UI ROWS
------------------------------------------------------------------------
local o=0
local function O() o=o+1; return o end

-- ═══ ESP ═══
addRow(makeSection("ESP",O()),"ESP")
addRow(makeToggle("ESP All Players",false,O(),function(v)
    globalESP=v
    if v then for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end
    else for _,p in ipairs(Players:GetPlayers()) do if not trackedPlayers[p.Name] then removeESP(p) end end end
end),"ESP")
addRow(makeToggle("Hide Teammates",true,O(),function(v) espIgnoreTeam=v end),"ESP")
addRow(makeToggle("Show Names",true,O(),function(v) showNames=v end),"ESP")
addRow(makeToggle("Show Health",true,O(),function(v) showHealth=v end),"ESP")
addRow(makeToggle("Show Distance",true,O(),function(v) showDistance=v end),"ESP")
addRow(makeSlider("Max Distance",50,2000,500,O(),function(v) maxDistance=v end),"ESP")
addRow(makeButton("Refresh Player List",O(),function()
    local names={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(names,p.Name) end end
end),"ESP")
addRow(makeButton("Remove All ESP",O(),function() trackedPlayers={}; removeAllESP() end),"ESP")

-- ═══ AIM ═══
addRow(makeSection("Aim Assist",O()),"Aim")
addRow(makeToggle("Enable Aim Assist",false,O(),function(v)
    aimEnabled=v; fovCircle.Visible=v and not isMobile; aimBtn.Visible=v and isMobile
    if not v then aimTarget=nil end
end),"Aim")
addRow(makeToggle("Ignore Teammates",true,O(),function(v) aimIgnoreTeam=v;aimTarget=nil end),"Aim")
addRow(makeToggle("Wall Check",true,O(),function(v) aimWallCheck=v;aimTarget=nil end),"Aim")
addRow(makeSlider("Strength",1,10,1,O(),function(v) aimStrength=v end),"Aim")
addRow(makeSlider("Smoothness",1,10,5,O(),function(v) aimSmoothness=v*0.03 end),"Aim")
addRow(makeSlider("FOV Radius",30,400,120,O(),function(v) aimFOV=v;fovCircle.Radius=v end),"Aim")
if isMobile then
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,36); f.BackgroundTransparency=1
    f.LayoutOrder=O(); f.Parent=scrollFrame
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.TextColor3=Color3.fromRGB(160,120,255); l.Font=Enum.Font.Gotham; l.TextSize=11
    l.Text="📱 Hold 🎯 button to aim"; addRow(f,"Aim")
end

-- ═══ TRIGGER ═══
addRow(makeSection("Triggerbot",O()),"Trigger")
addRow(makeToggle("Enable Triggerbot",false,O(),function(v) triggerEnabled=v end),"Trigger")
addRow(makeToggle("Ignore Teammates",true,O(),function(v) triggerIgnoreTeam=v end),"Trigger")
addRow(makeToggle("Wall Check",true,O(),function(v) triggerWallCheck=v end),"Trigger")
addRow(makeSlider("Fire Delay (ms)",0,500,50,O(),function(v) triggerDelay=v/1000 end),"Trigger")
addRow(makeSlider("Hit Zone Size %",5,40,15,O(),function(v) triggerHitPct=v/100 end),"Trigger")
do
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,48); f.BackgroundColor3=Color3.fromRGB(18,12,35)
    f.BorderSizePixel=0; f.LayoutOrder=O(); f.Parent=scrollFrame
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-10,1,0); l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(160,120,255); l.Font=Enum.Font.Gotham
    l.TextSize=11; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Text="Auto-fires when crosshair is over an enemy. Adjust Hit Zone to control sensitivity."
    addRow(f,"Trigger")
end

-- ═══ FLIGHT ═══
addRow(makeSection("Flight",O()),"Flight")
addRow(makeToggle("Enable Flight",false,O(),function(v) flightEnabled=v; if v then enableFlight() else disableFlight() end end),"Flight")
addRow(makeSlider("Speed",10,300,50,O(),function(v) flightSpeed=v end),"Flight")
addRow(makeButton("⬆ Teleport Up 50",O(),function() local h=getHRP(); if h then h.CFrame=h.CFrame+Vector3.new(0,50,0) end end),"Flight")
addRow(makeButton("⬇ Return to Ground",O(),function()
    local char=getCharacter();local hrp=getHRP(); if not hrp then return end
    local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Exclude;rp.FilterDescendantsInstances={char}
    local res=workspace:Raycast(hrp.Position,Vector3.new(0,-5000,0),rp)
    if res then hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0)) end
    if flightEnabled then flightEnabled=false;disableFlight() end
end),"Flight")
do
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,isMobile and 72 or 56)
    f.BackgroundColor3=Color3.fromRGB(18,12,35); f.BorderSizePixel=0; f.LayoutOrder=O(); f.Parent=scrollFrame
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-10,1,0); l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(160,120,255); l.Font=Enum.Font.Gotham
    l.TextSize=11; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Text=isMobile and "📱 On-screen pad appears when flight is on\n⬆⬇ Fwd/Back  ←→ Strafe  🔼🔽 Rise/Descend  ⚡ Boost"
        or "WASD = direction  Space = up  Ctrl = down  Shift = boost (2.5x)"
    addRow(f,"Flight")
end

-- ═══ SKYBOX ═══
addRow(makeSection("Skybox",O()),"Skybox")
addRow(makeToggle("Enable Skybox",false,O(),function(v) if v then applySkybox(currentSkyPreset) else removeSkybox() end end),"Skybox")
local skyDrop,skyDropSet=makeDropdown("Preset",skyboxNames,O(),function(v)
    for i,n in ipairs(skyboxNames) do if n==v then currentSkyPreset=i;break end end
    if Lighting:FindFirstChildOfClass("Sky") then applySkybox(currentSkyPreset) end
end)
addRow(skyDrop,"Skybox")
addRow(makeButton("Apply Preset",O(),function() applySkybox(currentSkyPreset) end),"Skybox")
addRow(makeButton("Remove Skybox",O(),function() removeSkybox() end),"Skybox")
addRow(makeSlider("Star Count",0,15000,3000,O(),function(v)
    local s=Lighting:FindFirstChildOfClass("Sky"); if s then s.StarCount=v end
end),"Skybox")
addRow(makeToggle("Show Sun/Moon",true,O(),function(v)
    local s=Lighting:FindFirstChildOfClass("Sky"); if s then s.CelestialBodiesShown=v end
end),"Skybox")
addRow(makeButton("Apply Custom (_G.skyBk..Up)",O(),function()
    customIDs.Bk=tostring(_G.skyBk or "");customIDs.Dn=tostring(_G.skyDn or "")
    customIDs.Ft=tostring(_G.skyFt or "");customIDs.Lf=tostring(_G.skyLf or "")
    customIDs.Rt=tostring(_G.skyRt or "");customIDs.Up=tostring(_G.skyUp or "")
    currentSkyPreset=#SKYBOXES;applySkybox(currentSkyPreset)
end),"Skybox")

-- ═══ CURRENCY ═══
addRow(makeSection("Currency",O()),"Currency")
local currencyAmount=1000;local currencyStatName="Cash";local currencyTarget="Everyone"
addRow(makeSlider("Amount",0,1000000,1000,O(),function(v) currencyAmount=v end),"Currency")
addRow(makeButton("Refresh Stat (_G.statName)",O(),function()
    if _G.statName and _G.statName~="" then currencyStatName=tostring(_G.statName) end
end),"Currency")
local currPlayers={"Everyone"}; local currDrop,currDropSet=makeDropdown("Target",currPlayers,O(),function(v) currencyTarget=v end)
addRow(currDrop,"Currency")
addRow(makeButton("Refresh Players",O(),function()
    local n={"Everyone"}; for _,p in ipairs(Players:GetPlayers()) do table.insert(n,p.Name) end
    currPlayers=n; currDropSet(n[1])
end),"Currency")
addRow(makeButton("✅ Set Currency",O(),function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerCurrencySet"); if not remote then return end
    if currencyTarget=="Everyone" then
        for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,currencyStatName,currencyAmount) end
    else remote:FireServer(currencyTarget,currencyStatName,currencyAmount) end
end),"Currency")
addRow(makeButton("🔄 Reset to 0",O(),function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerCurrencySet"); if not remote then return end
    if currencyTarget=="Everyone" then
        for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,currencyStatName,0) end
    else remote:FireServer(currencyTarget,currencyStatName,0) end
end),"Currency")

-- ═══ PERKS ═══
addRow(makeSection("Perks",O()),"Perks")
local perkNames={"VIP Speed","Double Jump","VIP Tag","God Mode","Reset Perks"}
local selectedPerk=perkNames[1];local selectedPerkTarget="Everyone"
local perkDrop,_=makeDropdown("Perk",perkNames,O(),function(v) selectedPerk=v end)
addRow(perkDrop,"Perks")
local perkPlayers={"Everyone"}; local perkPlayerDrop,perkPlayerSet=makeDropdown("Target",perkPlayers,O(),function(v) selectedPerkTarget=v end)
addRow(perkPlayerDrop,"Perks")
addRow(makeButton("Refresh Players",O(),function()
    local n={"Everyone"}; for _,p in ipairs(Players:GetPlayers()) do table.insert(n,p.Name) end
    perkPlayers=n; perkPlayerSet(n[1])
end),"Perks")
addRow(makeButton("✅ Grant Perk",O(),function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerGrantPerk"); if not remote then return end
    if selectedPerkTarget=="Everyone" then
        for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,selectedPerk) end
    else remote:FireServer(selectedPerkTarget,selectedPerk) end
end),"Perks")
addRow(makeButton("🔄 Reset All Perks",O(),function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerGrantPerk"); if not remote then return end
    for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,"Reset Perks") end
end),"Perks")

------------------------------------------------------------------------
-- PLAYER EVENTS
------------------------------------------------------------------------
Players.PlayerRemoving:Connect(function(player) trackedPlayers[player.Name]=nil;removeESP(player) end)
Players.PlayerAdded:Connect(function(player)
    if globalESP or trackedPlayers[player.Name] then
        player.CharacterAdded:Connect(function() task.wait(0.5);createESP(player) end)
        createESP(player)
    end
end)

-- Initial tab
switchTab("ESP")
