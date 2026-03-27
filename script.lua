-- Delta GUI: Floating Button + ESP Menu
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local FloatButton = Instance.new("TextButton")
local MenuFrame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local TitleLabel = Instance.new("TextLabel")

-- Variables
local ESPEnabled = false
local ESPConnections = {}
local dragging = false
local dragStart = nil
local startPos = nil

-- Parent to PlayerGui
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "DeltaESP"
ScreenGui.ResetOnSpawn = false

-- Main Floating Button
FloatButton.Name = "FloatButton"
FloatButton.Parent = ScreenGui
FloatButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FloatButton.BorderSizePixel = 0
FloatButton.Position = UDim2.new(0, 20, 0, 20)
FloatButton.Size = UDim2.new(0, 60, 0, 60)
FloatButton.Font = Enum.Font.GothamBold
FloatButton.Text = "ESP"
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.TextScaled = true
FloatButton.Active = true
FloatButton.Draggable = true

-- Button Corner
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 12)
FloatCorner.Parent = FloatButton

-- Button Stroke
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 255, 0)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatButton

-- Main Menu Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

-- Main Frame Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Main Frame Stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.Size = UDim2.new(1, -30, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Delta ESP Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ESP Button
ESPButton.Name = "ESPButton"
ESPButton.Parent = MainFrame
ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPButton.BorderSizePixel = 0
ESPButton.Position = UDim2.new(0, 20, 0, 60)
ESPButton.Size = UDim2.new(1, -40, 0, 50)
ESPButton.Font = Enum.Font.Gotham
ESPButton.Text = "ESP: OFF"
ESPButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ESPButton.TextScaled = true

local ESPButtonCorner = Instance.new("UICorner")
ESPButtonCorner.CornerRadius = UDim.new(0, 8)
ESPButtonCorner.Parent = ESPButton

-- Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- ESP Functions
local function toggleESP()
    ESPEnabled = not ESPEnabled
    
    if ESPEnabled then
        ESPButton.Text = "ESP: ON"
        ESPButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        ESPButton.BackgroundColor3 = Color3.fromRGB(30, 70, 30)
        createESP()
    else
        ESPButton.Text = "ESP: OFF"
        ESPButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        ESPButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        removeESP()
    end
end

local function createHighlight(player)
    if player == LocalPlayer or not player.Character then return end
    
    local char = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Name = "DeltaESP"
    highlight.Parent = char
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    
    ESPConnections[player] = highlight
end

function createESP()
    for _, player in pairs(Players:GetPlayers()) do
        createHighlight(player)
    end
end

function removeESP()
    for player, highlight in pairs(ESPConnections) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPConnections = {}
end

-- Respawn Handler
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            wait(1)
            createHighlight(player)
        end)
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        player.CharacterAdded:Connect(function()
            if ESPEnabled then
                wait(1)
                createHighlight(player)
            end
        end)
    end
end

-- Button Events
FloatButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    FloatButton.Text = MainFrame.Visible and "—" or "ESP"
end)

ESPButton.MouseButton1Click:Connect(toggleESP)
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatButton.Text = "ESP"
end)

-- Animations
local function tweenButton(button, goal)
    TweenService:Create(button, TweenInfo.new(0.2), goal):Play()
end

FloatButton.MouseEnter:Connect(function()
    tweenButton(FloatButton, {Size = UDim2.new(0, 65, 0, 65)})
end)

FloatButton.MouseLeave:Connect(function()
    tweenButton(FloatButton, {Size = UDim2.new(0, 60, 0, 60)})
end)

ESPButton.MouseEnter:Connect(function()
    TweenService:Create(ESPButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -38, 0, 52)}):Play()
end)

ESPButton.MouseLeave:Connect(function()
    TweenService:Create(ESPButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -40, 0, 50)}):Play()
end)

-- Anti-Detection (Hide from some detectors)
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

print("Delta ESP GUI loaded! Drag the button anywhere.")
