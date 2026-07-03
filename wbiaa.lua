-- MM2_Jack_Rig.lua
-- Для мобильного GUI, все модули внутри
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Создаем главное окно
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Hub_Jack"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 600)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "☠ MM2 RIG by Jack & Bin"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Табы (кнопки-переключатели)
local Tabs = {"Murder", "Sheriff", "Misc", "Player", "Settings"}
local TabButtons = {}
local CurrentTab = "Murder"

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -100)
ContentFrame.Position = UDim2.new(0, 5, 0, 85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 4
ContentFrame.Parent = MainFrame

local function CreateTabButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #Tabs, -2, 1, -4)
    btn.Position = UDim2.new(pos, 0, 0, 2)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.6
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    btn.Parent = TabContainer
    return btn
end

for i, name in ipairs(Tabs) do
    local btn = CreateTabButton(name, (i-1)/#Tabs)
    btn.MouseButton1Click:Connect(function()
        CurrentTab = name
        UpdateContent()
    end)
    TabButtons[name] = btn
end

-- Функции-помощники для GUI элементов
local function MakeToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 80)
    toggle.BorderSizePixel = 0
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextScaled = true
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = toggle
    toggle.Parent = frame

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 80)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return frame
end

local function MakeButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 38)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Переменные состояний
local espEnabled = false
local espMurder = true
local espSheriff = true
local espPlayers = false
local flingEnabled = false
local rageMode = false
local autoShoot = false
local selectedTarget = nil

-- ESP функция (простые линии и тексты)
local function UpdateESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local isMurder = v:FindFirstChild("Murder") -- пример, по факту надо проверять роль
            local isSheriff = v:FindFirstChild("Sheriff")
            -- упрощенно: красим по ролям (в MM2 обычно есть удача, но для демо)
            local color = Color3.fromRGB(255,255,255)
            if isMurder then color = Color3.fromRGB(255,0,0) end
            if isSheriff then color = Color3.fromRGB(0,0,255) end
            -- рисуем BillboardGui (для краткости опускаю полную реализацию)
        end
    end
end

-- Основной контент
local function UpdateContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    if CurrentTab == "Murder" then
        MakeToggle(ContentFrame, "ESP Murder", true, function(s) espMurder = s end)
        MakeToggle(ContentFrame, "Rage Mode (auto-kill)", false, function(s) rageMode = s end)
        MakeButton(ContentFrame, "Fling all players", function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-500,500), 300, math.random(-500,500))
                end
            end
        end)
        MakeButton(ContentFrame, "Teleport to Murder", function()
            -- поиск убийцы и телепорт
        end)

    elseif CurrentTab == "Sheriff" then
        MakeToggle(ContentFrame, "ESP Sheriff", true, function(s) espSheriff = s end)
        MakeToggle(ContentFrame, "Auto Shoot (tap screen)", false, function(s) autoShoot = s end)
        MakeButton(ContentFrame, "Shoot (manual)", function()
            -- выстрел шерифа
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Tool") then
                local tool = LocalPlayer.Character:FindFirstChild("Tool")
                if tool:FindFirstChild("Fire") then
                    tool:FindFirstChild("Fire"):FireServer()
                end
            end
        end)
        -- Кнопка для стрельбы по тапу (дублируем)
        local shootBtn = Instance.new("ImageButton")
        shootBtn.Size = UDim2.new(0, 70, 0, 70)
        shootBtn.Position = UDim2.new(0.8, 0, 0.8, 0)
        shootBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
        shootBtn.Image = "rbxassetid://0" -- просто круг
        shootBtn.BackgroundTransparency = 0.3
        shootBtn.Parent = ScreenGui
        local c2 = Instance.new("UICorner")
        c2.CornerRadius = UDim.new(1, 0)
        c2.Parent = shootBtn
        shootBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Tool") then
                local tool = LocalPlayer.Character:FindFirstChild("Tool")
                if tool:FindFirstChild("Fire") then
                    tool:FindFirstChild("Fire"):FireServer()
                end
            end
        end)

    elseif CurrentTab == "Misc" then
        MakeToggle(ContentFrame, "ESP Players", false, function(s) espPlayers = s end)
        MakeButton(ContentFrame, "Fly (Noclip)", function()
            -- noclip
        end)
        MakeButton(ContentFrame, "Infinite Jump", function()
            -- инф. прыжок
        end)
        MakeButton(ContentFrame, "Unlock all skins (client)", function()
            -- чисто визуально
        end)

    elseif CurrentTab == "Player" then
        MakeButton(ContentFrame, "Heal", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 100
            end
        end)
        MakeButton(ContentFrame, "WalkSpeed x2", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 32
            end
        end)
        MakeButton(ContentFrame, "JumpPower x2", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 100
            end
        end)

    elseif CurrentTab == "Settings" then
        MakeToggle(ContentFrame, "ESP enabled", false, function(s) espEnabled = s end)
        MakeButton(ContentFrame, "Reset all", function()
            -- сброс всех состояний
        end)
        MakeButton(ContentFrame, "Close GUI", function()
            ScreenGui:Destroy()
        end)
    end

    -- Обновляем канвас
    local count = #ContentFrame:GetChildren()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, count * 40 + 20)
end

UpdateContent()

-- ESP Loop (упрощенно)
RunService.RenderStepped:Connect(function()
    if espEnabled then
        UpdateESP()
    end
end)

-- Обработка тапа для автострельбы (если включено)
UserInputService.TouchTap:Connect(function()
    if autoShoot then
        -- эмулируем выстрел
    end
end)
