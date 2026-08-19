-- ВЕРСИЯ ДЛЯ ИНЖЕКТОРОВ (EXPLOIT READ_ONLY)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)

local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50

-- Защита от повторного запуска (удаляем старое меню, если оно было)
if CoreGui:FindFirstChild("ExploitMenuGui") then
	CoreGui.ExploitMenuGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExploitMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui -- Специально для читов, чтобы меню не удалялось

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- В инжекторах старый Draggable обычно работает
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "EXPLOIT MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local function createButton(text, position, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 160, 0, 35)
	button.Position = position
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 16
	button.Parent = mainFrame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = button
	return button
end

local flyBtn = createButton("Fly: OFF", UDim2.new(0, 20, 0, 50), Color3.fromRGB(60, 60, 60))

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 160, 0, 35)
speedInput.Position = UDim2.new(0, 20, 0, 100)
speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedInput.BorderSizePixel = 0
speedInput.Text = "Speed: 50"
speedInput.TextColor3 = Color3.fromRGB(200, 200, 200)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 14
speedInput.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedInput

local noclipBtn = createButton("Noclip: OFF", UDim2.new(0, 20, 0, 150), Color3.fromRGB(60, 60, 60))

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, 0, 0, 30)
hintLabel.Position = UDim2.new(0, 0, 1, -35)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "Клавиша [P] — скрыть меню"
hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
hintLabel.Font = Enum.Font.SourceSansItalic
hintLabel.TextSize = 12
hintLabel.Parent = mainFrame

speedInput.FocusLost:Connect(function()
	local numericValue = tonumber(speedInput.Text:match("%d+"))
	if numericValue then flySpeed = numericValue end
	speedInput.Text = "Speed: " .. tostring(flySpeed)
end)

local bodyVelocity, bodyGyro
flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled then
		flyBtn.Text = "Fly: ON"
		flyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
		
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
		bodyVelocity.Parent = root
		
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root
		
		humanoid.PlatformStand = true
	else
		flyBtn.Text = "Fly: OFF"
		flyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		humanoid.PlatformStand = false
	end
end)

RunService.RenderStepped:Connect(function()
	if flyEnabled and root and character:FindFirstChild("Humanoid") then
		local camera = workspace.CurrentCamera
		local moveDirection = Vector3.new(0,0,0)
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
		
		if bodyVelocity and bodyGyro then
			bodyVelocity.Velocity = moveDirection.Unit * flySpeed
			if moveDirection == Vector3.new(0,0,0) then bodyVelocity.Velocity = Vector3.new(0,0,0) end
			bodyGyro.CFrame = camera.CFrame
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
	noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(60, 60, 60)
end)

RunService.Stepped:Connect(function()
	if noclipEnabled and character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.P then mainFrame.Visible = not mainFrame.Visible end
end)
