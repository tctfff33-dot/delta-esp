local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ColorEffect = Instance.new("ColorCorrectionEffect", Lighting)
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0

local ESPColor = Color3.fromRGB(180, 0, 255)
local ESPEnabled = false
local ESPObjects = {}
local ESPMode = "ALL"
local TargetName = nil

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
local notifY = 20

local ACCENT       = Color3.fromRGB(138, 43, 226)
local ACCENT_LIGHT = Color3.fromRGB(170, 70, 255)
local ACCENT_DARK  = Color3.fromRGB(80, 16, 140)
local ACCENT_GLOW  = Color3.fromRGB(200, 120, 255)
local BG_MAIN      = Color3.fromRGB(12, 12, 18)
local BG_PANEL     = Color3.fromRGB(18, 18, 28)
local BG_LEFT      = Color3.fromRGB(14, 14, 22)
local BG_ITEM      = Color3.fromRGB(24, 24, 38)
local BG_SLIDER    = Color3.fromRGB(32, 32, 48)
local TEXT_WHITE    = Color3.fromRGB(240, 240, 250)
local TEXT_GREY     = Color3.fromRGB(130, 130, 160)
local TEXT_DIM      = Color3.fromRGB(80, 80, 110)
local GREEN         = Color3.fromRGB(40, 185, 90)
local RED           = Color3.fromRGB(190, 45, 65)
local BORDER        = Color3.fromRGB(40, 40, 60)

-- ============================================
-- GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "DeltaMenu"
ScreenGui.IgnoreGuiInset = true

-- ============================================
-- RUNTIME LOOPS
-- ============================================
RunService.RenderStepped:Connect(function()
    local targetBlur = 0
    if MotionBlurEnabled then
        local delta2 = (lastCF:Inverse() * Camera.CFrame)
        local _,_,_, r00,r01,r02,r10,r11,r12 = delta2:GetComponents()
        local change = math.abs(r01) + math.abs(r02) + math.abs(r10)
        targetBlur = math.clamp(change * 60, 0, 20)
        lastCF = Camera.CFrame
    end
    currentBlur = currentBlur + (targetBlur - currentBlur) * 0.15
    Blur.Size = currentBlur
end)

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local BaseFOV = 70
Camera.FieldOfView = BaseFOV

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Camera.FieldOfView = BaseFOV
    if FlyEnabled then FlyEnabled = false; flyBody = nil end
end)

-- ============================================
-- NOTIFICATIONS
-- ============================================
local function notify(text, duration, color)
    duration = duration or 3
    color = color or ACCENT_LIGHT

    local notif = Instance.new("Frame", ScreenGui)
    notif.Size = UDim2.new(0, 280, 0, 44)
    notif.Position = UDim2.new(1, 290, 1, -(notifY + 44))
    notif.BackgroundColor3 = BG_PANEL
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local ns = Instance.new("UIStroke", notif)
    ns.Color = color; ns.Thickness = 1; ns.Transparency = 0.5

    local bar = Instance.new("Frame", notif)
    bar.Size = UDim2.new(0, 3, 0.7, 0)
    bar.Position = UDim2.new(0, 0, 0.15, 0)
    bar.BackgroundColor3 = color; bar.BorderSizePixel = 0; bar.ZIndex = 101
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local icn = Instance.new("TextLabel", notif)
    icn.Size = UDim2.new(0, 24, 1, 0); icn.Position = UDim2.new(0, 10, 0, 0)
    icn.BackgroundTransparency = 1; icn.Text = "◈"; icn.TextColor3 = color
    icn.TextSize = 12; icn.ZIndex = 101

    local lbl = Instance.new("TextLabel", notif)
    lbl.Size = UDim2.new(1, -44, 1, 0); lbl.Position = UDim2.new(0, 34, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 11; lbl.TextColor3 = TEXT_WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.ZIndex = 101

    local prog = Instance.new("Frame", notif)
    prog.Size = UDim2.new(1, 0, 0, 2); prog.Position = UDim2.new(0, 0, 1, -2)
    prog.BackgroundColor3 = color; prog.BackgroundTransparency = 0.3
    prog.BorderSizePixel = 0; prog.ZIndex = 101
    Instance.new("UICorner", prog).CornerRadius = UDim.new(1, 0)

    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -295, 1, -(notifY + 44))
    }):Play()
    TweenService:Create(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()

    notifY = notifY + 54
    task.delay(duration, function()
        local t = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 290, notif.Position.Y.Scale, notif.Position.Y.Offset)
        })
        t:Play()
        t.Completed:Connect(function() notif:Destroy(); notifY = math.max(20, notifY - 54) end)
    end)
end

-- ============================================
-- FLOAT BUTTON
-- ============================================
local FloatButton = Instance.new("TextButton", ScreenGui)
FloatButton.Size = UDim2.new(0, 50, 0, 50)
FloatButton.Position = UDim2.new(0, 20, 0, 40)
FloatButton.Text = "◈"
FloatButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
FloatButton.TextSize = 20; FloatButton.BackgroundColor3 = BG_PANEL
FloatButton.TextColor3 = ACCENT_LIGHT; FloatButton.BorderSizePixel = 0
Instance.new("UICorner", FloatButton).CornerRadius = UDim.new(1, 0)
local fbStroke = Instance.new("UIStroke", FloatButton)
fbStroke.Color = ACCENT_DARK; fbStroke.Thickness = 1.2

-- ============================================
-- MAIN FRAME (ФИКСИРОВАННЫЙ)
-- ============================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 460)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -230)
MainFrame.BackgroundColor3 = BG_MAIN
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = BORDER; mfStroke.Thickness = 1

-- TITLE BAR
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = BG_PANEL; TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
local tbFix = Instance.new("Frame", TitleBar)
tbFix.Size = UDim2.new(1, 0, 0.5, 0); tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = BG_PANEL; tbFix.BorderSizePixel = 0

local sep = Instance.new("Frame", TitleBar)
sep.Size = UDim2.new(1, 0, 0, 1); sep.Position = UDim2.new(0, 0, 1, -1)
sep.BackgroundColor3 = BORDER; sep.BorderSizePixel = 0

local TitleIcon = Instance.new("TextLabel", TitleBar)
TitleIcon.Size = UDim2.new(0, 28, 1, 0); TitleIcon.Position = UDim2.new(0, 14, 0, 0)
TitleIcon.BackgroundTransparency = 1; TitleIcon.Text = "◈"
TitleIcon.TextColor3 = ACCENT_LIGHT; TitleIcon.TextSize = 16

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0, 120, 1, 0); TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "DELTA"
TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Black)
TitleLabel.TextSize = 15; TitleLabel.TextColor3 = TEXT_WHITE
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local VerBadge = Instance.new("TextLabel", TitleBar)
VerBadge.Size = UDim2.new(0, 32, 0, 16); VerBadge.Position = UDim2.new(0, 110, 0.5, -8)
VerBadge.BackgroundColor3 = ACCENT_DARK; VerBadge.Text = "2.0"
VerBadge.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
VerBadge.TextSize = 8; VerBadge.TextColor3 = ACCENT_LIGHT; VerBadge.BorderSizePixel = 0
Instance.new("UICorner", VerBadge).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
CloseBtn.Text = "×"; CloseBtn.TextSize = 16
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 30); CloseBtn.TextColor3 = RED
CloseBtn.BorderSizePixel = 0
CloseBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = RED, TextColor3 = TEXT_WHITE}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50,20,30), TextColor3 = RED}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 26, 0, 26); MinBtn.Position = UDim2.new(1, -68, 0.5, -13)
MinBtn.Text = "–"; MinBtn.TextSize = 14
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45); MinBtn.TextColor3 = TEXT_GREY
MinBtn.BorderSizePixel = 0
MinBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45,45,65)}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30,30,45)}):Play()
end)
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ============================================
-- DRAG
-- ============================================
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
LeftPanel.Size = UDim2.new(0, 140, 1, -42); LeftPanel.Position = UDim2.new(0, 0, 0, 42)
LeftPanel.BackgroundColor3 = BG_LEFT; LeftPanel.BorderSizePixel = 0

local lpBorder = Instance.new("Frame", LeftPanel)
lpBorder.Size = UDim2.new(0, 1, 1, 0); lpBorder.Position = UDim2.new(1, -1, 0, 0)
lpBorder.BackgroundColor3 = BORDER; lpBorder.BorderSizePixel = 0

-- ПРАВАЯ ПАНЕЛЬ (контент)
local RightPanel = Instance.new("Frame", MainFrame)
RightPanel.Size = UDim2.new(1, -148, 1, -50)
RightPanel.Position = UDim2.new(0, 145, 0, 47)
RightPanel.BackgroundColor3 = BG_PANEL
RightPanel.BorderSizePixel = 0
RightPanel.ClipsDescendants = true
RightPanel.Visible = true
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)

-- Текст "выберите раздел" по умолчанию
local PlaceholderLabel = Instance.new("TextLabel", RightPanel)
PlaceholderLabel.Size = UDim2.new(1, 0, 1, 0)
PlaceholderLabel.BackgroundTransparency = 1
PlaceholderLabel.Text = "◈ Select a tab"
PlaceholderLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
PlaceholderLabel.TextSize = 13
PlaceholderLabel.TextColor3 = TEXT_DIM

-- ============================================
-- CONTENT PANELS
-- ============================================
local function makeContentPanel()
    local p = Instance.new("ScrollingFrame", RightPanel)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = ACCENT_DARK
    p.CanvasSize = UDim2.new(0, 0, 0, 600)
    p.ScrollingDirection = Enum.ScrollingDirection.Y
    return p
end

local ESPPanel = makeContentPanel()
local DisplayPanel = makeContentPanel()
local PlayerPanel = makeContentPanel()
local TeleportPanel = makeContentPanel()
local MiscPanel = makeContentPanel()

-- ============================================
-- NAV
-- ============================================
local navY = 14

local function createNavBtn(iconText, labelText)
    local btn = Instance.new("TextButton", LeftPanel)
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.Position = UDim2.new(0, 8, 0, navY)
    btn.Text = ""; btn.BackgroundColor3 = BG_LEFT; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local accent = Instance.new("Frame", btn)
    accent.Size = UDim2.new(0, 3, 0, 0)
    accent.Position = UDim2.new(0, 0, 0.5, 0)
    accent.AnchorPoint = Vector2.new(0, 0.5)
    accent.BackgroundColor3 = ACCENT_LIGHT; accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)

    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Size = UDim2.new(0, 24, 1, 0); iconLbl.Position = UDim2.new(0, 12, 0, 0)
    iconLbl.BackgroundTransparency = 1; iconLbl.Text = iconText
    iconLbl.TextColor3 = TEXT_DIM; iconLbl.TextSize = 13

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -44, 1, 0); lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 11; lbl.TextColor3 = TEXT_GREY; lbl.TextXAlignment = Enum.TextXAlignment.Left

    navY = navY + 42

    local isActive = false

    local function setActive(active)
        isActive = active
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = active and Color3.fromRGB(28, 22, 48) or BG_LEFT
        }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.2), {
            TextColor3 = active and TEXT_WHITE or TEXT_GREY
        }):Play()
        TweenService:Create(iconLbl, TweenInfo.new(0.2), {
            TextColor3 = active and ACCENT_LIGHT or TEXT_DIM
        }):Play()
        TweenService:Create(accent, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = active and UDim2.new(0, 3, 0.55, 0) or UDim2.new(0, 3, 0, 0)
        }):Play()
    end

    btn.MouseEnter:Connect(function()
        if not isActive then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 36)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not isActive then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BG_LEFT}):Play()
        end
    end)

    return btn, setActive
end

-- ============================================
-- ESP
-- ============================================
local function addESP(player)
    if player == LocalPlayer or not player.Character then return end
    if ESPMode == "ALONE" then
        if not TargetName or player.Name:lower() ~= TargetName:lower() then return end
    end
    if player.Character:FindFirstChild("DeltaESP") then return end
    local h = Instance.new("Highlight")
    h.Name = "DeltaESP"; h.Parent = player.Character
    h.FillColor = ESPColor; h.FillTransparency = 0.4
    h.OutlineColor = ESPColor; h.OutlineTransparency = 0.2
    ESPObjects[player] = h
end

local function removeESP()
    for _,v in pairs(ESPObjects) do if v then v:Destroy() end end
    ESPObjects = {}
end

local function applyESP()
    removeESP()
    if ESPEnabled then
        for _,p in ipairs(Players:GetPlayers()) do task.spawn(function() addESP(p) end) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); if ESPEnabled then addESP(p) end end)
end)

-- ============================================
-- FLY
-- ============================================
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp:FindFirstChild("DeltaFlyVel") then hrp.DeltaFlyVel:Destroy() end
    if hrp:FindFirstChild("DeltaFlyGyro") then hrp.DeltaFlyGyro:Destroy() end
    local bv = Instance.new("BodyVelocity"); bv.Name = "DeltaFlyVel"
    bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge); bv.Velocity = Vector3.zero; bv.Parent = hrp
    local bg = Instance.new("BodyGyro"); bg.Name = "DeltaFlyGyro"
    bg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge); bg.D = 100; bg.Parent = hrp
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
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit end
        flyBody.vel.Velocity = dir * FlySpeed
        flyBody.gyro.CFrame = Camera.CFrame
    end
end)

-- ============================================
-- UI HELPERS
-- ============================================
local function sectionLabel(parent, text, y)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -28, 0, 18); lbl.Position = UDim2.new(0, 14, 0, y)
    lbl.BackgroundTransparency = 1; lbl.Text = text:upper()
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    lbl.TextSize = 9; lbl.TextColor3 = TEXT_DIM; lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function createDivider(parent, y)
    local d = Instance.new("Frame", parent)
    d.Size = UDim2.new(1, -28, 0, 1); d.Position = UDim2.new(0, 14, 0, y)
    d.BackgroundColor3 = BORDER; d.BorderSizePixel = 0
end

-- ============================================
-- SLIDER
-- ============================================
local function createSlider(parent, title, y, min, max, default, suffix, callback)
    suffix = suffix or ""
    local norm = (default - min) / (max - min)

    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -28, 0, 52); container.Position = UDim2.new(0, 14, 0, y)
    container.BackgroundColor3 = BG_ITEM; container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.6, 0, 0, 20); lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = title
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 11; lbl.TextColor3 = TEXT_WHITE; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", container)
    valLabel.Size = UDim2.new(0.4, -14, 0, 20); valLabel.Position = UDim2.new(0.6, 0, 0, 4)
    valLabel.BackgroundTransparency = 1; valLabel.TextColor3 = ACCENT_LIGHT
    valLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    valLabel.TextSize = 11; valLabel.Text = tostring(math.floor(default)) .. suffix
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", container)
    track.Size = UDim2.new(1, -28, 0, 10); track.Position = UDim2.new(0, 14, 0, 30)
    track.BackgroundColor3 = BG_SLIDER; track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(norm, 0, 1, 0); fill.BackgroundColor3 = ACCENT; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fillGlow = Instance.new("Frame", fill)
    fillGlow.Size = UDim2.new(0, 14, 0, 10); fillGlow.Position = UDim2.new(1, -7, 0.5, -5)
    fillGlow.BackgroundColor3 = ACCENT_GLOW; fillGlow.BackgroundTransparency = 0.6; fillGlow.BorderSizePixel = 0
    Instance.new("UICorner", fillGlow).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 20, 0, 20); knob.Position = UDim2.new(norm, -10, 0.5, -10)
    knob.BackgroundColor3 = TEXT_WHITE; knob.BorderSizePixel = 0; knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob); ks.Color = ACCENT; ks.Thickness = 2

    local dot = Instance.new("Frame", knob)
    dot.Size = UDim2.new(0, 6, 0, 6); dot.Position = UDim2.new(0.5, -3, 0.5, -3)
    dot.BackgroundColor3 = ACCENT; dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -10, 0.5, -10)
        local val = min + pos * (max - min)
        valLabel.Text = tostring(math.floor(val)) .. suffix
        callback(val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; MainFrame.Active = false; update(i)
        end
    end)
    track.InputEnded:Connect(function(i)
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
-- TOGGLE
-- ============================================
local function createToggle(parent, title, y, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -28, 0, 38); container.Position = UDim2.new(0, 14, 0, y)
    container.BackgroundColor3 = BG_ITEM; container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = title
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 11; lbl.TextColor3 = TEXT_WHITE; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBG = Instance.new("Frame", container)
    toggleBG.Size = UDim2.new(0, 42, 0, 22); toggleBG.Position = UDim2.new(1, -54, 0.5, -11)
    toggleBG.BackgroundColor3 = default and GREEN or Color3.fromRGB(40, 40, 58); toggleBG.BorderSizePixel = 0
    Instance.new("UICorner", toggleBG).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggleBG)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = TEXT_WHITE; knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local enabled = default or false

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 5

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggleBG, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = enabled and GREEN or Color3.fromRGB(40, 40, 58)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
        callback(enabled)
    end)
end

-- ============================================
-- ACTION BUTTON
-- ============================================
local function createActionButton(parent, iconText, title, y, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -28, 0, 38); btn.Position = UDim2.new(0, 14, 0, y)
    btn.Text = ""; btn.BackgroundColor3 = BG_ITEM; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", btn); bs.Color = BORDER; bs.Thickness = 1

    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Size = UDim2.new(0, 24, 1, 0); iconLbl.Position = UDim2.new(0, 12, 0, 0)
    iconLbl.BackgroundTransparency = 1; iconLbl.Text = iconText
    iconLbl.TextColor3 = ACCENT_LIGHT; iconLbl.TextSize = 12

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = title
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    lbl.TextSize = 11; lbl.TextColor3 = TEXT_WHITE; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1; arrow.Text = "›"; arrow.TextColor3 = TEXT_DIM; arrow.TextSize = 16

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 28, 52)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BG_ITEM}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
end

-- ============================================
-- RGB SLIDER
-- ============================================
local function createRGBSlider(parent, name, y, initVal)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -28, 0, 42); container.Position = UDim2.new(0, 14, 0, y)
    container.BackgroundColor3 = BG_ITEM; container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local fillColor = name == "R" and Color3.fromRGB(220,50,80) or name == "G" and Color3.fromRGB(50,200,100) or Color3.fromRGB(50,100,255)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0, 30, 0, 16); lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    lbl.TextSize = 10; lbl.TextColor3 = fillColor; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", container)
    valLbl.Size = UDim2.new(0, 40, 0, 16); valLbl.Position = UDim2.new(1, -54, 0, 4)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(math.floor(initVal * 255))
    valLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    valLbl.TextSize = 10; valLbl.TextColor3 = TEXT_GREY; valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", container)
    track.Size = UDim2.new(1, -28, 0, 8); track.Position = UDim2.new(0, 14, 0, 26)
    track.BackgroundColor3 = BG_SLIDER; track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(initVal, 0, 1, 0); fill.BackgroundColor3 = fillColor; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 18, 0, 18); knob.Position = UDim2.new(initVal, -9, 0.5, -9)
    knob.BackgroundColor3 = TEXT_WHITE; knob.BorderSizePixel = 0; knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob); ks.Color = fillColor; ks.Thickness = 2

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -9, 0.5, -9)
        local val = math.floor(pos * 255)
        valLbl.Text = tostring(val)
        if name == "R" then ESPColor = Color3.fromRGB(val, ESPColor.G*255, ESPColor.B*255) end
        if name == "G" then ESPColor = Color3.fromRGB(ESPColor.R*255, val, ESPColor.B*255) end
        if name == "B" then ESPColor = Color3.fromRGB(ESPColor.R*255, ESPColor.G*255, val) end
        for _,v in pairs(ESPObjects) do if v then v.FillColor = ESPColor; v.OutlineColor = ESPColor end end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; MainFrame.Active = false; update(i)
        end
    end)
    track.InputEnded:Connect(function(i)
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
-- ESP PANEL
-- ============================================
sectionLabel(ESPPanel, "Highlight Color", 12)
createRGBSlider(ESPPanel, "R", 34, ESPColor.R)
createRGBSlider(ESPPanel, "G", 84, ESPColor.G)
createRGBSlider(ESPPanel, "B", 134, ESPColor.B)

createDivider(ESPPanel, 190)
sectionLabel(ESPPanel, "Target Mode", 200)

local ModeButton = Instance.new("TextButton", ESPPanel)
ModeButton.Size = UDim2.new(1, -28, 0, 38); ModeButton.Position = UDim2.new(0, 14, 0, 222)
ModeButton.Text = ""; ModeButton.BackgroundColor3 = BG_ITEM; ModeButton.BorderSizePixel = 0
Instance.new("UICorner", ModeButton).CornerRadius = UDim.new(0, 8)
local mbS = Instance.new("UIStroke", ModeButton); mbS.Color = BORDER; mbS.Thickness = 1

local modeIcon = Instance.new("TextLabel", ModeButton)
modeIcon.Size = UDim2.new(0, 24, 1, 0); modeIcon.Position = UDim2.new(0, 12, 0, 0)
modeIcon.BackgroundTransparency = 1; modeIcon.Text = "◉"
modeIcon.TextColor3 = ACCENT_LIGHT; modeIcon.TextSize = 13

local modeLbl = Instance.new("TextLabel", ModeButton)
modeLbl.Size = UDim2.new(1, -50, 1, 0); modeLbl.Position = UDim2.new(0, 38, 0, 0)
modeLbl.BackgroundTransparency = 1; modeLbl.Text = "Mode: ALL PLAYERS"
modeLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
modeLbl.TextSize = 11; modeLbl.TextColor3 = TEXT_WHITE; modeLbl.TextXAlignment = Enum.TextXAlignment.Left

local NameBox = Instance.new("TextBox", ESPPanel)
NameBox.Size = UDim2.new(1, -28, 0, 36); NameBox.Position = UDim2.new(0, 14, 0, 270)
NameBox.PlaceholderText = "Enter player name..."; NameBox.Text = ""
NameBox.Visible = false; NameBox.BackgroundColor3 = BG_ITEM
NameBox.TextColor3 = TEXT_WHITE; NameBox.PlaceholderColor3 = TEXT_DIM
NameBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
NameBox.TextSize = 11; NameBox.BorderSizePixel = 0
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 8)
local nbS = Instance.new("UIStroke", NameBox); nbS.Color = ACCENT_DARK; nbS.Thickness = 1

ModeButton.MouseButton1Click:Connect(function()
    if ESPMode == "ALL" then
        ESPMode = "ALONE"; modeLbl.Text = "Mode: SINGLE TARGET"
        NameBox.Visible = true
        TweenService:Create(mbS, TweenInfo.new(0.2), {Color = ACCENT}):Play()
        notify("ESP → Single target", 2)
    else
        ESPMode = "ALL"; modeLbl.Text = "Mode: ALL PLAYERS"
        NameBox.Visible = false; TargetName = nil
        TweenService:Create(mbS, TweenInfo.new(0.2), {Color = BORDER}):Play()
        notify("ESP → All players", 2)
    end
    applyESP()
end)

NameBox.FocusLost:Connect(function()
    TargetName = NameBox.Text; applyESP()
    if TargetName and TargetName ~= "" then notify("Target set: " .. TargetName, 2) end
end)

ESPPanel.CanvasSize = UDim2.new(0, 0, 0, 320)

-- ============================================
-- DISPLAY PANEL
-- ============================================
sectionLabel(DisplayPanel, "Color Correction", 12)
createSlider(DisplayPanel, "Saturation", 34, -1, 2, 0, "", function(v) ColorEffect.Saturation = v end)
createSlider(DisplayPanel, "Brightness", 100, -1, 1, 0, "", function(v) ColorEffect.Brightness = v end)
createSlider(DisplayPanel, "Contrast", 166, 0, 2, 0, "", function(v) ColorEffect.Contrast = v end)

createDivider(DisplayPanel, 232)
sectionLabel(DisplayPanel, "Camera & Effects", 242)

createToggle(DisplayPanel, "Motion Blur", 264, false, function(v)
    MotionBlurEnabled = v
    if not v then Blur.Size = 0; currentBlur = 0 end
    notify(v and "Motion Blur enabled" or "Motion Blur disabled", 2, v and GREEN or RED)
end)

createSlider(DisplayPanel, "Field of View", 314, 70, 120, 70, "°", function(v)
    Camera.FieldOfView = v; BaseFOV = v
end)

DisplayPanel.CanvasSize = UDim2.new(0, 0, 0, 390)

-- ============================================
-- PLAYER PANEL
-- ============================================
sectionLabel(PlayerPanel, "Movement", 12)
createSlider(PlayerPanel, "Walk Speed", 34, 16, 250, 16, "", function(v)
    SpeedValue = v
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = v end end
end)
createSlider(PlayerPanel, "Jump Power", 100, 50, 350, 50, "", function(v)
    JumpValue = v
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = v end end
end)

createDivider(PlayerPanel, 166)
sectionLabel(PlayerPanel, "Abilities", 176)

createToggle(PlayerPanel, "Fly", 198, false, function(v)
    FlyEnabled = v
    if v then startFly() else stopFly() end
    notify(v and "Fly enabled" or "Fly disabled", 2, v and GREEN or RED)
end)

createSlider(PlayerPanel, "Fly Speed", 248, 10, 250, 50, "", function(v) FlySpeed = v end)

createToggle(PlayerPanel, "Noclip", 318, false, function(v)
    NoclipEnabled = v
    notify(v and "Noclip enabled" or "Noclip disabled", 2, v and GREEN or RED)
end)

createToggle(PlayerPanel, "Infinite Jump", 366, false, function(v)
    InfJumpEnabled = v
    notify(v and "Infinite Jump enabled" or "Infinite Jump disabled", 2, v and GREEN or RED)
end)

PlayerPanel.CanvasSize = UDim2.new(0, 0, 0, 420)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = SpeedValue; hum.JumpPower = JumpValue end
end)

-- ============================================
-- TELEPORT PANEL
-- ============================================
sectionLabel(TeleportPanel, "Select Player", 12)

local TPScroll = Instance.new("ScrollingFrame", TeleportPanel)
TPScroll.Size = UDim2.new(1, -28, 1, -45); TPScroll.Position = UDim2.new(0, 14, 0, 36)
TPScroll.BackgroundTransparency = 1; TPScroll.BorderSizePixel = 0
TPScroll.ScrollBarThickness = 3; TPScroll.ScrollBarImageColor3 = ACCENT_DARK
TPScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local TPLayout = Instance.new("UIListLayout", TPScroll)
TPLayout.Padding = UDim.new(0, 4); TPLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshTPList()
    for _,c in ipairs(TPScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", TPScroll)
            btn.Size = UDim2.new(1, 0, 0, 36); btn.BackgroundColor3 = BG_ITEM
            btn.BorderSizePixel = 0; btn.Text = ""
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            local ico = Instance.new("TextLabel", btn)
            ico.Size = UDim2.new(0, 24, 1, 0); ico.Position = UDim2.new(0, 10, 0, 0)
            ico.BackgroundTransparency = 1; ico.Text = "◇"; ico.TextColor3 = ACCENT_LIGHT; ico.TextSize = 12

            local nl = Instance.new("TextLabel", btn)
            nl.Size = UDim2.new(1, -60, 1, 0); nl.Position = UDim2.new(0, 36, 0, 0)
            nl.BackgroundTransparency = 1; nl.Text = p.DisplayName .. "  @" .. p.Name
            nl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
            nl.TextSize = 11; nl.TextColor3 = TEXT_WHITE; nl.TextXAlignment = Enum.TextXAlignment.Left

            local arr = Instance.new("TextLabel", btn)
            arr.Size = UDim2.new(0, 20, 1, 0); arr.Position = UDim2.new(1, -26, 0, 0)
            arr.BackgroundTransparency = 1; arr.Text = "›"; arr.TextColor3 = TEXT_DIM; arr.TextSize = 16

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 28, 52)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BG_ITEM}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                local myChar = LocalPlayer.Character; local tChar = p.Character
                if myChar and tChar then
                    local hrp = myChar:FindFirstChild("HumanoidRootPart")
                    local thrp = tChar:FindFirstChild("HumanoidRootPart")
                    if hrp and thrp then
                        hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
                        notify("Teleported → " .. p.DisplayName, 2, GREEN)
                    end
                else notify("Target unavailable", 2, RED) end
            end)
        end
    end
    TPScroll.CanvasSize = UDim2.new(0, 0, 0, TPLayout.AbsoluteContentSize.Y + 5)
end

-- ============================================
-- MISC PANEL
-- ============================================
sectionLabel(MiscPanel, "Server Information", 12)

local InfoFrame = Instance.new("Frame", MiscPanel)
InfoFrame.Size = UDim2.new(1, -28, 0, 74); InfoFrame.Position = UDim2.new(0, 14, 0, 34)
InfoFrame.BackgroundColor3 = BG_ITEM; InfoFrame.BorderSizePixel = 0
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 8)

local infoText = Instance.new("TextLabel", InfoFrame)
infoText.Size = UDim2.new(1, -20, 1, 0); infoText.Position = UDim2.new(0, 10, 0, 0)
infoText.BackgroundTransparency = 1; infoText.TextColor3 = TEXT_GREY
infoText.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
infoText.TextSize = 10; infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Center; infoText.TextWrapped = true

local function updateInfo()
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    local playerCount = #Players:GetPlayers()
    local gameName = "Unknown"
    pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    infoText.Text = string.format("Players: %d  │  Ping: %dms\nGame: %s\nServer: %s",
        playerCount, ping, gameName, game.JobId:sub(1, 20) .. "...")
end

task.spawn(function() while task.wait(3) do pcall(updateInfo) end end)

createDivider(MiscPanel, 120)
sectionLabel(MiscPanel, "Quick Actions", 130)

createActionButton(MiscPanel, "↻", "Rejoin Server", 152, function()
    notify("Rejoining server...", 2, ACCENT_LIGHT)
    task.wait(1); game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

createActionButton(MiscPanel, "◫", "Copy Server Link", 198, function()
    local link = "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
    if setclipboard then setclipboard(link); notify("Link copied", 2, GREEN)
    else notify("Clipboard not available", 2, RED) end
end)

createActionButton(MiscPanel, "⊗", "Reset Character", 244, function()
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.Health = 0; notify("Character reset", 2) end end
end)

createDivider(MiscPanel, 296)
sectionLabel(MiscPanel, "Controls", 306)

local kbInfo = Instance.new("TextLabel", MiscPanel)
kbInfo.Size = UDim2.new(1, -28, 0, 40); kbInfo.Position = UDim2.new(0, 14, 0, 328)
kbInfo.BackgroundColor3 = BG_ITEM; kbInfo.BorderSizePixel = 0
kbInfo.Text = "  RightShift — Toggle Menu\n  Fly: WASD + Space/Shift"
kbInfo.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
kbInfo.TextSize = 10; kbInfo.TextColor3 = TEXT_GREY
kbInfo.TextXAlignment = Enum.TextXAlignment.Left; kbInfo.TextYAlignment = Enum.TextYAlignment.Center
Instance.new("UICorner", kbInfo).CornerRadius = UDim.new(0, 8)

MiscPanel.CanvasSize = UDim2.new(0, 0, 0, 390)

-- ============================================
-- KEYBIND
-- ============================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- NAV TABS (ИСПРАВЛЕННАЯ ЛОГИКА)
-- ============================================
local currentTab = nil
local currentSetActive = nil

local function makeTab(iconText, label, panel, onOpen)
    local btn, setActive = createNavBtn(iconText, label)
    btn.MouseButton1Click:Connect(function()
        if onOpen then onOpen() end

        if currentTab == panel then
            -- Закрыть текущий таб
            panel.Visible = false
            setActive(false)
            PlaceholderLabel.Visible = true
            currentTab = nil
            currentSetActive = nil
        else
            -- Закрыть предыдущий
            if currentTab then
                currentTab.Visible = false
                if currentSetActive then currentSetActive(false) end
            end
            -- Открыть новый
            panel.Visible = true
            setActive(true)
            PlaceholderLabel.Visible = false
            currentTab = panel
            currentSetActive = setActive
        end
    end)
end

makeTab("◈", "ESP", ESPPanel, function()
    ESPEnabled = not ESPEnabled; applyESP()
    notify(ESPEnabled and "ESP enabled" or "ESP disabled", 2, ESPEnabled and GREEN or RED)
end)
makeTab("◐", "Display", DisplayPanel)
makeTab("△", "Player", PlayerPanel)
makeTab("◇", "Teleport", TeleportPanel, function() refreshTPList() end)
makeTab("≡", "Misc", MiscPanel, function() pcall(updateInfo) end)

-- Nav separator
navY = navY + 6
local navSep = Instance.new("Frame", LeftPanel)
navSep.Size = UDim2.new(1, -24, 0, 1); navSep.Position = UDim2.new(0, 12, 0, navY)
navSep.BackgroundColor3 = BORDER; navSep.BorderSizePixel = 0

local userInfo = Instance.new("TextLabel", LeftPanel)
userInfo.Size = UDim2.new(1, -16, 0, 30); userInfo.Position = UDim2.new(0, 8, 1, -40)
userInfo.BackgroundTransparency = 1; userInfo.Text = "◈ " .. LocalPlayer.DisplayName
userInfo.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
userInfo.TextSize = 9; userInfo.TextColor3 = TEXT_DIM
userInfo.TextXAlignment = Enum.TextXAlignment.Left; userInfo.TextTruncate = Enum.TextTruncate.AtEnd

-- ============================================
-- FLOAT BUTTON — ПРОСТОЕ ОТКРЫТИЕ (ФИКС)
-- ============================================
FloatButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

FloatButton.MouseEnter:Connect(function()
    TweenService:Create(fbStroke, TweenInfo.new(0.2), {Color = ACCENT}):Play()
    TweenService:Create(FloatButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28,28,42)}):Play()
end)
FloatButton.MouseLeave:Connect(function()
    TweenService:Create(fbStroke, TweenInfo.new(0.2), {Color = ACCENT_DARK}):Play()
    TweenService:Create(FloatButton, TweenInfo.new(0.2), {BackgroundColor3 = BG_PANEL}):Play()
end)

-- ============================================
-- READY
-- ============================================
notify("◈ Delta v2.0 — Ready", 3, ACCENT_LIGHT)
print("◈ DELTA v2.0 LOADED")