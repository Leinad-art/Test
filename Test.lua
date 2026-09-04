local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============================================================================
-- НАСТРОЙКИ (Вы можете менять эти значения)
-- ============================================================================
local SETTINGS = {
	AimEnabled = true,          -- Включить/выключить автоприцеливание
	EspEnabled = true,          -- Включить/выключить подсветку игроков
	
	FovRadius = 150,            -- Размер зоны захвата в пикселях (радиус аима)
	
	AllyColor = Color3.fromRGB(0, 255, 0),   -- Цвет союзников (Зеленый)
	EnemyColor = Color3.fromRGB(255, 0, 0),  -- Цвет врагов (Красный)
}

local isAiming = false
local currentTarget = nil

-- ============================================================================
-- ПРОВЕРКА ВИДИМОСТИ (RAYCASTING ЧЕРЕЗ СТЕНЫ)
-- ============================================================================
local function isVisible(targetHead)
	if not targetHead then return false end
	
	local origin = camera.CFrame.Position
	local direction = targetHead.Position - origin
	
	local raycastParams = RaycastParams.new()
	-- Игнорируем персонажа самого игрока при проверке луча
	if localPlayer.Character then
		raycastParams.FilterDescendantsInstances = {localPlayer.Character}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end
	
	local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
	
	-- Если луч ни обо что не ударился или попал прямо в деталь персонажа цели
	if raycastResult then
		return raycastResult.Instance:IsDescendantOf(targetHead.Parent)
	end
	
	return false
end

-- ============================================================================
-- ПОИСК БЛИЖАЙШЕЙ ГОЛОВЫ В ЗОНЕ FOV
-- ============================================================================
local function getClosestHeadInFov()
	local closestHead = nil
	local shortestDistance = SETTINGS.FovRadius
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local character = player.Character
			local head = character.Head
			local human = character:FindFirstChildOfClass("Humanoid")
			
			-- Проверяем, что игрок жив и это не союзник по команде (если команды настроены)
			if human and human.Health > 0 then
				local isAlly = (player.Team == localPlayer.Team) and (localPlayer.Team ~= nil)
				
				-- Переводим 3D координаты головы в 2D координаты экрана
				local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
				
				if onScreen then
					-- Считаем расстояние от центра экрана до головы игрока
					local mousePos = UserInputService:GetMouseLocation()
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					
					-- Если игрок в пределах круга FOV и ближе всех остальных
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
	
	return closestHead
end

-- ============================================================================
-- НАВЕДЕНИЕ КАМЕРЫ (LOCK-ON)
-- ============================================================================
RunService.RenderStepped:Connect(function()
	if SETTINGS.AimEnabled and isAiming then
		-- Если текущая цель потеряна, умерла или спряталась за стену, ищем новую
		if not currentTarget or not currentTarget.Parent or not isVisible(currentTarget) then
			currentTarget = getClosestHeadInFov()
		end
		
		if currentTarget then
			-- Плавно или мгновенно направляем камеру на голову цели
			camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
		end
	else
		currentTarget = nil
	end
end)

-- ============================================================================
-- СЛУШАТЕЛИ МЫШИ (ПКМ)
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Правая кнопка мыши
		isAiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = false
	end
end)

-- ============================================================================
-- СИСТЕМА ДЛЯ ESP ПОДСВЕТКИ (HIGHLIGHTS)
-- ============================================================================
local function applyHighlight(player)
	if player == localPlayer then return end
	
	local function onCharacterAdded(character)
		if not SETTINGS.EspEnabled then return end
		
		-- Ждем полной загрузки персонажа
		task.wait(0.5) 
		if not character:Parent then return end
		
		-- Удаляем старую подсветку, если она была
		local oldHighlight = character:FindFirstChild("GameHighlight")
		if oldHighlight then oldHighlight:Destroy() end
		
		-- Создаем новый Highlight
		local highlight = Instance.new("Highlight")
		highlight.Name = "GameHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены
		highlight.FillOpacity = 0.25
		highlight.OutlineOpacity = 1
		
		-- Определяем цвет в зависимости от команды
		local isAlly = (player.Team == localPlayer.Team) and (localPlayer.Team ~= nil)
		if isAlly then
			highlight.FillColor = SETTINGS.AllyColor
			highlight.OutlineColor = SETTINGS.AllyColor
		else
			highlight.FillColor = SETTINGS.EnemyColor
			highlight.OutlineColor = SETTINGS.EnemyColor
		end
		
		highlight.Parent = character
	end
	
	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Включаем ESP для текущих и новых игроков
for _, player in ipairs(Players:GetPlayers()) do
	applyHighlight(player)
end
Players.PlayerAdded:Connect(applyHighlight)
