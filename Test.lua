local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Настройки внешнего вида
local FILL_COLOR = Color3.fromRGB(255, 0, 0)     -- Цвет заливки (Красный)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255) -- Цвет контура (Белый)
local FILL_TRANSPARENCY = 0.6                  -- Прозрачность тела (0 - яркий, 1 - невидимый)
local OUTLINE_TRANSPARENCY = 0                 -- Прозрачность контура

-- Функция создания подсветки для конкретного персонажа
local function applyESP(character, player)
    -- Не подсвечиваем самого себя
    if player == LocalPlayer then return end
    
    -- Ожидаем загрузки ключевой части тела
    character:WaitForChild("HumanoidRootPart", 5)
    
    -- Удаляем старый ESP, если он был
    local oldHighlight = character:FindFirstChild("ClientESP")
    if oldHighlight then oldHighlight:Destroy() end
    
    -- Создаем новую подсветку
    local highlight = Instance.new("Highlight")
    highlight.Name = "ClientESP"
    highlight.FillColor = FILL_COLOR
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineColor = OUTLINE_COLOR
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    highlight.Adornee = character
    highlight.Parent = character
end

-- Функция отслеживания игрока
local function watchPlayer(player)
    if player.Character then
        applyESP(player.Character, player)
    end
    player.CharacterAdded:Connect(function(character)
        applyESP(character, player)
    end)
end

-- Запуск для текущих игроков в сервере
for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

-- Запуск для новых подключившихся игроков
Players.PlayerAdded:Connect(watchPlayer)
