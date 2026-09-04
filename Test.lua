local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============================================================================
-- НАСТРОЙКИ
-- ============================================================================
local SETTINGS = {
	AimEnabled = true,          -- Включить прицеливание по умолчанию
	EspEnabled = true,          -- Включить ESP по умолчанию
	
	FovRadius = 250,            -- Радиус захвата цели (в пикселях)
	
	AllyColor = Color3.fromRGB(0, 255, 0),   -- Зеленый для своих
	EnemyColor = Color3.fromRGB(255, 0, 0),  -- Красный для врагов
	
	-- Клавиши для переключения функций во время игры:
	ToggleAimKey = Enum.KeyCode.K, -- Нажмите K чтобы включить/выключить Аим
	ToggleEspKey = Enum.KeyCode.H, -- Нажмите H чтобы включить/выключить ESP
}

local isAiming = false
local currentTarget = nil

-- ============================================================================
-- ПРОВЕРКА ЧЕРЕЗ СТЕНЫ (RAYCASTING)
-- ============================================================================
local function isVisible(targetHead)
	if not targetHead then return false end
	
	local origin = camera.CFrame.Position
	local direction = targetHead.Position - origin
	
	local raycastParams = RaycastParams.new()
	if localPlayer.Character then
		-- Игнорируем себя, аксессуары и инструменты при проверке луча
		raycastParams.FilterDescendantsInstances = {localPlayer.Character, camera}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end
	
	local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
	
	if raycastResult then
		-- Если луч уперся в объект, проверяем, принадлежит ли он целевому персонажу
		return raycastResult.Instance:IsDescendantOf(targetHead.Parent)
	end
	
	-- Если на пути вообще ничего нет (чистое небо)
	return true
end

-- ============================================================================
-- ПОИСК БЛИЖАЙШЕЙ ЦЕЛИ
-- ============================================================================
local function getClosestHeadInFov()
	local closestHead = nil
	local shortestDistance = SETTINGS.FovRadius
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local character = player.Character
			local head = character.Head
			local human = character:FindFirstChildOfClass("Humanoid")
			
			if human and human.Health > 0 then
				-- Исправление: Если команд нет, то игрок всегда ВРАГ
				local isAlly = false
				if localPlayer.Team and player.Team then
					isAlly = (player.Team == localPlayer.Team)
				end
				
				-- Целимся только во врагов
				if not isAlly then
					local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
					
					if onScreen then
						local mousePos = UserInputService:GetMouseLocation()
						local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
						
						if distance < shortestDistance then
							if isVisible(head) then
								shortestDistance = distance
								closestHead = head
							end
						end
					end
				end
			end
		end
	end
	
	return closestHead
end

-- ============================================================================
-- НАВЕДЕНИЕ КАМЕРЫ (КАЖДЫЙ КАДР)
-- ============================================================================
RunService.RenderStepped:Connect(function()
	if SETTINGS.AimEnabled and isAiming then
		if not currentTarget or not currentTarget.Parent or not isVisible(currentTarget) then
			currentTarget = getClosestHeadInFov()
		end
		
		if currentTarget then
			-- Плавное слежение за головой
			local targetCFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
			camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.25) -- 0.25 обеспечивает плавность. Поставьте 1 для мгновенного наведения
		end
	else
		currentTarget = nil
	end
end)

-- ============================================================================
-- ОБНОВЛЕНИЕ И ПОДДЕРЖКА ESP ПОДСВЕТКИ
-- ============================================================================
local function updateEsp()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local character = player.Character
			local oldHighlight = character:FindFirstChild("GameHighlight")
			
			if oldHighlight then 
				oldHighlight:Destroy() 
			end
			
			if SETTINGS.EspEnabled then
				local highlight = Instance.new("Highlight")
				highlight.Name = "GameHighlight"
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillOpacity = 0.3
				highlight.OutlineOpacity = 1
				
				-- Проверка на союзника для цвета
				local isAlly = false
				if localPlayer.Team and player.Team then
					isAlly = (player.Team == localPlayer.Team)
				end
				
				local color = isAlly and SETTINGS.AllyColor or SETTINGS.EnemyColor
				highlight.FillColor = color
				highlight.OutlineColor = color
				highlight.Parent = character
			end
		end
	end
end

-- Включаем отслеживание появления новых персонажей
local function setupPlayerEsp(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5) -- Ждем загрузки частей тела в Workspace
		updateEsp()
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayerEsp(player)
end
Players.PlayerAdded:Connect(setupPlayerEsp)
Players.PlayerRemoving:Connect(updateEsp)

-- Обновляем ESP при старте
task.spawn(updateEsp)

-- ============================================================================
-- ОБРАБОТКА НАЖАТИЙ (КЛАВИАТУРА И МЫШЬ)
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	-- Нажатие ПКМ (Зажать для прицеливания)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = true
	end
	
	-- Переключение Аима на кнопку K
	if input.KeyCode == SETTINGS.ToggleAimKey then
		SETTINGS.AimEnabled = not SETTINGS.AimEnabled
		print("Автоприцеливание:", SETTINGS.AimEnabled and "ВКЛ" or "ВЫКЛ")
	end
	
	-- Переключение ESP на кнопку H
	if input.KeyCode == SETTINGS.ToggleEspKey then
		SETTINGS.EspEnabled = not SETTINGS.EspEnabled
		updateEsp()
		print("ESP Подсветка:", SETTINGS.EspEnabled and "ВКЛ" or "ВЫКЛ")
	end
end)

UserInputService.InputEnded:Connect(function(input)
	-- Отпускание ПКМ (Прекратить прицеливание)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = false
	end
end)
