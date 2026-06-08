-- Dingus Hub - MM2 Script
-- Clean GUI + Role ESP + Aimbot Lock + Auto Shoot
-- Load with a Roblox executor

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DingusHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Dingus Hub"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- ESP Variables
local ESPEnabled = true
local ESPObjects = {}

-- Aimbot Variables
local AimbotEnabled = false
local AutoShootEnabled = false
local TargetLock = nil

-- Role Detection
local function GetRole(player)
    if not player or not player.Character then return "Unknown" end
    local char = player.Character
    local role = "Innocent"
    
    if char:FindFirstChild("Knife") or char:FindFirstChild("Gun") then
        -- Murderer usually has Knife
        if char:FindFirstChild("Knife") then
            role = "Murderer"
        elseif char:FindFirstChild("Gun") then
            role = "Sheriff"
        end
    end
    
    -- Check Backpack
    if player.Backpack:FindFirstChild("Gun") then
        role = "Sheriff"
    elseif player.Backpack:FindFirstChild("Knife") then
        role = "Murderer"
    end
    
    return role
end

-- Create ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local espBox = Drawing.new("Square")
    espBox.Thickness = 2
    espBox.Filled = false
    espBox.Transparency = 1
    espBox.Color = Color3.fromRGB(255, 255, 255)
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    
    ESPObjects[player] = {Box = espBox, Name = nameLabel}
end

local function UpdateESP()
    for player, drawings in pairs(ESPObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local role = GetRole(player)
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                
                local height = (headPos.Y - legPos.Y) * 1.5
                
                drawings.Box.Size = Vector2.new(height / 2, height)
                drawings.Box.Position = Vector2.new(screenPos.X - drawings.Box.Size.X / 2, screenPos.Y - drawings.Box.Size.Y / 2)
                
                if role == "Murderer" then
                    drawings.Box.Color = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then
                    drawings.Box.Color = Color3.fromRGB(0, 100, 255)
                else
                    drawings.Box.Color = Color3.fromRGB(0, 255, 100)
                end
                
                drawings.Name.Text = player.Name .. " [" .. role .. "]"
                drawings.Name.Position = Vector2.new(screenPos.X, screenPos.Y - drawings.Box.Size.Y / 2 - 20)
                drawings.Name.Visible = ESPEnabled
                drawings.Box.Visible = ESPEnabled
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
            end
        else
            if drawings.Box then drawings.Box.Visible = false end
            if drawings.Name then drawings.Name.Visible = false end
        end
    end
end

-- Get Closest Murderer
local function GetClosestMurderer()
    local closest = nil
    local shortestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if GetRole(player) == "Murderer" then
                local dist = (player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Aim at target
local function AimAt(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    local head = target.Character.Head
    local direction = (head.Position - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
end

-- Check if player has gun
local function HasGun()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
end

-- Auto Shoot
local function AutoShoot()
    if not AutoShootEnabled or not TargetLock or not HasGun() then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local gun = char:FindFirstChild("Gun")
    if gun and gun:FindFirstChild("Remote") then
        local args = { TargetLock.Character.Head.Position }
        gun.Remote:FireServer(unpack(args))
    end
end

-- Create Button Helper
local function CreateButton(parent, text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Buttons
CreateButton(MainFrame, "Toggle ESP", 120, function()
    ESPEnabled = not ESPEnabled
end)

CreateButton(MainFrame, "Toggle Aimbot Lock", 175, function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        TargetLock = GetClosestMurderer()
    else
        TargetLock = nil
    end
end)

CreateButton(MainFrame, "Toggle Auto Shoot", 230, function()
    AutoShootEnabled = not AutoShootEnabled
end)

-- Status Label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 290)
Status.BackgroundTransparency = 1
Status.Text = "Status: Idle"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Parent = MainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    if AimbotEnabled and TargetLock and HasGun() then
        AimAt(TargetLock)
        Status.Text = "Aiming at: " .. (TargetLock.Name or "Unknown")
    elseif AutoShootEnabled and TargetLock then
        Status.Text = "Auto Shooting at: " .. (TargetLock.Name or "Unknown")
    else
        Status.Text = "Status: Idle"
    end
    
    AutoShoot()
end)

-- Update target periodically
spawn(function()
    while true do
        wait(0.5)
        if (AimbotEnabled or AutoShootEnabled) then
            TargetLock = GetClosestMurderer()
        end
    end
end)

-- Initialize ESP
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)

print("Dingus Hub Loaded! Enjoy.")
