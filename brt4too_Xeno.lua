--[[
    b4t4too_Xeno.lua
    Developed by Kindo AI
    Version: 2.1 (Xeno Optimized)
    
    Instructions:
    1. Upload this file to GitHub.
    2. Use the 'Raw' link to load via loadstring().
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration & State Management
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    FlyEnabled = false,
    ESPEnabled = false,
    Invisibility = false,
    AntiBanMode = true
}

-- [SECURITY MODULE: PROPERTY MASKING]
local function ApplySecurity(humanoid)
    if not Settings.AntiBanMode or not humanoid then return end
    local mt = getrawmetatable(humanoid)
    local oldIndex = mt.__index
    setmetatable(humanoid, {
        __index = function(t, k)
            if k == "WalkSpeed" then return Settings.WalkSpeed end
            if k == "JumpPower" then return Settings.JumpPower end
            return oldIndex(t, k)
        end,
        __namecall = oldIndex,
        __tostring = oldIndex
    })
end

-- [PHYSICS MODULE: FLY SYSTEM]
local function StartFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 3000
    bg.CFrame = root.CFrame
    bg.Parent = root

    task.spawn(function()
        while Settings.FlyEnabled and char.Parent do
            local direction = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
            
            bv.Velocity = direction * Settings.FlySpeed
            bg.CFrame = camera.CFrame
            RunService.Heartbeat:Wait()
        end
        bv:Destroy()
        bg:Destroy()
    end)
end

-- [GUI CONSTRUCTION]
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- UI Setup
ScreenGui.Name = "b4t4too_UI"
ScreenGui.Parent = (getgenv().CoreGui or game:GetService("CoreGui"))
ScreenGui.ResetOnSpawn = false

MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(1, -240, 1, -340)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "b4t4too_Xeno"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

ScrollFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.Parent = MainFrame

UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [UI UTILS]
local function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.BackgroundColor3 = color
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = text
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = ScrollFrame
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- [FUNCTION IMPLEMENTATION]

-- Speed
CreateButton("Speed: +10", Color3.fromRGB(50, 50, 50), function()
    Settings.WalkSpeed += 10
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        ApplySecurity(LocalPlayer.Character.Humanoid)
    end
end)

-- Jump
CreateButton("Jump: +10", Color3.fromRGB(50, 50, 50), function()
    Settings.JumpPower += 10
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

-- Gravity
CreateButton("Gravity Toggle", Color3.fromRGB(50, 50, 50), function()
    workspace.Gravity = workspace.Gravity == 196.2 and 50 or 196.2
end)

-- Fly
CreateButton("Fly (Toggle)", Color3.fromRGB(70, 30, 30), function()
    Settings.FlyEnabled = not Settings.FlyEnabled
    if Settings.FlyEnabled then StartFly() end
end)

-- ESP
CreateButton("ESP (Players)", Color3.fromRGB(30, 50, 70), function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    task.spawn(function()
        while Settings.ESPEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    if not char:FindFirstChild("b4t4tooESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "b4t4tooESP"
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.6
                        highlight.Parent = char
                    end
                end
            end
            task.wait(2)
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("b4t4tooESP") then
                player.Character.b4t4tooESP:Destroy()
            end
        end
    end)
end)

-- Invisibility
CreateButton("Invisibility", Color3.fromRGB(50, 50, 50), function()
    Settings.Invisibility = not Settings.Invisibility
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = Settings.Invisibility and 0.7 or 0
            end
        end
    end
end)

print("b4t4too_Xeno Loaded Successfully.")
