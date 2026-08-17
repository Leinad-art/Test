print("[ESP] Скрипт успешно запущен и начинает работу...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Если LocalPlayer еще не загрузился, ждем его
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Настройки
local FILL_COLOR = Color3.fromRGB(255, 0, 0)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)

local function applyESP(character, player)
    if player == LocalPlayer then return end
    
    -- Безопасное ожидание загрузки персонажа
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then 
        print("[ESP] Предупреждение: Не удалось дождаться HumanoidRootPart для " .. player.Name)
        return 
    end
    
    -- Удаляем старый ESP, если он остался
    local old = character:FindFirstChild("ClientESP")
    if old then old:Destroy() end
    
    -- Создаем подсветку
    local highlight = Instance.new("Highlight")
    highlight.Name = "ClientESP"
    highlight.FillColor = FILL_COLOR
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = OUTLINE_COLOR
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character
    
    print("[ESP] Подсветка успешно создана для: " .. player.Name)
end

local function watchPlayer(player)
    if player.Character then
        task.spawn(applyESP, player.Character, player)
    end
    player.CharacterAdded:Connect(function(character)
        task.spawn(applyESP, character, player)
    end)
end

-- Обрабатываем текущих игроков
for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

-- Слушаем новых игроков
Players.PlayerAdded:Connect(watchPlayer)
print("[ESP] Инициализация завершена. Ожидаем игроков...")
