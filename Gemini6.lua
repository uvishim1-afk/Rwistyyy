-- WindUI Mobile Library Bootstrap
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Twisted V6",
    Icon = "rbxassetid://4370317228",
    Author = "by Gemini",
    Folder = "TwistedConfigs"
})

-- State Variables
local globalESP = false
local showNames = true
local showBoxes = true
local aimbotEnabled = false
local smoothness = 5
local walkspeed = 16
local jumppower = 50

-- Create Main Channels
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Utilities", Icon = "sliders" })

------------------------------------------------------------------------
-- COMBAT INTERFACE
------------------------------------------------------------------------
CombatTab:Toggle({
    Title = "Camera Aimbot",
    Desc = "Locks camera tracking onto closest player head",
    Value = false,
    Callback = function(state) aimbotEnabled = state end
})

CombatTab:Slider({
    Title = "Aim Smoothness",
    Desc = "Higher value means slower, safer tracking",
    Min = 1,
    Max = 10,
    Value = 5,
    Callback = function(val) smoothness = val end
})

------------------------------------------------------------------------
-- VISUALS INTERFACE
------------------------------------------------------------------------
VisualsTab:Toggle({
    Title = "Master ESP System",
    Desc = "Highlights player frames through geometry",
    Value = false,
    Callback = function(state) globalESP = state end
})

VisualsTab:Toggle({
    Title = "Render Player Names",
    Desc = "Displays tracking labels above targets",
    Value = true,
    Callback = function(state) showNames = state end
})

VisualsTab:Toggle({
    Title = "Render 3D Wire Boxes",
    Desc = "Draws visual boundaries around frames",
    Value = true,
    Callback = function(state) showBoxes = state end
})

VisualsTab:Dropdown({
    Title = "Skybox Profile",
    Desc = "Alters map atmosphere presets",
    List = {"Default", "Deep Space", "Sunset", "Apocalypse"},
    Value = "Default",
    Callback = function(choice)
        local Lighting = game:GetService("Lighting")
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        if choice == "Default" then
            sky.SkyboxBk = "rbxassetid://91458024"; sky.SkyboxDn = "rbxassetid://91457980"; sky.SkyboxFt = "rbxassetid://91458024"
        elseif choice == "Deep Space" then
            sky.SkyboxBk = "rbxassetid://159454286"; sky.SkyboxDn = "rbxassetid://159454286"; sky.SkyboxFt = "rbxassetid://159454286"
        elseif choice == "Sunset" then
            sky.SkyboxBk = "rbxassetid://32584699"; sky.SkyboxDn = "rbxassetid://32584699"; sky.SkyboxFt = "rbxassetid://32584699"
        elseif choice == "Apocalypse" then
            sky.SkyboxBk = "rbxassetid://358313209"; sky.SkyboxDn = "rbxassetid://358313209"; sky.SkyboxFt = "rbxassetid://358313209"
        end
    end
})

------------------------------------------------------------------------
-- UTILITIES INTERFACE
------------------------------------------------------------------------
MiscTab:Slider({
    Title = "WalkSpeed Force",
    Desc = "Modifies character translation speed limits",
    Min = 16,
    Max = 150,
    Value = 16,
    Callback = function(val) walkspeed = val end
})

MiscTab:Slider({
    Title = "JumpPower Force",
    Desc = "Modifies vertical impulse limits",
    Min = 50,
    Max = 300,
    Value = 50,
    Callback = function(val) jumppower = val end
})

------------------------------------------------------------------------
-- UNIFIED EXECUTION ENGINE BACKEND
------------------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function getClosestPlayer()
    local closest, maxDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize / 2)).Magnitude
                    if dist < maxDist then closest = p.Character.Head; maxDist = dist end
                end
            end
        end
    end
    return closest
end

local espBoxes = {}
local espNames = {}

local function cleanESP(p)
    if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
    if espNames[p] then espNames[p]:Destroy(); espNames[p] = nil end
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = walkspeed
        hum.JumpPower = jumppower
    end

    if aimbotEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 / smoothness)
        end
    end

    if globalESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                
                if showBoxes then
                    if not espBoxes[p] then
                        local b = Instance.new("BoxHandleAdornment")
                        b.Size = Vector3.new(4, 5.5, 1)
                        b.AlwaysOnTop = true
                        b.Color3 = Color3.fromRGB(140, 80, 255)
                        b.Transparency = 0.6
                        b.ZIndex = 5
                        espBoxes[p] = b
                    end
                    espBoxes[p].Adornee = hrp; espBoxes[p].Parent = hrp
                else
                    if espBoxes[p] then espBoxes[p]:Destroy(); espBoxes[p] = nil end
                end

                if showNames then
                    if not espNames[p] then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 200, 0, 50); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.new(1, 1, 1)
                        lbl.TextStrokeTransparency = 0; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.Text = p.Name
                        espNames[p] = bb
                    end
                    espNames[p].Adornee = hrp; espNames[p].Parent = hrp
                else
                    if espNames[p] then espNames[p]:Destroy(); espNames[p] = nil end
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
