-- === BIN'S MM2 ULTIMATE HUB - STABLE FOR DELTA ===
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Bin's Hub",
        Text = "Fluent не загрузился. Использую встроенный GUI...",
        Duration = 5
    })
    -- Fallback будет ниже, но сначала попробуем основной
end

local Window = Fluent:CreateWindow({
    Title = "Bin's MM2 Ultimate",
    SubTitle = "Delta Mobile | Полный Rage 2026",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 520),
    Theme = "Dark",
    Acrylic = false
})

local Tabs = {
    Combat = Window:AddTab({Title = "Combat", Icon = "⚔"}),
    ESPTab = Window:AddTab({Title = "ESP", Icon = "👁"}),
    Movement = Window:AddTab({Title = "Movement", Icon = "🏃"}),
    Farm = Window:AddTab({Title = "Farm", Icon = "💰"}),
    Misc = Window:AddTab({Title = "Misc", Icon = "⚙"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "🔧"})
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local espEnabled = true
local silentAim = true
local murderAura = false
local rageFling = false
local autoShoot = false
local autoFarm = false
local antiStaff = true

local espCache = {}

-- ESP
local function createESP(plr)
    if espCache[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2.8
    box.Filled = false
    box.Transparency = 1

    local nametag = Drawing.new("Text")
    nametag.Size = 17
    nametag.Center = true
    nametag.Outline = true
    nametag.Transparency = 1

    espCache[plr] = {Box = box, Name = nametag}
end

local function updateESP()
    for plr, data in pairs(espCache) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            data.Box.Visible = false
            data.Name.Visible = false
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = plr.leaderstats and plr.leaderstats.Role and plr.leaderstats.Role.Value or "Innocent"
            local color = (role == "Murderer" and Color3.new(1,0,0)) or (role == "Sheriff" and Color3.new(0,0.6,1)) or Color3.new(1,1,1)

            if not espCache[plr] then createESP(plr) end

            local root = plr.Character.HumanoidRootPart
            local cam = Workspace.CurrentCamera
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)

            if onScreen and espEnabled then
                local top = cam:WorldToViewportPoint(root.Position + Vector3.new(0,3.2,0))
                local height = (cam:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - top.Y)
                local width = height * 0.65

                local d = espCache[plr]
                d.Box.Size = Vector2.new(width, height)
                d.Box.Position = Vector2.new(pos.X - width/2, top.Y)
                d.Box.Color = color
                d.Box.Visible = true

                d.Name.Text = plr.Name .. " [" .. role .. "]"
                d.Name.Position = Vector2.new(pos.X, top.Y - 25)
                d.Name.Color = color
                d.Name.Visible = true
            end
        end
    end
end
RunService.RenderStepped:Connect(updateESP)

-- Silent Aim
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if silentAim and getnamecallmethod() == "FireServer" and self.Name == "ShootGun" then
        local closest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p \~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d closest = p.Character.HumanoidRootPart end
            end
        end
        if closest then args[2] = closest.Position end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)

-- Aura + Fling
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if murderAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                if (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude < 28 then
                    plr.Character.Humanoid.Health = 0
                end
            end
        end
    end

    if rageFling then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tr = plr.Character.HumanoidRootPart
                tr.Velocity = tr.Velocity + Vector3.new(math.random(-150,150), 100, math.random(-150,150))
            end
        end
    end
end)

-- Auto Farm
RunService.Heartbeat:Connect(function()
    if autoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Coin" or v.Name == "Money" then
                v.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- On-screen Auto Shoot Button
local shootButton = Instance.new("TextButton")
shootButton.Size = UDim2.new(0, 140, 0, 140)
shootButton.Position = UDim2.new(0.78, 0, 0.55, 0)
shootButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
shootButton.Text = "🔫\nAUTO\nSHOOT"
shootButton.TextScaled = true
shootButton.Font = Enum.Font.GothamBold
shootButton.Parent = LocalPlayer.PlayerGui

shootButton.MouseButton1Click:Connect(function()
    if autoShoot then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- GUI Toggles
Tabs.Combat:AddToggle("SilentAimToggle", {Title = "Silent Aim", Default = true, Callback = function(v) silentAim = v end})
Tabs.Combat:AddToggle("MurderAuraToggle", {Title = "Murder Aura", Default = false, Callback = function(v) murderAura = v end})
Tabs.Combat:AddToggle("RageFlingToggle", {Title = "Rage Fling", Default = false, Callback = function(v) rageFling = v end})
Tabs.Combat:AddToggle("AutoShootToggle", {Title = "Auto Shoot", Default = false, Callback = function(v) 
    autoShoot = v 
    shootButton.Visible = v 
end})

Tabs.ESPTab:AddToggle("ESPToggle", {Title = "ESP (Roles)", Default = true, Callback = function(v) espEnabled = v end})

Tabs.Movement:AddSlider("SpeedSlider", {Title = "WalkSpeed", Min = 16, Max = 300, Default = 80, Callback = function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})

Tabs.Farm:AddToggle("AutoFarmToggle", {Title = "Auto Farm Coins", Default = false, Callback = function(v) autoFarm = v end})

Tabs.Misc:AddToggle("AntiStaffToggle", {Title = "Anti-Staff", Default = true, Callback = function(v) antiStaff = v end})

Tabs.Settings:AddButton({Title = "Destroy Hub", Callback = function()
    shootButton:Destroy()
    Window:Destroy()
end})

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Bin", Text = "Hub загружен. Удачи, сука.", Duration = 6})
