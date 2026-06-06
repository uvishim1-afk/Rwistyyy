--!strict
-- Administrative Utility: Mobile Client ESP & Assist Matrix
-- MUST BE PLACED IN A LOCALSCRIPT (e.g., StarterPlayerScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------
local MAX_AIM_DISTANCE: number = 500 -- Max distance in studs
local AIM_SMOOTHNESS: number = 0.15 -- Smooth camera tracking (0.01 = slow, 1 = instant snap)

--------------------------------------------------------------------------------
-- STATE VARIABLES
--------------------------------------------------------------------------------
local Camera = Workspace.CurrentCamera or Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
local isAiming: boolean = false
local espTracker: { [Player]: Highlight } = {}

--------------------------------------------------------------------------------
-- UI CREATION (Mobile Toggle Button)
--------------------------------------------------------------------------------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminUtilityGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Create Toggle Button adapted for touch interaction
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "TrackToggle"
ToggleButton.Size = UDim2.new(0, 90, 0, 90)
-- Positioned on the right side of the screen, safely above typical mobile jump buttons
ToggleButton.Position = UDim2.new(0.75, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Text = "TRACK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

-- Round the button corners for better mobile UI aesthetics
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

-- Creates a hardware-accelerated outline around targets
local function createESP(player: Player)
	if player == LocalPlayer or espTracker[player] then return end

	local function setupHighlight(character: Model)
		local oldHighlight = character:FindFirstChildOfClass("Highlight")
		if oldHighlight then oldHighlight:Destroy() end

		local highlight = Instance.new("Highlight")
		highlight.Name = "AdminESP"
		highlight.FillColor = Color3.fromRGB(255, 0, 50)
		highlight.FillTransparency = 0.6
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.1
		highlight.Adornee = character
		highlight.Parent = character
		
		espTracker[player] = highlight
	end

	if player.Character then
		setupHighlight(player.Character)
	end

	player.CharacterAdded:Connect(setupHighlight)
end

-- Cleans up tracking instances to prevent memory leaks
local function removeESP(player: Player)
	if espTracker[player] then
		espTracker[player]:Destroy()
		espTracker[player] = nil
	end
end

-- Determines the closest living player to the center of the mobile screen
local function getClosestPlayerToCenter(): Player?
	local closestPlayer: Player? = nil
	local shortestDistance: number = math.huge
	
	-- For mobile, we reference the absolute center of the viewport
	local screenCenter: Vector2 = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local head = character and character:FindFirstChild("Head") :: BasePart
		
		if character and humanoid and head and humanoid.Health > 0 then
			local worldPoint: Vector3 = head.Position
			local screenPosition: Vector3, onScreen: boolean = Camera:WorldToViewportPoint(worldPoint)
			
			if onScreen then
				local distanceToPlayer = (Camera.CFrame.Position - worldPoint).Magnitude
				
				if distanceToPlayer <= MAX_AIM_DISTANCE then
					local target2D: Vector2 = Vector2.new(screenPosition.X, screenPosition.Y)
					local screenDistance: number = (target2D - screenCenter).Magnitude
					
					if screenDistance < shortestDistance then
						shortestDistance = screenDistance
						closestPlayer = player
					end
				end
			end
		end
	end

	return closestPlayer
end

--------------------------------------------------------------------------------
-- EVENT CONNECTIONS & CORE LOOP
--------------------------------------------------------------------------------

-- Mobile Touch Input Connection via Activated event
ToggleButton.Activated:Connect(function()
	isAiming = not isAiming
	if isAiming then
		ToggleButton.Text = "TRACK: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
	else
		ToggleButton.Text = "TRACK: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end
end)

-- Initialize ESP for current and incoming players
for _, player in ipairs(Players:GetPlayers()) do
	createESP(player)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- Main Frame Loop (Calculates and updates tracking every frame)
RunService.RenderStepped:Connect(function(deltaTime: number)
	Camera = Workspace.CurrentCamera -- Ensure viewport matrices are fresh
	
	if isAiming then
		local targetPlayer = getClosestPlayerToCenter()
		if targetPlayer and targetPlayer.Character then
			local head = targetPlayer.Character:FindFirstChild("Head") :: BasePart
			if head then
				-- Smoothly interpolate camera look vector towards target head position
				local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
				Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)
			end
		end
	end
end)
