print("[ESP] Скрипт успешно запущен. Нажмите RightControl для ВКЛ/ВЫКЛ")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Настройки
local TOGGLE_KEY = Enum.KeyCode.RightControl -- Клавиша для переключения (можно поменять)
local FILL_COLOR = Color3.fromRGB(255, 0, 0)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)

-- Глобальное состояние (включено или выключено)
_G.ESP_Enabled = true

-- Функция создания подсветки
local function applyESP(character, player)
    if player == LocalPlayer then return end
    
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    
    -- Очищаем старый ESP, если он был
    local old = character:FindFirstChild("ClientESP")
    if old then old:Destroy() end
    
    -- Создаем подсветку только если ESP включен в настройках
    if _G.ESP_Enabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ClientESP"
        highlight.FillColor = FILL_COLOR
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = OUTLINE_COLOR
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = character
    end
end

-- Функция полной очистки всех подсветок на сервере
local function removeAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local old = player.Character:FindFirstChild("ClientESP")
            if old then old:Destroy() end
        end
    end
end

-- Обновление состояния всех игроков
local function refreshAllESP()
    if _G.ESP_Enabled then
        print("[ESP] Подсветка ВКЛЮЧЕНА")
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                task.spawn(applyESP, player.Character, player)
            end
        end
    else
        print("[ESP] Подсветка ВЫКЛЮЧЕНА")
        removeAllESP()
    end
end

-- Отслеживание захода игроков
local function watchPlayer(player)
    if player.Character then
        task.spawn(applyESP, player.Character, player)
    end
    player.CharacterAdded:Connect(function(character)
        task.spawn(applyESP, character, player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end
Players.PlayerAdded:Connect(watchPlayer)

-- Обработка нажатия клавиши для ВКЛ/ВЫКЛ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Если игрок пишет в чат, нажатия кнопок игнорируются
    if gameProcessed then return end 
    
    if input.KeyCode == TOGGLE_KEY then
        _G.ESP_Enabled = not _G.ESP_Enabled
        refreshAllESP()
    end
end)
