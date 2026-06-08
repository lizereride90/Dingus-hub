local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ShootButtonLocked = false
local TargetLock = nil

-- Role Detection (Murderer only)
local function GetRole(player)
    if not player or not player.Character then return "Unknown" end
    local char = player.Character
    if char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return "Murderer"
    end
    return "Not Murderer"
end

-- Wall Check
local function IsVisible(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local targetPos = target.Character.Head.Position
    local direction = (targetPos - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    local hit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target.Character})
    return hit == nil or hit:IsDescendantOf(target.Character)
end

-- Prediction (Basic velocity prediction for better accuracy)
local LastPositions = {}
local function GetPredictedPosition(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local root = target.Character.HumanoidRootPart
    local currentPos = root.Position
    
    if not LastPositions[target] then
        LastPositions[target] = currentPos
        return currentPos
    end
    
    local velocity = (currentPos - LastPositions[target]) / 0.016 -- Approx 60 FPS delta
    LastPositions[target] = currentPos
    
    -- Predict ahead (tuned for MM2 gun)
    local predictionTime = 0.15 + (currentPos - Camera.CFrame.Position).Magnitude / 300
    return currentPos + velocity * predictionTime
end

-- Get Closest Murderer
local function GetClosestMurderer()
    local closest = nil
    local shortest = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if GetRole(plr) == "Murderer" and IsVisible(plr) then
                local dist = (plr.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Powerful Aim + Shoot with Prediction
local function PowerfulShoot()
    local target = GetClosestMurderer()
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    
    local predictedPos = GetPredictedPosition(target)
    if not predictedPos then return end
    
    -- Strong Aim (Smooth + Prediction)
    local direction = (predictedPos - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction * 10)
    
    -- Fire Gun
    local char = LocalPlayer.Character
    if char then
        local gun = char:FindFirstChild("Gun")
        if gun and gun:FindFirstChild("Remote") then
            gun.Remote:FireServer(predictedPos)
        end
    end
end

-- Floating Shoot Button (Big & Powerful)
local ShootFrame = Instance.new("Frame")
ShootFrame.Size = UDim2.new(0, 100, 0, 100)
ShootFrame.Position = UDim2.new(0.8, 0, 0.5, 0)
ShootFrame.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
ShootFrame.BorderSizePixel = 0
ShootFrame.Active = true
ShootFrame.Draggable = true
ShootFrame.Parent = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CoreGui") or LocalPlayer.PlayerGui

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(1, 0)
ShootCorner.Parent = ShootFrame

local ShootStroke = Instance.new("UIStroke")
ShootStroke.Color = Color3.fromRGB(255, 255, 100)
ShootStroke.Thickness = 4
ShootStroke.Parent = ShootFrame

local ShootText = Instance.new("TextLabel")
ShootText.Size = UDim2.new(1, 0, 1, 0)
ShootText.BackgroundTransparency = 1
ShootText.Text = "🔫\nSHOOT"
ShootText.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootText.TextScaled = true
ShootText.Font = Enum.Font.GothamBold
ShootText.Parent = ShootFrame

-- Lock Button (Small, near shoot button)
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 110, 0, 35)
LockBtn.Position = UDim2.new(0.8, -10, 0.5, 110)
LockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
LockBtn.Text = "🔒 Lock Position"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.TextScaled = true
LockBtn.Font = Enum.Font.GothamSemibold
LockBtn.Parent = LocalPlayer.PlayerGui

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 8)
LockCorner.Parent = LockBtn

LockBtn.MouseButton1Click:Connect(function()
    ShootButtonLocked = not ShootButtonLocked
    ShootFrame.Draggable = not ShootButtonLocked
    LockBtn.Text = ShootButtonLocked and "🔓 Unlock Position" or "🔒 Lock Position"
end)

-- Shoot on Click (Hold for spam)
ShootFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        PowerfulShoot()
    end
end)

-- Auto spam while holding (for max power)
local holding = false
ShootFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = true
        spawn(function()
            while holding do
                PowerfulShoot()
                wait(0.08) -- Fast fire rate for "guaranteed" feel
            end
        end)
    end
end)

ShootFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = false
    end
end)

print("Dingus Hub Minimal Loaded - Powerful Shoot Button Ready")    
    local nameLabel = Drawing.new("Text")
    nameLabel.Size = 17
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    
    -- Chams (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character or player.CharacterAdded:Wait()
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or player
    
    ESPObjects[player] = {Box = box, Name = nameLabel, Highlight = highlight}
end

local function UpdateESP()
    for player, data in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local role = GetRole(player)
            local root = char.HumanoidRootPart
            local head = char.Head
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen and ESPEnabled then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local height = (headPos.Y - legPos.Y) * 1.6
                
                data.Box.Size = Vector2.new(height / 2, height)
                data.Box.Position = Vector2.new(screenPos.X - data.Box.Size.X/2, screenPos.Y - data.Box.Size.Y/2)
                
                if role == "Murderer" then
                    data.Box.Color = Color3.fromRGB(255, 0, 0)
                    data.Highlight.FillColor = Color3.fromRGB(255, 50, 50)
                elseif role == "Sheriff" then
                    data.Box.Color = Color3.fromRGB(0, 120, 255)
                    data.Highlight.FillColor = Color3.fromRGB(50, 100, 255)
                else
                    data.Box.Color = Color3.fromRGB(0, 255, 100)
                    data.Highlight.FillColor = Color3.fromRGB(50, 255, 120)
                end
                
                data.Name.Text = player.Name .. " [" .. role .. "]"
                data.Name.Position = Vector2.new(screenPos.X, screenPos.Y - data.Box.Size.Y/2 - 22)
                data.Box.Visible = true
                data.Name.Visible = true
            else
                data.Box.Visible = false
                data.Name.Visible = false
            end
        else
            if data.Box then data.Box.Visible = false end
            if data.Name then data.Name.Visible = false end
        end
    end
end

-- Wall Check (Visibility)
local function IsVisible(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local direction = (target.Character.Head.Position - origin).Unit * 500
    local ray = Ray.new(origin, direction)
    local hit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit and hit:IsDescendantOf(target.Character)
end

-- Get Closest Murderer
local function GetClosestMurderer()
    local closest = nil
    local shortest = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if GetRole(plr) == "Murderer" then
                local dist = (plr.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist < shortest and IsVisible(plr) then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Aim + Shoot
local function AimAndShoot()
    local target = GetClosestMurderer()
    if not target or not target.Character then return end
    
    -- Aim
    local head = target.Character.Head
    local direction = (head.Position - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
    
    -- Shoot
    local char = LocalPlayer.Character
    if char then
        local gun = char:FindFirstChild("Gun")
        if gun and gun:FindFirstChild("Remote") then
            gun.Remote:FireServer(head.Position)
        end
    end
end

-- Floating Shoot Button
local ShootFrame = Instance.new("Frame")
ShootFrame.Size = UDim2.new(0, 80, 0, 80)
ShootFrame.Position = UDim2.new(0.85, 0, 0.6, 0)
ShootFrame.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ShootFrame.BorderSizePixel = 0
ShootFrame.Active = true
ShootFrame.Draggable = true
ShootFrame.Visible = true
ShootFrame.Parent = ScreenGui

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(1, 0)
ShootCorner.Parent = ShootFrame

local ShootStroke = Instance.new("UIStroke")
ShootStroke.Color = Color3.fromRGB(255, 255, 255)
ShootStroke.Thickness = 3
ShootStroke.Parent = ShootFrame

local ShootText = Instance.new("TextLabel")
ShootText.Size = UDim2.new(1, 0, 1, 0)
ShootText.BackgroundTransparency = 1
ShootText.Text = "🔫 SHOOT"
ShootText.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootText.TextScaled = true
ShootText.Font = Enum.Font.GothamBold
ShootText.Parent = ShootFrame

-- Lock Button
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 120, 0, 40)
LockBtn.Position = UDim2.new(0, 10, 0, 380)
LockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
LockBtn.Text = "Lock Button Pos"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.TextScaled = true
LockBtn.Font = Enum.Font.GothamSemibold
LockBtn.Parent = MainFrame

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 10)
LockCorner.Parent = LockBtn

LockBtn.MouseButton1Click:Connect(function()
    ShootButtonLocked = not ShootButtonLocked
    ShootFrame.Draggable = not ShootButtonLocked
    LockBtn.Text = ShootButtonLocked and "Unlock Button Pos" or "Lock Button Pos"
end)

-- Shoot Button Click
ShootFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        AimAndShoot()
    end
end)

-- GUI Buttons
local function CreateButton(parent, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 50)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

CreateButton(MainFrame, "Toggle ESP", 100, function()
    ESPEnabled = not ESPEnabled
end)

CreateButton(MainFrame, "Toggle Chams", 160, function()
    ChamsEnabled = not ChamsEnabled
    for _, data in pairs(ESPObjects) do
        if data.Highlight then
            data.Highlight.Enabled = ChamsEnabled
        end
    end
end)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 40)
Status.Position = UDim2.new(0, 15, 0, 280)
Status.BackgroundTransparency = 1
Status.Text = "Ready - Click 🔫 to Shoot"
Status.TextColor3 = Color3.fromRGB(140, 255, 140)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- Initialize
for _, plr in ipairs(Players:GetPlayers()) do
    CreateESP(plr)
end
Players.PlayerAdded:Connect(CreateESP)

print("Dingus Hub Loaded - Beautiful Edition")    
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
