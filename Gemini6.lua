-- TWISTED V6: NATIVE MOBILE ENGINE (ZERO-EXTERNAL)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration Data
local Config = {
    Aimbot = false, AimSmooth = 0.15, AimFOV = 150,
    ESP = false, ESPNames = true, ESPBoxes = true,
    Speed = 16, Jump = 50,
    SkyIndex = 1
}

local SKIES = {
    {N = "Default", ID = "91458024"},
    {N = "Space", ID = "159454286"},
    {N = "Sunset", ID = "32584699"},
    {N = "Blood", ID = "358313209"}
}

------------------------------------------------------------------------
-- CORE UI ENGINE (NATIVE ONLY)
------------------------------------------------------------------------
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
Screen.Name = "TwistedV6"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 320)
Main.Position = UDim2.new(0.5, -130, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Built-in Roblox dragging for mobile stability

local Corner = Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(100, 80, 200)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "  TWISTED V6 [NATIVE]"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -45)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0,0,0,450)
Container.ScrollBarThickness = 2

local List = Instance.new("UIListLayout", Container)
List.Padding = UDim.new(0, 5)

-- Component Helper
local function CreateButton(txt, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Setup Features
CreateButton("Aimbot: OFF", function(b) 
    Config.Aimbot = not Config.Aimbot 
    Container:FindFirstChild(b).Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF")
end)

CreateButton("ESP: OFF", function(b) 
    Config.ESP = not Config.ESP 
    Container:FindFirstChild(b).Text = "ESP: " .. (Config.ESP and "ON" or "OFF")
end)

CreateButton("Cycle Skybox", function()
    Config.SkyIndex = (Config.SkyIndex % #SKIES) + 1
    local s = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
    s.SkyboxBk = "rbxassetid://"..SKIES[Config.SkyIndex].ID
    s.SkyboxFt = "rbxassetid://"..SKIES[Config.SkyIndex].ID
end)

CreateButton("Speed +10", function() Config.Speed = Config.Speed + 10 end)
CreateButton("Jump +10", function() Config.Jump = Config.Jump + 10 end)
CreateButton("Reset Stats", function() Config.Speed = 16 Config.Jump = 50 end)

------------------------------------------------------------------------
-- CHEAT LOGIC (SEPARATE THREAD)
------------------------------------------------------------------------
task.spawn(function()
    while task.wait() do
        -- Character Mods
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Config.Speed
                char.Humanoid.JumpPower = Config.Jump
            end
        end)

        -- Aimbot Logic
        if Config.Aimbot then
            local target = nil
            local dist = Config.AimFOV
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize/2)).Magnitude
                        if mag < dist then dist = mag target = p.Character.Head end
                    end
                end
            end
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.AimSmooth)
            end
        end

        -- ESP Logic
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local box = hrp:FindFirstChild("T_ESP")
                if Config.ESP then
                    if not box then
                        local b = Instance.new("BoxHandleAdornment", hrp)
                        b.Name = "T_ESP"; b.Size = Vector3.new(4,5,1); b.AlwaysOnTop = true
                        b.ZIndex = 5; b.Transparency = 0.5; b.Color3 = Color3.fromRGB(150, 100, 255)
                        b.Adornee = hrp
                    end
                elseif box then box:Destroy() end
            end
        end
    end
end)

-- Toggle Menu Key (For those with Keyboards)
UserInputService.InputBegan:Connect(function(io, gpe)
    if not gpe and io.KeyCode == Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end
end)
