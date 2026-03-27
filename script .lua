local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- EFFECTS
local ColorEffect = Instance.new("ColorCorrectionEffect", Lighting)
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0

-- ESP
local ESPColor = Color3.fromRGB(180, 0, 255)
local ESPEnabled = false
local ESPObjects = {}

-- ESP MODE
local ESPMode = "ALL"
local TargetName = nil

-- FEATURES STATE
local MotionBlurEnabled = false
local FlyEnabled = false
local NoclipEnabled = false
local InfJumpEnabled = false
local SpeedValue = 16
local JumpValue = 50
local FlySpeed = 50
local lastCF = Camera.CFrame
local currentBlur = 0
local flyBody = nil

-- NOTIFICATIONS TABLE
local notifications = {}
local notifY = 20

-- ============================================
-- MOTION BLUR
-- ============================================
RunService.RenderStepped:Connect(function()
    local targetBlur = 0
    if MotionBlurEnabled then
        local delta = (lastCF:Inverse() * Camera.CFrame)
        local _,_,_, r00,r01,r02,r10,r11,r12 = delta:GetComponents()
        local change = math.abs(r01) + math.abs(r02) + math.abs(r10)
        targetBlur = math.clamp(change * 60, 0, 20)
        lastCF = Camera.CFrame
    end
    currentBlur = currentBlur + (targetBlur - currentBlur) * 0.15
    Blur.Size = currentBlur
end)

-- ============================================
-- NOCLIP LOOP
-- ============================================
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================
-- INFINITE JUMP
-- ============================================
UIS.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- FOV
local BaseFOV = 70
Camera.FieldOfView = BaseFOV

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Camera.FieldOfView = BaseFOV
    -- Reset fly on respawn
    if FlyEnabled then
        FlyEnabled = false
        flyBody = nil
    end
end)

-- ============================================
-- COLORS
-- ============================================
local ACCENT       = Color3.fromRGB(138, 43, 226)
local ACCENT_LIGHT = Color3.fromRGB(180, 80, 255)
local ACCENT_DARK  = Color3.fromRGB(90,  20, 160)
local BG_MAIN      = Color3.fromRGB(18,  18,  26)
local BG_PANEL     = Color3.fromRGB(24,  24,  36)
local BG_LEFT      = Color3.fromRGB(20,  20,  30)
local BG_ITEM      = Color3.fromRGB(30,  30,  45)
local TEXT_WHITE    = Color3.new(1, 1, 1)
local TEXT_GREY     = Color3.fromRGB(160, 160, 190)
local GREEN         = Color3.fromRGB(50, 200, 100)
local RED           = Color3.fromRGB(200, 60, 80)

-- ============================================
-- GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "DeltaMenu"

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
local function notify(text, duration, color)
    duration = duration or 3
    color = color or ACCENT_LIGHT

    local notif = Instance.new("Frame", ScreenGui)
    notif.Size = UDim2.new(0, 260, 0, 40)
    notif.Position = UDim2.new(1, 270, 1, -(notifY + 40))
    notif.BackgroundColor3 = BG_PANEL
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    local nc = Instance.new("UICorner", notif)
    nc.CornerRadius = UDim.new(0, 10)
    local ns = Instance.new("UIStroke", notif)
    ns.Color = color
    ns.Thickness = 1.2

    local icon = Instance.new("TextLabel", notif)
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 6, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "◈"
    icon.TextColor3 = color
    icon.TextSize = 14
    icon.ZIndex = 101

    local lbl = Instance.new("TextLabel", notif)
    lbl.Size = UDim2.new(1, -42, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 12
    lbl.TextColor3 = TEXT_WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.ZIndex = 101

    -- Progress bar
    local prog = Instance.new("Frame", notif)
    prog.Size = UDim2.new(1, 0, 0, 2)
    prog.Position = UDim2.new(0, 0, 1, -2)
    prog.BackgroundColor3 = color
    prog.BorderSizePixel = 0
    prog.ZIndex = 101

    -- Slide in
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -275, 1, -(notifY + 40))
    }):Play()

    -- Progress shrink
    TweenService:Create(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()

    notifY = notifY + 50

    task.delay(duration, function()
        local t = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 270, notif.Position.Y.Scale, notif.Position.Y.Offset)
        })
        t:Play()
        t.Completed:Connect(function()
            notif:Destroy()
            notifY = math.max(20, notifY - 50)
        end)
    end)
end

-- ============================================
-- FLOAT BUTTON
-- ============================================
local FloatButton = Instance.new("TextButton", ScreenGui)
FloatButton.Size = UDim2.new(0, 54, 0, 54)
FloatButton.Position = UDim2.new(0, 20, 0, 20)
FloatButton.Text = "◈"
FloatButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
FloatButton.TextSize = 22
FloatButton.BackgroundColor3 = BG_PANEL
FloatButton.TextColor3 = ACCENT_LIGHT
FloatButton.BorderSizePixel = 0
local fbCorner = Instance.new("UICorner", FloatButton)
fbCorner.CornerRadius = UDim.new(1, 0)
local fbStroke = Instance.new("UIStroke", FloatButton)
fbStroke.Color = ACCENT
fbStroke.Thickness = 1.5

-- ============================================
-- MAIN FRAME
-- ============================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 440)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -220)
MainFrame.BackgroundColor3 = BG_MAIN
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.BorderSizePixel = 0
local mfCorner = Instance.new("UICorner", MainFrame)
mfCorner.CornerRadius = UDim.new(0, 14)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = ACCENT_DARK
mfStroke.Thickness = 1.5

-- TITLE BAR
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = BG_PANEL
TitleBar.BorderSizePixel = 0
local tbCorner = Instance.new("UICorner", TitleBar)
tbCorner.CornerRadius = UDim.new(0, 14)
local tbFix = Instance.new("Frame", TitleBar)
tbFix.Size = UDim2.new(1, 0, 0.5, 0)
tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = BG_PANEL
tbFix.BorderSizePixel = 0

local TitleIcon = Instance.new("TextLabel", TitleBar)
TitleIcon.Size = UDim2.new(0, 30, 1, 0)
TitleIcon.Position = UDim2.new(0, 12, 0, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "◈"
TitleIcon.TextColor3 = ACCENT_LIGHT
TitleIcon.TextSize = 18

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Delta Menu v2"
TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
TitleLabel.TextSize = 15
TitleLabel.TextColor3 = TEXT_WHITE
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- VERSION BADGE
local VerBadge = Instance.new("TextLabel", TitleBar)
VerBadge.Size = UDim2.new(0, 40, 0, 18)
VerBadge.Position = UDim2.new(0, 170, 0.5, -9)
VerBadge.BackgroundColor3 = ACCENT_DARK
VerBadge.Text = "v2.0"
VerBadge.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
VerBadge.TextSize = 9
VerBadge.TextColor3 = ACCENT_LIGHT
VerBadge.BorderSizePixel = 0
local vbc = Instance.new("UICorner", VerBadge)
vbc.CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.Text = "✕"
CloseBtn.TextSize = 13
CloseBtn.BackgroundColor3 = RED
CloseBtn.TextColor3 = TEXT_WHITE
CloseBtn.BorderSizePixel = 0
local cbCorner = Instance.new("UICorner", CloseBtn)
cbCorner.CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ============================================
-- DRAG SYSTEM
-- ============================================
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(MainFrame, TitleBar)
makeDraggable(FloatButton)

-- ============================================
-- PANELS
-- ============================================
local LeftPanel = Instance.new("Frame", MainFrame)
LeftPanel.Size = UDim2.new(0, 130, 1, -44)
LeftPanel.Position = UDim2.new(0, 0, 0, 44)
LeftPanel.BackgroundColor3 = BG_LEFT
LeftPanel.BorderSizePixel = 0
local lpCorner = Instance.new("UICorner", LeftPanel)
lpCorner.CornerRadius = UDim.new(0, 14)
local lpFix = Instance.new("Frame", LeftPanel)
lpFix.Size = UDim2.new(0.5, 0, 1, 0)
lpFix.Position = UDim2.new(0.5, 0, 0, 0)
lpFix.BackgroundColor3 = BG_LEFT
lpFix.BorderSizePixel = 0

local SettingsFrame = Instance.new("Frame", MainFrame)
SettingsFrame.Size = UDim2.new(1, -140, 1, -54)
SettingsFrame.Position = UDim2.new(0, 138, 0, 50)
SettingsFrame.BackgroundColor3 = BG_PANEL
SettingsFrame.Visible = false
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ClipsDescendants = true
local sfCorner = Instance.new("UICorner", SettingsFrame)
sfCorner.CornerRadius = UDim.new(0, 12)
local sfStroke = Instance.new("UIStroke", SettingsFrame)
sfStroke.Color = ACCENT_DARK
sfStroke.Thickness = 1

-- ANIMATE OPEN/CLOSE SETTINGS
local function showSettings(show)
    if show then
        SettingsFrame.Visible = true
        SettingsFrame.BackgroundTransparency = 1
        TweenService:Create(SettingsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 0}):Play()
    else
        local t = TweenService:Create(SettingsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
        t:Play()
        t.Completed:Connect(function() SettingsFrame.Visible = false end)
    end
end

-- ============================================
-- CREATE ALL PANELS
-- ============================================
local ESPPanel = Instance.new("Frame", SettingsFrame)
ESPPanel.Size = UDim2.new(1, 0, 1, 0)
ESPPanel.Visible = false
ESPPanel.BackgroundTransparency = 1

local DisplayPanel = Instance.new("Frame", SettingsFrame)
DisplayPanel.Size = UDim2.new(1, 0, 1, 0)
DisplayPanel.Visible = false
DisplayPanel.BackgroundTransparency = 1

local PlayerPanel = Instance.new("Frame", SettingsFrame)
PlayerPanel.Size = UDim2.new(1, 0, 1, 0)
PlayerPanel.Visible = false
PlayerPanel.BackgroundTransparency = 1

local TeleportPanel = Instance.new("Frame", SettingsFrame)
TeleportPanel.Size = UDim2.new(1, 0, 1, 0)
TeleportPanel.Visible = false
TeleportPanel.BackgroundTransparency = 1

local MiscPanel = Instance.new("Frame", SettingsFrame)
MiscPanel.Size = UDim2.new(1, 0, 1, 0)
MiscPanel.Visible = false
MiscPanel.BackgroundTransparency = 1

-- ============================================
-- NAV BUTTON CREATOR
-- ============================================
local navY = 12
local activeNavBtn = nil

local function createNavBtn(labelText)
    local btn = Instance.new("TextButton", LeftPanel)
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, navY)
    btn.Text = ""
    btn.BackgroundColor3 = BG_ITEM
    btn.BorderSizePixel = 0
    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 12
    lbl.TextColor3 = TEXT_GREY
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local accent = Instance.new("Frame", btn)
    accent.Size = UDim2.new(0, 3, 0.55, 0)
    accent.Position = UDim2.new(0, 0, 0.225, 0)
    accent.BackgroundColor3 = ACCENT_LIGHT
    accent.BorderSizePixel = 0
    local ac = Instance.new("UICorner", accent)
    ac.CornerRadius = UDim.new(0, 4)
    accent.Visible = false

    navY = navY + 42

    local function setActive(active)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = active and ACCENT_DARK or BG_ITEM
        }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.2), {
            TextColor3 = active and TEXT_WHITE or TEXT_GREY
        }):Play()
        accent.Visible = active
    end

    -- Hover
    btn.MouseEnter:Connect(function()
        if accent.Visible then return end
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38,38,55)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if accent.Visible then return end
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_ITEM}):Play()
    end)

    return btn, setActive
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================
local function addESP(player)
    if player == LocalPlayer or not player.Character then return end
    if ESPMode == "ALONE" then
        if not TargetName or player.Name:lower() ~= TargetName:lower() then return end
    end
    if player.Character:FindFirstChild("DeltaESP") then return end
    local h = Instance.new("Highlight")
    h.Name = "DeltaESP"
    h.Parent = player.Character
    h.FillColor = ESPColor
    h.FillTransparency = 0.4
    h.OutlineColor = ESPColor
    h.OutlineTransparency = 0.2
    ESPObjects[player] = h
end

local function removeESP()
    for _,v in pairs(ESPObjects) do if v then v:Destroy() end end
    ESPObjects = {}
end

local function applyESP()
    removeESP()
    if ESPEnabled then
        for _,p in ipairs(Players:GetPlayers()) do
            task.spawn(function() addESP(p) end)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then addESP(p) end
    end)
end)

-- ============================================
-- FLY SYSTEM
-- ============================================
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Remove old
    if hrp:FindFirstChild("DeltaFlyVel") then hrp.DeltaFlyVel:Destroy() end
    if hrp:FindFirstChild("DeltaFlyGyro") then hrp.DeltaFlyGyro:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "DeltaFlyVel"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name = "DeltaFlyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.D = 100
    bg.Parent = hrp

    flyBody = {vel = bv, gyro = bg}
end

local function stopFly()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp:FindFirstChild("DeltaFlyVel") then hrp.DeltaFlyVel:Destroy() end
            if hrp:FindFirstChild("DeltaFlyGyro") then hrp.DeltaFlyGyro:Destroy() end
        end
    end
    flyBody = nil
end

RunService.RenderStepped:Connect(function()
    if FlyEnabled and flyBody and flyBody.vel then
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            dir = dir.Unit
        end

        flyBody.vel.Velocity = dir * FlySpeed
        flyBody.gyro.CFrame = Camera.CFrame
    end
end)

-- ============================================
-- UI HELPER FUNCTIONS
-- ============================================
local function sectionLabel(parent, text, y)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    lbl.TextSize = 10
    lbl.TextColor3 = ACCENT_LIGHT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- ============================================
-- TOGGLE BUTTON
-- ============================================
local function createToggle(parent, title, y, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 34)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = BG_ITEM
    frame.BorderSizePixel = 0
    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 12
    lbl.TextColor3 = TEXT_WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBG = Instance.new("Frame", frame)
    toggleBG.Size = UDim2.new(0, 40, 0, 20)
    toggleBG.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBG.BackgroundColor3 = default and GREEN or Color3.fromRGB(60, 60, 80)
    toggleBG.BorderSizePixel = 0
    local tbc = Instance.new("UICorner", toggleBG)
    tbc.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggleBG)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = TEXT_WHITE
    knob.BorderSizePixel = 0
    local kc = Instance.new("UICorner", knob)
    kc.CornerRadius = UDim.new(1, 0)

    local enabled = default or false

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggleBG, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and GREEN or Color3.fromRGB(60, 60, 80)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        callback(enabled)
    end)

    return btn
end

-- ============================================
-- SLIDER
-- ============================================
local function createSlider(parent, title, y, min, max, default, callback)
    sectionLabel(parent, title, y)

    local norm = (default - min) / (max - min)

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 6)
    frame.Position = UDim2.new(0, 10, 0, y + 22)
    frame.BackgroundColor3 = BG_ITEM
    frame.BorderSizePixel = 0
    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", frame)
    fill.Size = UDim2.new(norm, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT_LIGHT
    fill.BorderSizePixel = 0
    local fillC = Instance.new("UICorner", fill)
    fillC.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", frame)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(norm, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    local kc = Instance.new("UICorner", knob)
    kc.CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob)
    ks.Color = ACCENT
    ks.Thickness = 1.5

    local valLabel = Instance.new("TextLabel", parent)
    valLabel.Size = UDim2.new(0, 50, 0, 16)
    valLabel.Position = UDim2.new(1, -60, 0, y)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = ACCENT_LIGHT
    valLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    valLabel.TextSize = 10
    valLabel.Text = tostring(math.floor(default))
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        local val = min + pos * (max - min)
        valLabel.Text = tostring(math.floor(val))
        callback(val)
    end

    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; MainFrame.Active = false; update(i)
        end
    end)
    frame.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false; MainFrame.Active = true
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
end

-- ============================================
-- RGB SLIDER (for ESP)
-- ============================================
local function createRGBSlider(parent, name, y)
    sectionLabel(parent, name, y)

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 6)
    frame.Position = UDim2.new(0, 10, 0, y + 22)
    frame.BackgroundColor3 = BG_ITEM
    frame.BorderSizePixel = 0
    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(1, 0)

    local initVal = name == "R" and ESPColor.R or name == "G" and ESPColor.G or ESPColor.B

    local fill = Instance.new("Frame", frame)
    fill.Size = UDim2.new(initVal, 0, 1, 0)
    fill.BackgroundColor3 = name == "R" and Color3.fromRGB(220,50,80) or name == "G" and Color3.fromRGB(50,200,100) or Color3.fromRGB(50,100,255)
    fill.BorderSizePixel = 0
    local fillC = Instance.new("UICorner", fill)
    fillC.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", frame)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(initVal, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    local kc = Instance.new("UICorner", knob)
    kc.CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob)
    ks.Color = ACCENT
    ks.Thickness = 1.5

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        local val = math.floor(pos * 255)
        if name == "R" then ESPColor = Color3.fromRGB(val, ESPColor.G*255, ESPColor.B*255) end
        if name == "G" then ESPColor = Color3.fromRGB(ESPColor.R*255, val, ESPColor.B*255) end
        if name == "B" then ESPColor = Color3.fromRGB(ESPColor.R*255, ESPColor.G*255, val) end
        for _,v in pairs(ESPObjects) do
            if v then
                v.FillColor = ESPColor
                v.OutlineColor = ESPColor
            end
        end
    end

    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; MainFrame.Active = false; update(i)
        end
    end)
    frame.InputEnded:Connect(function()
        dragging = false; MainFrame.Active = true
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging then update(i) end
    end)
end

-- ============================================
-- ACTION BUTTON
-- ============================================
local function createActionButton(parent, title, y, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = title
    btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    btn.TextSize = 12
    btn.BackgroundColor3 = color or BG_ITEM
    btn.TextColor3 = TEXT_WHITE
    btn.BorderSizePixel = 0
    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = ACCENT_DARK
    bs.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT_DARK}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or BG_ITEM}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================
-- ESP PANEL CONTENT
-- ============================================
sectionLabel(ESPPanel, "ESP Color", 10)
createRGBSlider(ESPPanel, "R", 30)
createRGBSlider(ESPPanel, "G", 68)
createRGBSlider(ESPPanel, "B", 106)

local ModeButton = Instance.new("TextButton", ESPPanel)
ModeButton.Size = UDim2.new(1, -20, 0, 34)
ModeButton.Position = UDim2.new(0, 10, 0, 150)
ModeButton.Text = "Mode: ALL"
ModeButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
ModeButton.TextSize = 13
ModeButton.BackgroundColor3 = BG_ITEM
ModeButton.TextColor3 = TEXT_WHITE
ModeButton.BorderSizePixel = 0
local mbC = Instance.new("UICorner", ModeButton)
mbC.CornerRadius = UDim.new(0, 8)
local mbS = Instance.new("UIStroke", ModeButton)
mbS.Color = ACCENT_DARK
mbS.Thickness = 1

local NameBox = Instance.new("TextBox", ESPPanel)
NameBox.Size = UDim2.new(1, -20, 0, 34)
NameBox.Position = UDim2.new(0, 10, 0, 193)
NameBox.PlaceholderText = "Player name..."
NameBox.Text = ""
NameBox.Visible = false
NameBox.BackgroundColor3 = BG_ITEM
NameBox.TextColor3 = TEXT_WHITE
NameBox.PlaceholderColor3 = TEXT_GREY
NameBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
NameBox.TextSize = 13
NameBox.BorderSizePixel = 0
local nbC = Instance.new("UICorner", NameBox)
nbC.CornerRadius = UDim.new(0, 8)
local nbS = Instance.new("UIStroke", NameBox)
nbS.Color = ACCENT
nbS.Thickness = 1

ModeButton.MouseButton1Click:Connect(function()
    if ESPMode == "ALL" then
        ESPMode = "ALONE"
        ModeButton.Text = "Mode: ALONE"
        NameBox.Visible = true
        TweenService:Create(mbS, TweenInfo.new(0.2), {Color = ACCENT_LIGHT}):Play()
        notify("ESP mode: ALONE", 2)
    else
        ESPMode = "ALL"
        ModeButton.Text = "Mode: ALL"
        NameBox.Visible = false
        TargetName = nil
        TweenService:Create(mbS, TweenInfo.new(0.2), {Color = ACCENT_DARK}):Play()
        notify("ESP mode: ALL", 2)
    end
    applyESP()
end)

NameBox.FocusLost:Connect(function()
    TargetName = NameBox.Text
    applyESP()
    if TargetName and TargetName ~= "" then
        notify("ESP target: " .. TargetName, 2)
    end
end)

-- ============================================
-- DISPLAY PANEL CONTENT
-- ============================================
createSlider(DisplayPanel, "Saturation", 10, 0, 2, 1, function(v)
    ColorEffect.Saturation = v - 1
end)
createSlider(DisplayPanel, "Brightness", 60, -1, 1, 0, function(v)
    ColorEffect.Brightness = v
end)
createSlider(DisplayPanel, "Contrast", 110, 0, 2, 0, function(v)
    ColorEffect.Contrast = v
end)

createToggle(DisplayPanel, "Motion Blur", 170, false, function(v)
    MotionBlurEnabled = v
    if not v then Blur.Size = 0; currentBlur = 0 end
    notify(v and "Motion Blur ON" or "Motion Blur OFF", 2, v and GREEN or RED)
end)

createSlider(DisplayPanel, "Field of View", 215, 70, 120, 70, function(v)
    Camera.FieldOfView = v
    BaseFOV = v
end)

-- ============================================
-- PLAYER PANEL CONTENT
-- ============================================
sectionLabel(PlayerPanel, "Movement", 10)

createSlider(PlayerPanel, "Walk Speed", 30, 16, 200, 16, function(v)
    SpeedValue = v
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

createSlider(PlayerPanel, "Jump Power", 85, 50, 300, 50, function(v)
    JumpValue = v
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)

sectionLabel(PlayerPanel, "Abilities", 140)

createToggle(PlayerPanel, "Fly", 160, false, function(v)
    FlyEnabled = v
    if v then
        startFly()
        notify("Fly ENABLED", 2, GREEN)
    else
        stopFly()
        notify("Fly DISABLED", 2, RED)
    end
end)

createSlider(PlayerPanel, "Fly Speed", 205, 10, 200, 50, function(v)
    FlySpeed = v
end)

createToggle(PlayerPanel, "Noclip", 265, false, function(v)
    NoclipEnabled = v
    notify(v and "Noclip ENABLED" or "Noclip DISABLED", 2, v and GREEN or RED)
end)

createToggle(PlayerPanel, "Infinite Jump", 310, false, function(v)
    InfJumpEnabled = v
    notify(v and "Infinite Jump ENABLED" or "Infinite Jump DISABLED", 2, v and GREEN or RED)
end)

-- Apply speed/jump on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = SpeedValue
        hum.JumpPower = JumpValue
    end
end)

-- ============================================
-- TELEPORT PANEL CONTENT
-- ============================================
sectionLabel(TeleportPanel, "Teleport to Player", 10)

local TPScroll = Instance.new("ScrollingFrame", TeleportPanel)
TPScroll.Size = UDim2.new(1, -20, 1, -40)
TPScroll.Position = UDim2.new(0, 10, 0, 35)
TPScroll.BackgroundTransparency = 1
TPScroll.BorderSizePixel = 0
TPScroll.ScrollBarThickness = 3
TPScroll.ScrollBarImageColor3 = ACCENT
TPScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local TPLayout = Instance.new("UIListLayout", TPScroll)
TPLayout.Padding = UDim.new(0, 5)
TPLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshTPList()
    for _,c in ipairs(TPScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", TPScroll)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = BG_ITEM
            btn.BorderSizePixel = 0
            btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = TEXT_WHITE
            btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            local bc = Instance.new("UICorner", btn)
            bc.CornerRadius = UDim.new(0, 8)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT_DARK}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_ITEM}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                local char = LocalPlayer.Character
                local targetChar = p.Character
                if char and targetChar then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local thrp = targetChar:FindFirstChild("HumanoidRootPart")
                    if hrp and thrp then
                        hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
                        notify("Teleported to " .. p.DisplayName, 2, GREEN)
                    end
                else
                    notify("Player not found!", 2, RED)
                end
            end)
        end
    end

    TPScroll.CanvasSize = UDim2.new(0, 0, 0, TPLayout.AbsoluteContentSize.Y + 5)
end

-- ============================================
-- MISC PANEL CONTENT
-- ============================================
sectionLabel(MiscPanel, "Server Info", 10)

local InfoFrame = Instance.new("Frame", MiscPanel)
InfoFrame.Size = UDim2.new(1, -20, 0, 70)
InfoFrame.Position = UDim2.new(0, 10, 0, 32)
InfoFrame.BackgroundColor3 = BG_ITEM
InfoFrame.BorderSizePixel = 0
local ifc = Instance.new("UICorner", InfoFrame)
ifc.CornerRadius = UDim.new(0, 8)

local infoText = Instance.new("TextLabel", InfoFrame)
infoText.Size = UDim2.new(1, -16, 1, 0)
infoText.Position = UDim2.new(0, 8, 0, 0)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = TEXT_GREY
infoText.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
infoText.TextSize = 11
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Center
infoText.TextWrapped = true

local function updateInfo()
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local playerCount = #Players:GetPlayers()
    infoText.Text = string.format(
        "Players: %d  |  Ping: %dms  |  FPS: %d\nGame: %s\nServer ID: %s",
        playerCount, ping, fps,
        game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown",
        game.JobId:sub(1, 18) .. "..."
    )
end

task.spawn(function()
    while task.wait(2) do
        pcall(updateInfo)
    end
end)

sectionLabel(MiscPanel, "Actions", 115)

createActionButton(MiscPanel, "🔄 Rejoin Server", 138, BG_ITEM, function()
    notify("Rejoining...", 2, ACCENT_LIGHT)
    task.wait(1)
    TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

createActionButton(MiscPanel, "📋 Copy Server Link", 180, BG_ITEM, function()
    local link = "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
    if setclipboard then
        setclipboard(link)
        notify("Server link copied!", 2, GREEN)
    else
        notify("Clipboard not supported", 2, RED)
    end
end)

createActionButton(MiscPanel, "💀 Reset Character", 222, Color3.fromRGB(60, 30, 30), function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            notify("Character reset", 2)
        end
    end
end)

sectionLabel(MiscPanel, "Keybind", 270)

local keybindLabel = Instance.new("TextLabel", MiscPanel)
keybindLabel.Size = UDim2.new(1, -20, 0, 24)
keybindLabel.Position = UDim2.new(0, 10, 0, 292)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Press RightShift to toggle menu"
keybindLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
keybindLabel.TextSize = 11
keybindLabel.TextColor3 = TEXT_GREY
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ============================================
-- KEYBIND (RightShift)
-- ============================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- NAV TABS
-- ============================================
local currentTab = nil
local currentSetActive = nil

local function makeTab(label, panel, onOpen)
    local btn, setActive = createNavBtn(label)

    btn.MouseButton1Click:Connect(function()
        if onOpen then onOpen() end

        if currentTab == panel then
            showSettings(false)
            setActive(false)
            panel.Visible = false
            currentTab = nil
            currentSetActive = nil
        else
            if currentTab then
                currentTab.Visible = false
                if currentSetActive then currentSetActive(false) end
            end
            panel.Visible = true
            setActive(true)
            showSettings(true)
            currentTab = panel
            currentSetActive = setActive
        end
    end)
end

makeTab("⚡ ESP", ESPPanel, function()
    ESPEnabled = not ESPEnabled
    applyESP()
    notify(ESPEnabled and "ESP ENABLED" or "ESP DISABLED", 2, ESPEnabled and GREEN or RED)
end)

makeTab("🎨 Display", DisplayPanel)

makeTab("🏃 Player", PlayerPanel)

makeTab("🌀 Teleport", TeleportPanel, function()
    refreshTPList()
end)

makeTab("⚙ Misc", MiscPanel, function()
    pcall(updateInfo)
end)

-- ============================================
-- FLOAT TOGGLE
-- ============================================
FloatButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 460, 0, 0),
            Position = UDim2.new(0.5, -230, 0.5, -220)
        })
        t:Play()
        t.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 500, 0, 440)
            MainFrame.Position = UDim2.new(0.5, -250, 0.5, -220)
        end)
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 500, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 500, 0, 440)
        }):Play()
    end
end)

-- FLOAT BUTTON HOVER
FloatButton.MouseEnter:Connect(function()
    TweenService:Create(fbStroke, TweenInfo.new(0.2), {Color = ACCENT_LIGHT}):Play()
    TweenService:Create(FloatButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35,35,50)}):Play()
end)
FloatButton.MouseLeave:Connect(function()
    TweenService:Create(fbStroke, TweenInfo.new(0.2), {Color = ACCENT}):Play()
    TweenService:Create(FloatButton, TweenInfo.new(0.2), {BackgroundColor3 = BG_PANEL}):Play()
end)

-- ============================================
-- STARTUP
-- ============================================
notify("◈ Delta Menu v2 Loaded!", 4, ACCENT_LIGHT)
print("◈ DELTA UI v2 LOADED")