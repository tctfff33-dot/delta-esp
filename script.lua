local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberpunkMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 72, 0, 72)
FloatBtn.Position = UDim2.new(1, -100, 0.4, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
FloatBtn.Text = "Δ"
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
FloatBtn.TextScaled = true
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Thickness = 5
FloatStroke.Color = Color3.fromRGB(138, 43, 226)
FloatStroke.Parent = FloatBtn

local FloatGradient = Instance.new("UIGradient")
FloatGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))}
FloatGradient.Rotation = 0
FloatGradient.Parent = FloatStroke

RunService.Heartbeat:Connect(function(dt)
	FloatBtn.Rotation = FloatBtn.Rotation + 180 * dt
	local pulse = math.sin(tick() * 4) * 0.15 + 0.85
	FloatStroke.Transparency = 1 - pulse
	FloatGradient.Rotation = FloatGradient.Rotation + 90 * dt
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 520)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 14)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 4
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 0, 70))
}
MainGradient.Rotation = 135
MainGradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Δ Cyberpunk Menu"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -20)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local DragStart, StartPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		DragStart = input.Position
		StartPos = MainFrame.Position
		local dragConn
		dragConn = UserInputService.InputChanged:Connect(function(dragInput)
			if dragInput.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = dragInput.Position - DragStart
				MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
				dragConn:Disconnect()
			end
		end)
	end
end)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 50)
TabContainer.Position = UDim2.new(0, 0, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(0.5, 0, 1, 0)
ESPBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ESPBtn.Text = "ESP"
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.TextScaled = true
ESPBtn.Font = Enum.Font.GothamBold
ESPBtn.Parent = TabContainer

local MoveBtn = Instance.new("TextButton")
MoveBtn.Size = UDim2.new(0.5, 0, 1, 0)
MoveBtn.Position = UDim2.new(0.5, 0, 0, 0)
MoveBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MoveBtn.Text = "Movement"
MoveBtn.TextColor3 = Color3.fromRGB(180, 180, 255)
MoveBtn.TextScaled = true
MoveBtn.Font = Enum.Font.GothamBold
MoveBtn.Parent = TabContainer

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -110)
Content.Position = UDim2.new(0, 0, 0, 110)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 8
Content.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
Content.Parent = MainFrame

local ESPSection = Instance.new("Frame")
ESPSection.Size = UDim2.new(1, 0, 1, 0)
ESPSection.BackgroundTransparency = 1
ESPSection.Parent = Content

local MoveSection = Instance.new("Frame")
MoveSection.Size = UDim2.new(1, 0, 1, 0)
MoveSection.BackgroundTransparency = 1
MoveSection.Visible = false
MoveSection.Parent = Content

local function createSectionHeader(parent, text)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -40, 0, 40)
	header.BackgroundTransparency = 1
	header.Text = text
	header.TextColor3 = Color3.fromRGB(0, 255, 255)
	header.TextScaled = true
	header.Font = Enum.Font.GothamBold
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = parent
	return header
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -40, 0, 55)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local switch = Instance.new("Frame")
	switch.Size = UDim2.new(0, 72, 0, 36)
	switch.Position = UDim2.new(1, -90, 0.5, -18)
	switch.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	switch.Parent = frame

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switch

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 30, 0, 30)
	knob.Position = UDim2.new(0, 3, 0.5, -15)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = switch

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local state = default

	local function update()
		if state then
			TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
			TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 39, 0.5, -15)}):Play()
		else
			TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
			TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 3, 0.5, -15)}):Play()
		end
	end
	update()

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = switch
	btn.MouseButton1Click:Connect(function()
		state = not state
		update()
		callback(state)
	end)

	return frame
end

local function createSlider(parent, text, min, max, default, step, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -40, 0, 70)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 25)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. default
	label.TextColor3 = Color3.fromRGB(220, 220, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 12)
	bar.Position = UDim2.new(0, 0, 0, 35)
	bar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	bar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	fill.Parent = bar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 24, 0, 24)
	knob.Position = UDim2.new((default - min) / (max - min), -12, 0.5, -12)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = bar

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local value = default
	local dragging = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			value = min + (max - min) * rel
			value = math.floor(value / step) * step
			fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			knob.Position = UDim2.new((value - min) / (max - min), -12, 0.5, -12)
			label.Text = text .. ": " .. value
			callback(value)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return frame
end

local function createDropdown(parent, text, options, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -40, 0, 55)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.6, 0, 1, 0)
	btn.Position = UDim2.new(0.4, 0, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	btn.Text = default
	btn.TextColor3 = Color3.fromRGB(200, 200, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamSemibold
	btn.Parent = frame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = btn

	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Size = UDim2.new(0.6, 0, 0, #options * 40 + 10)
	dropdownFrame.Position = UDim2.new(0.4, 0, 1, 5)
	dropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	dropdownFrame.Visible = false
	dropdownFrame.ZIndex = 10
	dropdownFrame.Parent = frame

	local dfCorner = Instance.new("UICorner")
	dfCorner.CornerRadius = UDim.new(0, 10)
	dfCorner.Parent = dropdownFrame

	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 40)
		optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 40 + 5)
		optBtn.BackgroundTransparency = 1
		optBtn.Text = opt
		optBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
		optBtn.TextScaled = true
		optBtn.Font = Enum.Font.GothamSemibold
		optBtn.Parent = dropdownFrame
		optBtn.MouseButton1Click:Connect(function()
			btn.Text = opt
			dropdownFrame.Visible = false
			callback(opt)
		end)
	end

	btn.MouseButton1Click:Connect(function()
		dropdownFrame.Visible = not dropdownFrame.Visible
	end)

	return frame
end

local function createColorPicker(parent, text, defaultColor, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -40, 0, 110)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 25)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, 80, 0, 80)
	preview.Position = UDim2.new(0, 0, 0, 30)
	preview.BackgroundColor3 = defaultColor
	preview.Parent = frame

	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 12)
	previewCorner.Parent = preview

	local previewStroke = Instance.new("UIStroke")
	previewStroke.Thickness = 3
	previewStroke.Color = Color3.fromRGB(138, 43, 226)
	previewStroke.Parent = preview

	local rSlider = createSlider(frame, "R", 0, 255, defaultColor.R * 255, 1, function(v)
		local c = Color3.fromRGB(v, preview.BackgroundColor3.G * 255, preview.BackgroundColor3.B * 255)
		preview.BackgroundColor3 = c
		callback(c)
	end)
	rSlider.Position = UDim2.new(0, 100, 0, 30)

	local gSlider = createSlider(frame, "G", 0, 255, defaultColor.G * 255, 1, function(v)
		local c = Color3.fromRGB(preview.BackgroundColor3.R * 255, v, preview.BackgroundColor3.B * 255)
		preview.BackgroundColor3 = c
		callback(c)
	end)
	gSlider.Position = UDim2.new(0, 100, 0, 55)

	local bSlider = createSlider(frame, "B", 0, 255, defaultColor.B * 255, 1, function(v)
		local c = Color3.fromRGB(preview.BackgroundColor3.R * 255, preview.BackgroundColor3.G * 255, v)
		preview.BackgroundColor3 = c
		callback(c)
	end)
	bSlider.Position = UDim2.new(0, 100, 0, 80)

	return frame
end

-- ESP LOGIC
getgenv().ESPEnabled = false
getgenv().ShowNames = true
getgenv().ShowHealth = true
getgenv().ShowDistance = true
getgenv().ESPMode = "Static"
getgenv().ESPPrimary = Color3.fromRGB(138, 43, 226)
getgenv().ESPSecondary = Color3.fromRGB(0, 255, 255)
getgenv().AnimationSpeed = 1.6

local ESPObjects = {}
local colorConn

local function createESP(plr)
	if plr == LocalPlayer or ESPObjects[plr] then return end
	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not head or not hum then return end

	local hl = Instance.new("Highlight")
	hl.FillColor = getgenv().ESPPrimary
	hl.OutlineColor = getgenv().ESPSecondary
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.Adornee = char
	hl.Parent = char

	local bb = Instance.new("BillboardGui")
	bb.Adornee = head
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(5, 0, 2, 0)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.Parent = char

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
	lbl.TextStrokeTransparency = 0
	lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bb

	ESPObjects[plr] = {Highlight = hl, Billboard = bb, Label = lbl}
end

local function updateESP()
	for plr, data in pairs(ESPObjects) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hum = plr.Character.Humanoid
			local dist = 0
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myRoot then dist = math.floor((myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude) end
			local txt = ""
			if getgenv().ShowNames then txt = txt .. plr.Name .. "\n" end
			if getgenv().ShowHealth then txt = txt .. "❤️ " .. math.floor(hum.Health) .. "/" .. hum.MaxHealth .. "\n" end
			if getgenv().ShowDistance then txt = txt .. "📍 " .. dist .. " studs" end
			data.Label.Text = txt
		else
			if data.Highlight then data.Highlight:Destroy() end
			if data.Billboard then data.Billboard:Destroy() end
			ESPObjects[plr] = nil
		end
	end
end

local function startColorAnim()
	if colorConn then return end
	colorConn = RunService.RenderStepped:Connect(function()
		if not getgenv().ESPEnabled then return end
		local t = tick() * getgenv().AnimationSpeed
		local col
		if getgenv().ESPMode == "Static" then
			col = getgenv().ESPPrimary
		elseif getgenv().ESPMode == "Rainbow" then
			col = Color3.fromHSV((t % 6) / 6, 1, 1)
		elseif getgenv().ESPMode == "Fast Rainbow" then
			col = Color3.fromHSV((t * 3 % 6) / 6, 1, 1)
		elseif getgenv().ESPMode == "Gradient" then
			col = getgenv().ESPPrimary:Lerp(getgenv().ESPSecondary, (math.sin(t * 1.5) + 1) / 2)
		elseif getgenv().ESPMode == "Iridescent" then
			col = Color3.fromHSV((t * 1.2 % 6) / 6, 0.9 + math.sin(t * 4) * 0.1, 1)
		elseif getgenv().ESPMode == "Prophecy" then
			col = Color3.fromHSV(0.75 + math.sin(t * 0.8) * 0.2, 1, 1)
		end
		for _, data in pairs(ESPObjects) do
			if data.Highlight then data.Highlight.FillColor = col end
		end
	end)
end

local function stopColorAnim()
	if colorConn then colorConn:Disconnect() colorConn = nil end
end

local espConn
local function toggleESP(v)
	getgenv().ESPEnabled = v
	if v then
		for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end
		if not espConn then espConn = RunService.RenderStepped:Connect(updateESP) end
		startColorAnim()
		Players.PlayerAdded:Connect(function(plr) if getgenv().ESPEnabled then task.wait(1) createESP(plr) end end)
	else
		for _, data in pairs(ESPObjects) do
			if data.Highlight then data.Highlight:Destroy() end
			if data.Billboard then data.Billboard:Destroy() end
		end
		ESPObjects = {}
		if espConn then espConn:Disconnect() espConn = nil end
		stopColorAnim()
	end
end

-- Movement
local function toggleInfJump(v)
	if v then
		UserInputService.JumpRequest:Connect(function()
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	end
end

local flyConn, bv, bg
local function toggleFly(v)
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	if v then
		hum.PlatformStand = true
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Parent = root
		bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.P = 12000
		bg.Parent = root
		flyConn = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			local move = Vector3.new(
				(UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
				(UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
				(UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
			)
			bv.Velocity = cam.CFrame:VectorToWorldSpace(move) * 100
			bg.CFrame = cam.CFrame
		end)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		if flyConn then flyConn:Disconnect() end
		if hum then hum.PlatformStand = false end
	end
end

local noclipConn
local function toggleNoclip(v)
	if noclipConn then noclipConn:Disconnect() end
	if v then
		noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, p in pairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
end

local function setSpeed(v)
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
end

-- Build ESP Section
createSectionHeader(ESPSection, "ESP CONTROLS")
createToggle(ESPSection, "Enable ESP", false, toggleESP)
createToggle(ESPSection, "Show Names", true, function(v) getgenv().ShowNames = v end)
createToggle(ESPSection, "Show Health", true, function(v) getgenv().ShowHealth = v end)
createToggle(ESPSection, "Show Distance", true, function(v) getgenv().ShowDistance = v end)

createDropdown(ESPSection, "Highlight Mode", {"Static", "Rainbow", "Fast Rainbow", "Gradient", "Iridescent", "Prophecy"}, "Static", function(v)
	getgenv().ESPMode = v
end)

createColorPicker(ESPSection, "Primary Color", Color3.fromRGB(138, 43, 226), function(c) getgenv().ESPPrimary = c end)
createColorPicker(ESPSection, "Secondary Color", Color3.fromRGB(0, 255, 255), function(c) getgenv().ESPSecondary = c end)

createSlider(ESPSection, "Animation Speed", 0.5, 5, 1.6, 0.1, function(v) getgenv().AnimationSpeed = v end)

-- Build Movement Section
createSectionHeader(MoveSection, "MOVEMENT CHEATS")
createToggle(MoveSection, "Infinite Jump", false, toggleInfJump)
createToggle(MoveSection, "Fly", false, toggleFly)
createToggle(MoveSection, "Noclip", false, toggleNoclip)
createSlider(MoveSection, "WalkSpeed", 16, 500, 16, 1, setSpeed)

-- Tab switching
ESPBtn.MouseButton1Click:Connect(function()
	ESPSection.Visible = true
	MoveSection.Visible = false
	TweenService:Create(ESPBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
	TweenService:Create(MoveBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
end)

MoveBtn.MouseButton1Click:Connect(function()
	ESPSection.Visible = false
	MoveSection.Visible = true
	TweenService:Create(MoveBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
	TweenService:Create(ESPBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
end)

-- Open / Close animations
local function openMenu()
	MainFrame.Visible = true
	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	MainFrame.BackgroundTransparency = 1
	local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 680, 0, 520),
		BackgroundTransparency = 0
	})
	tween:Play()
	tween.Completed:Wait()
end

local function closeMenu()
	local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		MainFrame.Visible = false
	end)
end

CloseBtn.MouseButton1Click:Connect(closeMenu)

FloatBtn.MouseButton1Click:Connect(function()
	if MainFrame.Visible then
		closeMenu()
	else
		openMenu()
	end
end)

-- Auto create ESP for existing players
for _, plr in ipairs(Players:GetPlayers()) do
	createESP(plr)
end

print("✅ Δ Cyberpunk Menu loaded | Premium custom UI ready")