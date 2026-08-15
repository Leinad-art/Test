-- Оптимизированный ESP Скрипт для Delta Exploit (Roblox Mobile)
-- Использует Highlight и BillboardGui для максимальной стабильности и FPS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки ESP (можно менять цвета и дистанцию)
local CONFIG = {
    BoxColorVisible = Color3.fromRGB(0, 255, 127),   -- Ярко-зеленый (виден)
    BoxColorWall = Color3.fromRGB(255, 38, 0),      -- Красный (за стеной)
    TracerColor = Color3.fromRGB(0, 204, 255),      -- Неоновый синий для линий
    TextColor = Color3.fromRGB(255, 255, 255),      -- Белый цвет текста
    MaxDistance = 1000,                             -- Максимальная дистанция работы ESP
    TeamCheck = true                                -- Игнорировать игроков из своей команды
}

local Storage = {} -- Хранилище объектов ESP для очистки

-- Функция проверки видимости (Рейкаст)
local function checkVisibility(targetCharacter)
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return false end
    if not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local destination = targetCharacter.HumanoidRootPart.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {localChar, targetCharacter, Camera}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil -- Если препятствий нет, возвращает true
end

-- Создание ESP для конкретного игрока
local function createESP(player)
    if player == LocalPlayer then return end

    local function onCharacterAdded(character)
        local root = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not root or not humanoid then return end

        -- Очистка старого ESP если персонаж переродился
        if Storage[player] then Storage[player]:Destroy() end

        -- Контейнер для элементов игрока
        local playerStorage = Instance.new("Folder")
        playerStorage.Name = "ESP_" .. player.Name
        playerStorage.Parent = CoreGui
        Storage[player] = playerStorage

        -- 1. Создание Бокса и Проверки стен (Highlight - самый оптимизированный метод)
        local highlight = Instance.new("Highlight")
        highlight.Name = "Box"
        highlight.Adornee = character
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0
        highlight.Parent = playerStorage

        -- 2. Создание Имени и Дистанции (BillboardGui)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Info"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = playerStorage

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = CONFIG.TextColor
        label.TextStrokeTransparency = 0
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.Parent = billboard

        -- 3. Создание Трейсеров (Линий) через ScreenGui Line
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "Tracers"
        screenGui.Parent = playerStorage

        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = CONFIG.TracerColor
        line.BorderSizePixel = 0
        line.Parent = screenGui

        -- Цикл обновления (RenderStepped для плавности)
        local connection
        connection = RunService.RenderStepped:Connect(function()
            -- Проверка валидности объектов
            if not player.Parent or not character.Parent or not root.Parent or humanoid.Health <= 0 then
                connection:Disconnect()
                playerStorage:Destroy()
                return
            end

            -- Командный чек
            if CONFIG.TeamCheck and player.Team == LocalPlayer.Team then
                highlight.Enabled = false
                billboard.Enabled = false
                line.Visible = false
                return
            end

            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            -- Расчет дистанции
            local distance = math.floor((root.Position - localRoot.Position).Magnitude)
            if distance > CONFIG.MaxDistance then
                highlight.Enabled = false
                billboard.Enabled = false
                line.Visible = false
                return
            end

            -- Включение элементов
            highlight.Enabled = true
            billboard.Enabled = true

            -- Обновление текста (Имя + Дистанция)
            label.Text = string.format("%s\n[%d studs]", player.DisplayName, distance)

            -- Динамическое изменение цвета (Проверка на видимость)
            if checkVisibility(character) then
                highlight.FillColor = CONFIG.BoxColorVisible
                highlight.OutlineColor = CONFIG.BoxColorVisible
            else
                highlight.FillColor = CONFIG.BoxColorWall
                highlight.OutlineColor = CONFIG.BoxColorWall
            end

            -- Обновление линий (Tracers)
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local viewportSize = Camera.ViewportSize
                local startX, startY = viewportSize.X / 2, viewportSize.Y -- Нижний центр экрана
                local endX, endY = screenPos.X, screenPos.Y

                local distanceX = endX - startX
                local distanceY = endY - startY
                local lineLength = math.sqrt(distanceX^2 + distanceY^2)

                line.Size = UDim2.new(0, lineLength, 0, 1.5) -- Оптимальная толщина для мобилок
                line.Position = UDim2.new(0, startX + distanceX / 2, 0, startY + distanceY / 2)
                line.Rotation = math.deg(math.atan2(distanceY, distanceX))
                line.Visible = true
            else
                line.Visible = false
            end
        end)
    end

    if player.Character then
        task.spawn(onCharacterAdded, player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Инициализация для текущих игроков
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

-- Подписка на новых игроков
Players.PlayerAdded:Connect(createESP)

-- Полная очистка при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    if Storage[player] then
        Storage[player]:Destroy()
        Storage[player] = nil
    end
end)
