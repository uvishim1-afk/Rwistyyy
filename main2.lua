-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- !! Replace with your Roblox User ID !!
local OWNER_ID = 0

if LocalPlayer.UserId ~= OWNER_ID then return end

-- Load Linoria
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

------------------------------------------------------------------------
-- MOBILE TOGGLE BUTTON (floating, always visible)
------------------------------------------------------------------------
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name            = "OwnerToggleGui"
toggleGui.ResetOnSpawn    = false
toggleGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
toggleGui.DisplayOrder    = 999
toggleGui.IgnoreGuiInset  = true
toggleGui.Parent          = LocalPlayer.PlayerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name              = "ToggleBtn"
toggleBtn.Size              = UDim2.new(0, 64, 0, 64)
toggleBtn.Position          = UDim2.new(0, 12, 0.5, -32)
toggleBtn.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
toggleBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
toggleBtn.Font              = Enum.Font.GothamBold
toggleBtn.TextSize          = 11
toggleBtn.Text              = "👑\nMENU"
toggleBtn.AutoButtonColor   = true
toggleBtn.ZIndex            = 100
toggleBtn.Parent            = toggleGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 14)
btnCorner.Parent       = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color     = Color3.fromRGB(100, 100, 200)
btnStroke.Thickness = 2
btnStroke.Parent    = toggleBtn

-- Make button draggable on mobile
local dragging, dragStart, startPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = toggleBtn.Position
    end
end)
toggleBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
toggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

------------------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------------------
local Window = Library:CreateWindow({
    Title   = "👑 Owner Panel",
    Center  = true,
    AutoShow = true,
    Size    = isMobile and UDim2.new(0, 360, 0, 580) or nil,
})

-- Wire toggle button to show/hide
local menuVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    if menuVisible then
        Library:Show()
        toggleBtn.Text              = "👑\nMENU"
        toggleBtn.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
    else
        Library:Hide()
        toggleBtn.Text              = "👑\nOPEN"
        toggleBtn.BackgroundColor3  = Color3.fromRGB(40, 10, 10)
    end
end)

local Tabs = {
    ESP       = Window:AddTab("ESP"),
    AimAssist = Window:AddTab("Aim"),
    Flight    = Window:AddTab("Flight"),
    Skybox    = Window:AddTab("Sky"),
    Currency  = Window:AddTab("Currency"),
    Perks     = Window:AddTab("Perks"),
}

local LeftGroup  = Tabs.ESP:AddLeftGroupbox("ESP Settings")
local RightGroup = Tabs.ESP:AddRightGroupbox("Players")

------------------------------------------------------------------------
-- TEAM UTILITY
------------------------------------------------------------------------
local function isSameTeam(pA, pB)
    if not pA or not pB then return false end
    local tA, tB = pA.Team, pB.Team
    return tA ~= nil and tB ~= nil and tA == tB
end

------------------------------------------------------------------------
-- ESP STATE
------------------------------------------------------------------------
local espObjects     = {}
local trackedPlayers = {}
local globalESP      = false
local espIgnoreTeam  = true
local boxColor       = Color3.fromRGB(255, 50,  50)
local nameColor      = Color3.fromRGB(255, 255, 255)
local distColor      = Color3.fromRGB(255, 220, 50)
local teamBoxColor   = Color3.fromRGB(50,  200, 255)
local maxDistance    = 500
local showNames      = true
local showHealth     = true
local showDistance   = true

------------------------------------------------------------------------
-- AIM ASSIST STATE
------------------------------------------------------------------------
local aimEnabled    = false
local aimIgnoreTeam = true
local aimWallCheck  = true
local aimStrength   = 1
local aimSmoothness = 0.2
local aimFOV        = 120
local aimTarget     = nil

-- Mobile: aim activates via on-screen button instead of RMB
local mobileAiming  = false

------------------------------------------------------------------------
-- FLIGHT STATE
------------------------------------------------------------------------
local flightEnabled     = false
local flightSpeed       = 50
local flyConnection     = nil
local originalWalkSpeed = 16
local originalJumpPower = 50

local FLIGHT_KEYS = {
    UP      = Enum.KeyCode.Space,
    DOWN    = Enum.KeyCode.LeftControl,
    FORWARD = Enum.KeyCode.W,
    BACK    = Enum.KeyCode.S,
    LEFT    = Enum.KeyCode.A,
    RIGHT   = Enum.KeyCode.D,
    BOOST   = Enum.KeyCode.LeftShift,
}

------------------------------------------------------------------------
-- MOBILE FLIGHT CONTROLS (on-screen joystick-style buttons)
------------------------------------------------------------------------
local flightGui = Instance.new("ScreenGui")
flightGui.Name           = "FlightControlGui"
flightGui.ResetOnSpawn   = false
flightGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
flightGui.DisplayOrder   = 998
flightGui.IgnoreGuiInset = true
flightGui.Enabled        = false
flightGui.Parent         = LocalPlayer.PlayerGui

local function makeMobileBtn(parent, text, pos, size, color)
    local btn = Instance.new("TextButton")
    btn.Size             = size or UDim2.new(0, 72, 0, 72)
    btn.Position         = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.BackgroundTransparency = 0.25
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 22
    btn.Text             = text
    btn.AutoButtonColor  = false
    btn.ZIndex           = 50
    btn.Parent           = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,12); c.Parent = btn
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(80,80,160); s.Thickness=1.5; s.Parent=btn
    return btn
end

-- Flight direction pad (bottom-left area)
local flightPad = Instance.new("Frame")
flightPad.Name                   = "FlightPad"
flightPad.Size                   = UDim2.new(0, 240, 0, 240)
flightPad.Position               = UDim2.new(0, 10, 1, -260)
flightPad.BackgroundTransparency = 1
flightPad.ZIndex                 = 49
flightPad.Parent                 = flightGui

local btnUp    = makeMobileBtn(flightPad, "↑",  UDim2.new(0.5,-36,0,0))
local btnDown2 = makeMobileBtn(flightPad, "↓",  UDim2.new(0.5,-36,1,-72))
local btnLeft2 = makeMobileBtn(flightPad, "←",  UDim2.new(0,0,0.5,-36))
local btnRight2= makeMobileBtn(flightPad, "→",  UDim2.new(1,-72,0.5,-36))
local btnFwd   = makeMobileBtn(flightPad, "⬆",  UDim2.new(0.5,-36,0.5,-36), nil, Color3.fromRGB(20,60,20))
local btnBwd   = makeMobileBtn(flightPad, "⬇",  UDim2.new(0.5,-36,0.5,0),   nil, Color3.fromRGB(60,20,20))

-- Rise / Descend buttons (bottom-right)
local btnRise    = makeMobileBtn(flightGui, "🔼 Rise",    UDim2.new(1,-160,1,-170), UDim2.new(0,150,0,64), Color3.fromRGB(20,60,80))
local btnDescend = makeMobileBtn(flightGui, "🔽 Descend", UDim2.new(1,-160,1,-96),  UDim2.new(0,150,0,64), Color3.fromRGB(60,20,80))
local btnBoost   = makeMobileBtn(flightGui, "⚡ Boost",   UDim2.new(1,-160,1,-260), UDim2.new(0,150,0,64), Color3.fromRGB(80,60,0))

-- Mobile aim button (top-right corner)
local aimGui = Instance.new("ScreenGui")
aimGui.Name           = "AimGui"
aimGui.ResetOnSpawn   = false
aimGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
aimGui.DisplayOrder   = 997
aimGui.IgnoreGuiInset = true
aimGui.Parent         = LocalPlayer.PlayerGui

local aimBtn = makeMobileBtn(aimGui, "🎯", UDim2.new(1,-80,0,20), UDim2.new(0,64,0,64), Color3.fromRGB(50,10,10))
aimBtn.Visible = false

aimBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then mobileAiming=true; aimBtn.BackgroundColor3=Color3.fromRGB(180,30,30) end
end)
aimBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then mobileAiming=false; aimTarget=nil; aimBtn.BackgroundColor3=Color3.fromRGB(50,10,10) end
end)

-- Track held state for mobile flight buttons
local mobileHeld = {
    forward=false, back=false, left=false, right=false,
    up=false, down=false, boost=false,
}
local function wireHold(btn, key)
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then mobileHeld[key]=true end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then mobileHeld[key]=false end end)
end
wireHold(btnFwd,   "forward"); wireHold(btnBwd,  "back")
wireHold(btnLeft2, "left");    wireHold(btnRight2,"right")
wireHold(btnRise,  "up");      wireHold(btnDescend,"down")
wireHold(btnBoost, "boost")

------------------------------------------------------------------------
-- SKYBOX PRESETS
------------------------------------------------------------------------
local SKYBOXES = {
    { Name="🌤  Default Roblox",
      Bk="rbxassetid://91458024",  Dn="rbxassetid://91457980",
      Ft="rbxassetid://91458024",  Lf="rbxassetid://91458024",
      Rt="rbxassetid://91458024",  Up="rbxassetid://91458024",
      Stars=3000, Celestial=true },
    { Name="🌌  Deep Space",
      Bk="rbxassetid://159454286", Dn="rbxassetid://159454286",
      Ft="rbxassetid://159454286", Lf="rbxassetid://159454286",
      Rt="rbxassetid://159454286", Up="rbxassetid://159454286",
      Stars=10000, Celestial=false },
    { Name="🌃  City Night",
      Bk="rbxassetid://144943495", Dn="rbxassetid://144943495",
      Ft="rbxassetid://144943495", Lf="rbxassetid://144943495",
      Rt="rbxassetid://144943495", Up="rbxassetid://144943495",
      Stars=5000, Celestial=true },
    { Name="🌅  Sunset",
      Bk="rbxassetid://32584699",  Dn="rbxassetid://32584699",
      Ft="rbxassetid://32584699",  Lf="rbxassetid://32584699",
      Rt="rbxassetid://32584699",  Up="rbxassetid://32584699",
      Stars=0, Celestial=true },
    { Name="🌊  Ocean Blue",
      Bk="rbxassetid://1012890",   Dn="rbxassetid://1012891",
      Ft="rbxassetid://1012890",   Lf="rbxassetid://1012890",
      Rt="rbxassetid://1012890",   Up="rbxassetid://1012890",
      Stars=1000, Celestial=true },
    { Name="🔴  Red Apocalypse",
      Bk="rbxassetid://358313209", Dn="rbxassetid://358313209",
      Ft="rbxassetid://358313209", Lf="rbxassetid://358313209",
      Rt="rbxassetid://358313209", Up="rbxassetid://358313209",
      Stars=0, Celestial=false },
    { Name="❄️  Arctic Tundra",
      Bk="rbxassetid://159195142", Dn="rbxassetid://159195142",
      Ft="rbxassetid://159195142", Lf="rbxassetid://159195142",
      Rt="rbxassetid://159195142", Up="rbxassetid://159195142",
      Stars=500, Celestial=true },
    { Name="🌫  Foggy Dawn",
      Bk="rbxassetid://225469345", Dn="rbxassetid://225469349",
      Ft="rbxassetid://225469359", Lf="rbxassetid://225469364",
      Rt="rbxassetid://225469372", Up="rbxassetid://225469380",
      Stars=0, Celestial=true },
    { Name="🌙  Midnight Stars",
      Bk="rbxassetid://144933338", Dn="rbxassetid://144931530",
      Ft="rbxassetid://144933262", Lf="rbxassetid://144933244",
      Rt="rbxassetid://144933299", Up="rbxassetid://144931564",
      Stars=8000, Celestial=true },
    { Name="🔥  Lava World",
      Bk="rbxassetid://10258337305", Dn="rbxassetid://10258337305",
      Ft="rbxassetid://10258337305", Lf="rbxassetid://10258337305",
      Rt="rbxassetid://10258337305", Up="rbxassetid://10258337305",
      Stars=0, Celestial=false },
    { Name="✨  Custom (set _G IDs)",
      Bk="", Dn="", Ft="", Lf="", Rt="", Up="",
      Stars=3000, Celestial=true },
}

local skyboxNames      = {}
for _, s in ipairs(SKYBOXES) do table.insert(skyboxNames, s.Name) end
local currentSkyPreset = 1
local customIDs        = { Bk="", Dn="", Ft="", Lf="", Rt="", Up="" }

local function getSkyObject()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then sky=Instance.new("Sky"); sky.Parent=Lighting end
    return sky
end

local function applySkybox(preset)
    local sky=getSkyObject(); local p=SKYBOXES[preset]; if not p then return end
    local function id(field)
        local raw=(preset==#SKYBOXES and customIDs[field]~="") and customIDs[field] or p[field]
        if raw=="" then return "" end
        if raw:match("^rbxassetid://") then return raw end
        return "rbxassetid://"..raw
    end
    sky.SkyboxBk=id("Bk"); sky.SkyboxDn=id("Dn"); sky.SkyboxFt=id("Ft")
    sky.SkyboxLf=id("Lf"); sky.SkyboxRt=id("Rt"); sky.SkyboxUp=id("Up")
    sky.StarCount=p.Stars; sky.CelestialBodiesShown=p.Celestial
    Library:Notify("Skybox: "..p.Name, 2)
end

local function removeSkybox()
    local sky=Lighting:FindFirstChildOfClass("Sky"); if sky then sky:Destroy() end
    Library:Notify("Skybox removed", 2)
end

------------------------------------------------------------------------
-- FLIGHT HELPERS
------------------------------------------------------------------------
local function getCharacter() return LocalPlayer.Character end
local function getHumanoid() local c=getCharacter(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP()      local c=getCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end

local function enableFlight()
    local char=getCharacter(); local hrp=getHRP(); local hum=getHumanoid()
    if not char or not hrp or not hum then return end
    originalWalkSpeed=hum.WalkSpeed; originalJumpPower=hum.JumpPower
    hum.WalkSpeed=0; hum.JumpPower=0; hrp.Velocity=Vector3.zero

    local bv=hrp:FindFirstChild("FlightBodyVelocity") or Instance.new("BodyVelocity")
    bv.Name="FlightBodyVelocity"; bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    bv.Velocity=Vector3.zero; bv.Parent=hrp

    local bg=hrp:FindFirstChild("FlightBodyGyro") or Instance.new("BodyGyro")
    bg.Name="FlightBodyGyro"; bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bg.D=100; bg.CFrame=hrp.CFrame; bg.Parent=hrp

    if isMobile then flightGui.Enabled=true end

    flyConnection=RunService.RenderStepped:Connect(function()
        local h2=getHRP()
        local bv2=h2 and h2:FindFirstChild("FlightBodyVelocity")
        local bg2=h2 and h2:FindFirstChild("FlightBodyGyro")
        if not h2 or not bv2 or not bg2 then return end
        local camCF=Camera.CFrame
        local moveDir=Vector3.zero
        local boosting = isMobile and mobileHeld.boost
            or (not isMobile and UserInputService:IsKeyDown(FLIGHT_KEYS.BOOST))
        local speed=flightSpeed*(boosting and 2.5 or 1)

        local goFwd  = isMobile and mobileHeld.forward  or UserInputService:IsKeyDown(FLIGHT_KEYS.FORWARD)
        local goBack = isMobile and mobileHeld.back      or UserInputService:IsKeyDown(FLIGHT_KEYS.BACK)
        local goLeft = isMobile and mobileHeld.left      or UserInputService:IsKeyDown(FLIGHT_KEYS.LEFT)
        local goRight= isMobile and mobileHeld.right     or UserInputService:IsKeyDown(FLIGHT_KEYS.RIGHT)
        local goUp   = isMobile and mobileHeld.up        or UserInputService:IsKeyDown(FLIGHT_KEYS.UP)
        local goDown = isMobile and mobileHeld.down      or UserInputService:IsKeyDown(FLIGHT_KEYS.DOWN)

        if goFwd   then moveDir=moveDir+camCF.LookVector  end
        if goBack  then moveDir=moveDir-camCF.LookVector  end
        if goRight then moveDir=moveDir+camCF.RightVector end
        if goLeft  then moveDir=moveDir-camCF.RightVector end
        if goUp    then moveDir=moveDir+Vector3.new(0,1,0) end
        if goDown  then moveDir=moveDir-Vector3.new(0,1,0) end

        bv2.Velocity=moveDir.Magnitude>0 and moveDir.Unit*speed or bv2.Velocity*0.75
        bg2.CFrame=CFrame.new(h2.Position,h2.Position+camCF.LookVector)
    end)
end

local function disableFlight()
    if flyConnection then flyConnection:Disconnect(); flyConnection=nil end
    local hrp=getHRP()
    if hrp then
        local bv=hrp:FindFirstChild("FlightBodyVelocity")
        local bg=hrp:FindFirstChild("FlightBodyGyro")
        if bv then bv:Destroy() end; if bg then bg:Destroy() end
        hrp.Velocity=Vector3.zero
    end
    local hum=getHumanoid()
    if hum then hum.WalkSpeed=originalWalkSpeed; hum.JumpPower=originalJumpPower end
    flightGui.Enabled=false
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1); if flightEnabled then enableFlight() end
end)

------------------------------------------------------------------------
-- WALL CHECK
------------------------------------------------------------------------
local function isVisible(targetPart)
    if not targetPart then return false end
    local origin=Camera.CFrame.Position
    local dir=targetPart.Position-origin
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    local ignore={}
    local lc=LocalPlayer.Character; if lc then table.insert(ignore,lc) end
    local tc=targetPart.Parent;    if tc then table.insert(ignore,tc) end
    params.FilterDescendantsInstances=ignore
    return workspace:Raycast(origin,dir.Unit*dir.Magnitude,params)==nil
end

------------------------------------------------------------------------
-- ESP
------------------------------------------------------------------------
local function createESP(player)
    if espObjects[player] then return end
    local sg=Instance.new("ScreenGui")
    sg.Name="ESP_"..player.Name; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=LocalPlayer.PlayerGui

    local bf=Instance.new("Frame")
    bf.Name="Box"; bf.BackgroundTransparency=1; bf.BorderSizePixel=0
    bf.Size=UDim2.new(0,60,0,100); bf.Visible=false; bf.Parent=sg

    local function mkLine(n,aX,aY,sX,sY,pX,pY)
        local f=Instance.new("Frame"); f.Name=n; f.BackgroundColor3=boxColor
        f.BorderSizePixel=0; f.AnchorPoint=Vector2.new(aX,aY)
        f.Size=UDim2.new(sX,0,sY,0); f.Position=UDim2.new(pX,0,pY,0); f.ZIndex=5; f.Parent=bf; return f
    end
    local tl=mkLine("Top",  0,0,1,0,2,0, 0,0); local bl=mkLine("Bot", 0,1,1,0,2,0, 1,0)
    local ll=mkLine("Left", 0,0,0,2,1,0, 0,0); local rl=mkLine("Right",1,0,0,2,1,1, 0,0)

    local function mkLabel(n,sz,anc,pos,font,ts,col)
        local l=Instance.new("TextLabel"); l.Name=n; l.BackgroundTransparency=1
        l.TextColor3=col; l.TextStrokeColor3=Color3.new(0,0,0); l.TextStrokeTransparency=0.4
        l.Font=font; l.TextSize=ts; l.Size=sz; l.AnchorPoint=anc; l.Position=pos
        l.ZIndex=6; l.Text=""; l.Visible=false; l.Parent=bf; return l
    end
    local nl =mkLabel("Name",UDim2.new(1,40,0,18),Vector2.new(0.5,1),UDim2.new(0.5,0,0,-4), Enum.Font.GothamBold,13,nameColor)
    local dl =mkLabel("Dist",UDim2.new(1,40,0,16),Vector2.new(0.5,0),UDim2.new(0.5,0,1, 4), Enum.Font.Gotham,    11,distColor)
    local tml=mkLabel("Team",UDim2.new(1,40,0,14),Vector2.new(0.5,1),UDim2.new(0.5,0,0,-20),Enum.Font.Gotham,    10,Color3.fromRGB(180,230,255))

    local hbg=Instance.new("Frame"); hbg.Name="HBg"; hbg.BackgroundColor3=Color3.fromRGB(30,30,30)
    hbg.BorderSizePixel=0; hbg.AnchorPoint=Vector2.new(0,0); hbg.Size=UDim2.new(0,4,1,0)
    hbg.Position=UDim2.new(1,5,0,0); hbg.ZIndex=5; hbg.Visible=false; hbg.Parent=bf
    local hfl=Instance.new("Frame"); hfl.Name="HFl"; hfl.BackgroundColor3=Color3.fromRGB(50,255,100)
    hfl.BorderSizePixel=0; hfl.AnchorPoint=Vector2.new(0,1); hfl.Size=UDim2.new(1,0,1,0)
    hfl.Position=UDim2.new(0,0,1,0); hfl.ZIndex=6; hfl.Parent=hbg

    espObjects[player]={gui=sg,boxFrame=bf,topLine=tl,bottomLine=bl,leftLine=ll,rightLine=rl,
        nameLabel=nl,distLabel=dl,teamLabel=tml,healthBg=hbg,healthFill=hfl}
end

local function removeESP(p) local o=espObjects[p]; if o then o.gui:Destroy(); espObjects[p]=nil end end
local function removeAllESP() for p in pairs(espObjects) do removeESP(p) end end

------------------------------------------------------------------------
-- AIM TARGET
------------------------------------------------------------------------
local function getClosestTarget()
    local center=Camera.ViewportSize/2; local best=nil; local bestDist=aimFOV
    for _,player in ipairs(Players:GetPlayers()) do
        if player==LocalPlayer then continue end
        if aimIgnoreTeam and isSameTeam(LocalPlayer,player) then continue end
        local char=player.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        local ap=char:FindFirstChild("Head") or hrp
        local sp,on=Camera:WorldToViewportPoint(ap.Position)
        if not on then continue end
        if aimWallCheck and not isVisible(ap) then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<bestDist then bestDist=d; best=char end
    end
    return best
end

------------------------------------------------------------------------
-- FOV Circle
------------------------------------------------------------------------
local fovCircle=Drawing.new("Circle")
fovCircle.Visible=false; fovCircle.Radius=aimFOV
fovCircle.Color=Color3.fromRGB(255,255,255); fovCircle.Thickness=1
fovCircle.Filled=false; fovCircle.Position=Camera.ViewportSize/2

------------------------------------------------------------------------
-- RENDER LOOP
------------------------------------------------------------------------
local BORDER=2
RunService.RenderStepped:Connect(function(dt)
    local localChar=LocalPlayer.Character
    local localHRP=localChar and localChar:FindFirstChild("HumanoidRootPart")
    local center=Camera.ViewportSize/2
    fovCircle.Position=center; fovCircle.Radius=aimFOV

    -- ESP
    for player,obj in pairs(espObjects) do
        local character=player.Character
        local hrp=character and character:FindFirstChild("HumanoidRootPart")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local isTeammate=isSameTeam(LocalPlayer,player)
        local function hideAll()
            obj.boxFrame.Visible=false; obj.nameLabel.Visible=false
            obj.distLabel.Visible=false; obj.healthBg.Visible=false; obj.teamLabel.Visible=false
        end
        if espIgnoreTeam and isTeammate and not trackedPlayers[player.Name] then hideAll(); continue end
        if not hrp or not humanoid or humanoid.Health<=0 then hideAll(); continue end
        local dist=localHRP and (localHRP.Position-hrp.Position).Magnitude or 0
        if dist>maxDistance then hideAll(); continue end
        local cf=hrp.CFrame; local s=Vector3.new(2,3,0)
        local pts={cf*Vector3.new(s.X,s.Y*1.2,0),cf*Vector3.new(-s.X,s.Y*1.2,0),
                   cf*Vector3.new(s.X,-s.Y*1.1,0),cf*Vector3.new(-s.X,-s.Y*1.1,0)}
        local mnX,mnY,mxX,mxY=math.huge,math.huge,-math.huge,-math.huge
        for _,w in ipairs(pts) do
            local sc=Camera:WorldToViewportPoint(w)
            mnX=math.min(mnX,sc.X); mnY=math.min(mnY,sc.Y)
            mxX=math.max(mxX,sc.X); mxY=math.max(mxY,sc.Y)
        end
        local vp=Camera.ViewportSize
        if mxX<0 or mnX>vp.X or mxY<0 or mnY>vp.Y then hideAll(); continue end
        obj.boxFrame.Position=UDim2.new(0,mnX,0,mnY)
        obj.boxFrame.Size=UDim2.new(0,math.max(mxX-mnX,10),0,math.max(mxY-mnY,10))
        obj.boxFrame.Visible=true
        local col=isTeammate and teamBoxColor or boxColor
        for _,ln in ipairs({obj.topLine,obj.bottomLine,obj.leftLine,obj.rightLine}) do ln.BackgroundColor3=col end
        obj.topLine.Size=UDim2.new(1,0,0,BORDER); obj.bottomLine.Size=UDim2.new(1,0,0,BORDER)
        obj.leftLine.Size=UDim2.new(0,BORDER,1,0); obj.rightLine.Size=UDim2.new(0,BORDER,1,0)
        obj.nameLabel.Visible=showNames; obj.nameLabel.TextColor3=nameColor; obj.nameLabel.Text=player.Name
        obj.distLabel.Visible=showDistance; obj.distLabel.TextColor3=distColor
        obj.distLabel.Text=string.format("[%dm]",math.floor(dist))
        obj.healthBg.Visible=showHealth
        if showHealth then
            local pct=math.clamp(humanoid.Health/humanoid.MaxHealth,0,1)
            obj.healthFill.Size=UDim2.new(1,0,pct,0)
            obj.healthFill.BackgroundColor3=Color3.new(math.clamp(2*(1-pct),0,1),math.clamp(2*pct,0,1),0.1)
        end
        local team=player.Team
        if team then obj.teamLabel.Text="["..team.Name.."]"; obj.teamLabel.TextColor3=team.TeamColor.Color; obj.teamLabel.Visible=showNames
        else obj.teamLabel.Visible=false end
    end

    -- Aim Assist
    if not aimEnabled then return end
    local isAiming = isMobile and mobileAiming
        or (not isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
    if not isAiming then aimTarget=nil; return end
    if not aimTarget then
        aimTarget=getClosestTarget()
    else
        local hrp=aimTarget:FindFirstChild("HumanoidRootPart")
        local hum=aimTarget:FindFirstChildOfClass("Humanoid")
        local op=Players:GetPlayerFromCharacter(aimTarget)
        if not hrp or not hum or hum.Health<=0
            or (aimIgnoreTeam and isSameTeam(LocalPlayer,op))
            or (aimWallCheck and not isVisible(aimTarget:FindFirstChild("Head") or hrp))
        then aimTarget=getClosestTarget() end
    end
    if not aimTarget then return end
    local ap=aimTarget:FindFirstChild("Head") or aimTarget:FindFirstChild("HumanoidRootPart")
    if not ap then return end
    local _,on=Camera:WorldToViewportPoint(ap.Position)
    if not on then aimTarget=nil; return end
    local lf=math.clamp(dt*(1/aimSmoothness)*aimStrength,0,1)
    Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,ap.Position),lf)
end)

------------------------------------------------------------------------
-- ESP TAB UI
------------------------------------------------------------------------
LeftGroup:AddToggle("GlobalESP",{Text="ESP All Players",Default=false,Callback=function(v)
    globalESP=v
    if v then for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end
    else for _,p in ipairs(Players:GetPlayers()) do if not trackedPlayers[p.Name] then removeESP(p) end end end
end})
LeftGroup:AddToggle("ESPIgnoreTeam",  {Text="Hide Teammates",  Default=true, Callback=function(v) espIgnoreTeam=v end})
LeftGroup:AddToggle("ShowNames",      {Text="Show Names",      Default=true, Callback=function(v) showNames=v    end})
LeftGroup:AddToggle("ShowHealth",     {Text="Show Health Bar", Default=true, Callback=function(v) showHealth=v   end})
LeftGroup:AddToggle("ShowDistance",   {Text="Show Distance",   Default=true, Callback=function(v) showDistance=v end})
LeftGroup:AddSlider("MaxDist",{Text="Max Distance",Default=500,Min=50,Max=2000,Rounding=0,Callback=function(v) maxDistance=v end})
LeftGroup:AddLabel("Enemy Box Color");    LeftGroup:AddColorpicker("BoxColor",    {Default=boxColor,    Callback=function(v) boxColor=v     end})
LeftGroup:AddLabel("Teammate Box Color"); LeftGroup:AddColorpicker("TeamBoxColor",{Default=teamBoxColor,Callback=function(v) teamBoxColor=v end})
LeftGroup:AddLabel("Name Color");         LeftGroup:AddColorpicker("NameColor",   {Default=nameColor,   Callback=function(v) nameColor=v    end})
LeftGroup:AddLabel("Distance Color");     LeftGroup:AddColorpicker("DistColor",   {Default=distColor,   Callback=function(v) distColor=v    end})

local selectedPlayer=nil
local playerDropdown=RightGroup:AddDropdown("PlayerDropdown",{Values={},Default=1,Text="Select Player",Callback=function(v) selectedPlayer=v end})
local function refreshDropdown()
    local names={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(names,p.Name) end end
    playerDropdown:SetValues(names)
end
RightGroup:AddButton("Refresh List",refreshDropdown)
RightGroup:AddButton("Enable ESP on Selected",function()
    if not selectedPlayer then return end; trackedPlayers[selectedPlayer]=true
    local p=Players:FindFirstChild(selectedPlayer); if p then createESP(p) end
end)
RightGroup:AddButton("Remove ESP on Selected",function()
    if not selectedPlayer then return end; trackedPlayers[selectedPlayer]=nil
    local p=Players:FindFirstChild(selectedPlayer); if p and not globalESP then removeESP(p) end
end)
RightGroup:AddButton("Remove All ESP",function() trackedPlayers={}; removeAllESP() end)

------------------------------------------------------------------------
-- AIM ASSIST TAB UI
------------------------------------------------------------------------
local AimGroup    = Tabs.AimAssist:AddLeftGroupbox("Aim Assist")
local AimFOVGroup = Tabs.AimAssist:AddRightGroupbox("FOV & Target")

AimGroup:AddToggle("AimEnabled",{Text="Enable Aim Assist",Default=false,Callback=function(v)
    aimEnabled=v; fovCircle.Visible=v and not isMobile
    aimBtn.Visible=v and isMobile
    if not v then aimTarget=nil end
end})
AimGroup:AddToggle("AimIgnoreTeam",{Text="Ignore Teammates",Default=true,Callback=function(v) aimIgnoreTeam=v; aimTarget=nil end})
AimGroup:AddToggle("AimWallCheck",{Text="Wall Check",Default=true,Callback=function(v) aimWallCheck=v; aimTarget=nil end})
AimGroup:AddSlider("AimStrength",{Text="Strength",Default=1,Min=1,Max=10,Rounding=1,Suffix="x",Callback=function(v) aimStrength=v end})
AimGroup:AddSlider("AimSmoothness",{Text="Smoothness",Default=5,Min=1,Max=10,Rounding=1,Callback=function(v) aimSmoothness=v*0.03 end})
if isMobile then
    AimGroup:AddLabel("📱 Hold the 🎯 button to aim")
else
    AimGroup:AddLabel("Hold RMB to activate aim")
end
AimFOVGroup:AddSlider("AimFOV",{Text="FOV Radius (px)",Default=120,Min=30,Max=400,Rounding=0,Callback=function(v) aimFOV=v; fovCircle.Radius=v end})
AimFOVGroup:AddLabel("FOV Circle Color"); AimFOVGroup:AddColorpicker("FOVColor",{Default=Color3.fromRGB(255,255,255),Callback=function(v) fovCircle.Color=v end})
AimFOVGroup:AddToggle("ShowFOV",{Text="Show FOV Circle",Default=true,Callback=function(v) fovCircle.Visible=v and aimEnabled and not isMobile end})
AimFOVGroup:AddToggle("HeadshotMode",{Text="Headshot Mode",Default=true,Callback=function(v) _G.headshotMode=v end})

------------------------------------------------------------------------
-- FLIGHT TAB UI
------------------------------------------------------------------------
local FlightGroup     = Tabs.Flight:AddLeftGroupbox("Flight Controls")
local FlightInfoGroup = Tabs.Flight:AddRightGroupbox("Keybinds")

FlightGroup:AddToggle("FlightEnabled",{Text="Enable Flight",Default=false,Callback=function(v)
    flightEnabled=v; if v then enableFlight() else disableFlight() end
end})
FlightGroup:AddSlider("FlightSpeed",{Text="Flight Speed",Default=50,Min=10,Max=300,Rounding=0,Suffix=" u/s",Callback=function(v) flightSpeed=v end})
FlightGroup:AddLabel("Boost: 2.5x speed")
FlightGroup:AddButton("Teleport Up 50",function() local h=getHRP(); if h then h.CFrame=h.CFrame+Vector3.new(0,50,0) end end)
FlightGroup:AddButton("Return to Ground",function()
    local char=getCharacter(); local hrp=getHRP(); if not hrp then return end
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={char}
    local res=workspace:Raycast(hrp.Position,Vector3.new(0,-5000,0),rp)
    if res then hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0)) end
    if flightEnabled then flightEnabled=false; disableFlight(); Library:Notify("Landed.",2) end
end)

if isMobile then
    FlightInfoGroup:AddLabel("📱 Use on-screen pad to fly")
    FlightInfoGroup:AddLabel("⬆ ⬇  —  Forward / Back")
    FlightInfoGroup:AddLabel("← →  —  Strafe left / right")
    FlightInfoGroup:AddLabel("🔼 🔽  —  Rise / Descend")
    FlightInfoGroup:AddLabel("⚡  —  Speed boost (2.5x)")
else
    FlightInfoGroup:AddLabel("W/A/S/D  —  Direction")
    FlightInfoGroup:AddLabel("Space    —  Fly up")
    FlightInfoGroup:AddLabel("L-Ctrl   —  Fly down")
    FlightInfoGroup:AddLabel("L-Shift  —  Boost (2.5x)")
end
FlightInfoGroup:AddLabel("─────────────────────")
FlightInfoGroup:AddLabel("Camera-relative movement.")

------------------------------------------------------------------------
-- SKYBOX TAB UI
------------------------------------------------------------------------
local SkyGroup    = Tabs.Skybox:AddLeftGroupbox("Presets")
local SkySettings = Tabs.Skybox:AddLeftGroupbox("Settings")
local SkyCustom   = Tabs.Skybox:AddRightGroupbox("Custom IDs")

SkyGroup:AddToggle("SkyboxEnabled",{Text="Enable Custom Skybox",Default=false,Callback=function(v)
    if v then applySkybox(currentSkyPreset) else removeSkybox() end
end})
SkyGroup:AddDropdown("SkyboxPreset",{Values=skyboxNames,Default=1,Text="Select Preset",Callback=function(v)
    for i,name in ipairs(skyboxNames) do if name==v then currentSkyPreset=i; break end end
    if Lighting:FindFirstChildOfClass("Sky") then applySkybox(currentSkyPreset) end
end})
SkyGroup:AddButton("Apply Preset",function() applySkybox(currentSkyPreset) end)
SkyGroup:AddButton("Remove Skybox",function() removeSkybox() end)
SkySettings:AddSlider("StarCount",{Text="Star Count",Default=3000,Min=0,Max=15000,Rounding=0,Callback=function(v)
    local sky=Lighting:FindFirstChildOfClass("Sky"); if sky then sky.StarCount=v end
    if SKYBOXES[currentSkyPreset] then SKYBOXES[currentSkyPreset].Stars=v end
end})
SkySettings:AddToggle("ShowCelestial",{Text="Show Sun/Moon/Stars",Default=true,Callback=function(v)
    local sky=Lighting:FindFirstChildOfClass("Sky"); if sky then sky.CelestialBodiesShown=v end
    if SKYBOXES[currentSkyPreset] then SKYBOXES[currentSkyPreset].Celestial=v end
end})
SkyCustom:AddLabel("In executor console set:")
SkyCustom:AddLabel('_G.skyBk/Dn/Ft/Lf/Rt/Up')
SkyCustom:AddLabel('= "rbxassetid://ID"')
SkyCustom:AddLabel("─────────────────────")
SkyCustom:AddButton("Apply Custom IDs",function()
    customIDs.Bk=tostring(_G.skyBk or ""); customIDs.Dn=tostring(_G.skyDn or "")
    customIDs.Ft=tostring(_G.skyFt or ""); customIDs.Lf=tostring(_G.skyLf or "")
    customIDs.Rt=tostring(_G.skyRt or ""); customIDs.Up=tostring(_G.skyUp or "")
    currentSkyPreset=#SKYBOXES; applySkybox(currentSkyPreset)
end)
SkyCustom:AddButton("Single ID → All Faces",function()
    local id=tostring(_G.skyBk or "")
    if id=="" then Library:Notify("Set _G.skyBk first",3); return end
    for k in pairs(customIDs) do customIDs[k]=id end
    currentSkyPreset=#SKYBOXES; applySkybox(currentSkyPreset)
end)

------------------------------------------------------------------------
-- CURRENCY TAB UI
------------------------------------------------------------------------
local CurrencyGroup   = Tabs.Currency:AddLeftGroupbox("Set Currency")
local CurrTargetGroup = Tabs.Currency:AddRightGroupbox("Target Player")

local currencyAmount   = 1000
local currencyStatName = "Cash"
local currencyTarget   = "Everyone"

CurrencyGroup:AddSlider("CurrencyAmount",{Text="Amount",Default=1000,Min=0,Max=1000000,Rounding=0,Callback=function(v) currencyAmount=v end})
CurrencyGroup:AddLabel('_G.statName = "Cash"')
CurrencyGroup:AddButton("Refresh Stat Name",function()
    if _G.statName and _G.statName~="" then
        currencyStatName=tostring(_G.statName)
        Library:Notify("Stat: "..currencyStatName,3)
    else Library:Notify("Set _G.statName first.",3) end
end)

local currDropdown=CurrTargetGroup:AddDropdown("CurrencyTarget",{Values={"Everyone"},Default=1,Text="Select Target",Callback=function(v) currencyTarget=v end})
CurrTargetGroup:AddButton("Refresh Players",function()
    local names={"Everyone"}
    for _,p in ipairs(Players:GetPlayers()) do table.insert(names,p.Name) end
    currDropdown:SetValues(names)
end)
CurrTargetGroup:AddButton("Set Currency",function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerCurrencySet")
    if not remote then Library:Notify("Server script missing!",3); return end
    if currencyTarget=="Everyone" then
        for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,currencyStatName,currencyAmount) end
        Library:Notify("Set "..currencyStatName.." for all!",3)
    else remote:FireServer(currencyTarget,currencyStatName,currencyAmount); Library:Notify("Done!",3) end
end)
CurrTargetGroup:AddButton("Reset to 0",function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerCurrencySet"); if not remote then return end
    if currencyTarget=="Everyone" then
        for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,currencyStatName,0) end
    else remote:FireServer(currencyTarget,currencyStatName,0) end
    Library:Notify("Reset "..currencyStatName.."!",3)
end)

------------------------------------------------------------------------
-- PERKS TAB UI
------------------------------------------------------------------------
local PerksGroup = Tabs.Perks:AddLeftGroupbox("Grant Perks")
local PerkTarget = Tabs.Perks:AddRightGroupbox("Target Player")

local perkNames          = {"VIP Speed","Double Jump","VIP Tag","God Mode","Reset Perks"}
local selectedPerk       = perkNames[1]
local selectedPerkTarget = "Everyone"

PerksGroup:AddDropdown("PerkSelect",{Values=perkNames,Default=1,Text="Select Perk",Callback=function(v) selectedPerk=v end})
PerksGroup:AddLabel("Perks run via ServerScript.")

local perkPlayerDrop=PerkTarget:AddDropdown("PerkPlayerSelect",{Values={"Everyone"},Default=1,Text="Select Player",Callback=function(v) selectedPerkTarget=v end})
PerkTarget:AddButton("Refresh Players",function()
    local names={"Everyone"}
    for _,p in ipairs(Players:GetPlayers()) do table.insert(names,p.Name) end
    perkPlayerDrop:SetValues(names)
end)
PerkTarget:AddButton("Grant Perk",function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerGrantPerk")
    if not remote then Library:Notify("Server script missing!",3); return end
    if selectedPerkTarget=="Everyone" then
        for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,selectedPerk) end
        Library:Notify("Granted "..selectedPerk.." to all!",3)
    else remote:FireServer(selectedPerkTarget,selectedPerk); Library:Notify("Granted "..selectedPerk.."!",3) end
end)
PerkTarget:AddButton("Reset All Perks",function()
    local remote=ReplicatedStorage:FindFirstChild("OwnerGrantPerk"); if not remote then return end
    for _,p in ipairs(Players:GetPlayers()) do remote:FireServer(p.Name,"Reset Perks") end
    Library:Notify("All perks reset.",3)
end)

------------------------------------------------------------------------
-- Player events
------------------------------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
    trackedPlayers[player.Name]=nil; removeESP(player)
end)
Players.PlayerAdded:Connect(function(player)
    if globalESP or trackedPlayers[player.Name] then
        player.CharacterAdded:Connect(function() task.wait(0.5); createESP(player) end)
        createESP(player)
    end
end)

------------------------------------------------------------------------
-- Theme / Save
------------------------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.ESP)
ThemeManager:ApplyToTab(Tabs.ESP)

refreshDropdown()
Library:Notify("👑 Owner Panel Loaded!", 3)
