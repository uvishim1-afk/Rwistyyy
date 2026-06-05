-- Kavo Self-Contained Mobile Library Engine
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo:CreateWindow("Twisted V6", "Midnight")

-- State Engine Profiles
local globalESP = false
local showNames = true
local showBoxes = true
local aimbotEnabled = false
local smoothness = 5

local walkspeed = 16
local jumppower = 50

-- Create Main Channels
local CombatTab = Window:NewTab("Combat")
local VisualsTab = Window:NewTab("Visuals")
local MiscTab = Window:NewTab("Utilities")

-- Section Dividers
local CombatSection = CombatTab:NewSection("Targeting Assists")
local VisualsSection = VisualsTab:NewSection("Render Systems")
local EnvironmentSection = VisualsTab:NewSection("Map Environments")
local MiscSection = MiscTab:NewSection("Character Modifiers")

------------------------------------------------------------------------
-- COMBAT INTERACTION INTERFACE
------------------------------------------------------------------------
CombatSection:NewToggle("Camera Aimbot", "Locks camera tracking onto target heads", function(state)
    aimbotEnabled = state
end)

CombatSection:NewSlider("Aim Smoothness", "Higher value means slower, safer tracking", 50, 1, function(val)
    smoothness = val
end)

------------------------------------------------------------------------
-- VISUALS INTERACTION INTERFACE
------------------------------------------------------------------------
VisualsSection:NewToggle("Master ESP System", "Highlights player frames through geometry", function(state)
    globalESP = state
end)

VisualsSection:NewToggle("Render Player Names", "Displays tracking labels above targets", function(state)
    showNames = state
end)

VisualsSection:NewToggle("Render 3D Wire Boxes", "Draws visual boundaries around frames", function(state)
    showBoxes = state
end)

EnvironmentSection:NewDropdown("Skybox Profile", "Alters map atmosphere presets", {"Default", "Deep Space", "Sunset", "Apocalypse"}, function(choice)
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
end)

------------------------------------------------------------------------
-- UTILITIES INTERACTION INTERFACE
------------------------------------------------------------------------
MiscSection:NewSlider("WalkSpeed Force", "Modifies character translation speed limits", 150, 16, function(val)
    walkspeed = val
end)

MiscSection:NewSlider("JumpPower Force", "Modifies vertical impulse limits", 300, 50, function(val)
    jumppower = val
end)

------------------------------------------------------------------------
-- HIGH-PERFORMANCE MULTI-THREADED PERFORMANCE BACKEND
------------------------------------------------------------------------
