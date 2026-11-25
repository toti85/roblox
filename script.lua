local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flying = false
local noclip = false
local vertical = 0
local speed = 60
local walkSpeed = nil
local base = nil
local collisions = {}

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 400)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "BRAINROT HUB V2"
title.TextColor3 = Color3.fromRGB(100, 255, 140)
title.TextSize = 21
title.Font = Enum.Font.GothamBold

local function button(text, y, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 38)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = Color3.fromRGB(42, 42, 55)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.Text = text

    Instance.new("UICorner", b)

    b.Activated:Connect(function()
        callback(b)
    end)

    return b
end

local function character()
    local c = player.Character
    if not c then return end

    return c,
        c:FindFirstChild("HumanoidRootPart"),
        c:FindFirstChildOfClass("Humanoid")
end

-- FLY

button("Fly: OFF", 45, function(b)
    flying = not flying
    vertical = 0
    b.Text = flying and "Fly: ON" or "Fly: OFF"

    local c, root = character()

    if root and not flying then
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- NOCLIP

button("Noclip: OFF", 90, function(b)
    noclip = not noclip
    b.Text = noclip and "Noclip: ON" or "Noclip: OFF"

    if not noclip then
        for part, value in pairs(collisions) do
            if part.Parent then
                part.CanCollide = value
            end
        end

        table.clear(collisions)
    end
end)

-- FLY UP

button("Fly UP", 135, function()
    vertical = vertical == 1 and 0 or 1
end)

-- FLY DOWN

button("Fly DOWN", 180, function()
    vertical = vertical == -1 and 0 or -1
end)

-- SET BASE

button("Set Base", 225, function(b)
    local c, root = character()

    if root then
        base = root.CFrame
        b.Text = "BASE SAVED!"
    end
end)

-- TELEPORT TO BASE

button("Teleport to your base", 270, function(b)
    local c, root = character()

    if c and root and base then
        vertical = 0
        c:PivotTo(base)
        root.AssemblyLinearVelocity = Vector3.zero
        b.Text = "Teleported!"

        task.delay(1, function()
            b.Text = "Teleport to your base"
        end)
    else
        b.Text = "Set your base first!"
    end
end)

-- SPEED SET

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.fromOffset(105, 38)
speedBox.Position = UDim2.fromOffset(10, 320)
speedBox.BackgroundColor3 = Color3.fromRGB(42, 42, 55)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.PlaceholderText = "1-200"
speedBox.Text = "16"
speedBox.TextSize = 18
speedBox.Font = Enum.Font.GothamBold
speedBox.ClearTextOnFocus = false

Instance.new("UICorner", speedBox)

local speedButton = button("Speed Set", 320, function(b)
    local value = tonumber(speedBox.Text)
    local c, root, hum = character()

    if value and value >= 1 and value <= 200 and hum then
        walkSpeed = value
        hum.WalkSpeed = value
        b.Text = "Speed: " .. value
    else
        b.Text = "Invalid speed"
    end
end)

speedButton.Size = UDim2.fromOffset(125, 38)
speedButton.Position = UDim2.fromOffset(125, 320)

-- RESPAWN

player.CharacterAdded:Connect(function(c)
    table.clear(collisions)

    local hum = c:WaitForChild("Humanoid", 10)

    if hum and walkSpeed then
        hum.WalkSpeed = walkSpeed
    end
end)

-- MOVEMENT

RunService.PreSimulation:Connect(function()
    local c, root, hum = character()

    if not c or not root or not hum then return end

    if noclip then
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                if collisions[part] == nil then
                    collisions[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end
    end

    if flying then
        root.AssemblyLinearVelocity =
            hum.MoveDirection * speed +
            Vector3.new(0, vertical * speed, 0)
    end
end)
