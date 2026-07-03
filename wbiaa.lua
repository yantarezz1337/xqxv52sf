-- === BIN'S ULTIMATE MM2 HUB v2 for Delta Mobile ===
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Bin's MM2 Ultimate",
    SubTitle = "Delta | Полный Rage",
    TabWidth = 170,
    Size = UDim2.fromOffset(600, 500),
    Theme = "Dark",
    Acrylic = false
})

local Tabs = {
    Combat = Window:AddTab({Title = "Combat", Icon = "⚔"}),
    ESP = Window:AddTab({Title = "ESP", Icon = "👁"}),
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
local godMode = false
local antiStaff = true

local espCache = {}

-- ==================== ESP ====================
local function createESP(plr)
    if espCache[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2.5
    box.Filled = false
    box.Transparency = 1

    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Transparency = 1

    espCache[plr] = {Box = box, Name = nameTag}
end

local function updateESP()
    for plr, drawings in pairs(espCache) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = plr.leaderstats and plr.leaderstats:FindFirstChild("Role") and plr.leaderstats.Role.Value or "Unknown"
            local color = role == "Murderer" and Color3.new(1,0,0) or (role == "Sheriff" and Color3.new(0,0.8,1) or Color3.new(1,1,1))

            if not espCache[plr] then createESP(plr) end

            local root = plr.Character.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local top = camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0))
                local bottom = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                local height = bottom.Y - top.Y
                local width = height * 0.65

                local esp = espCache[plr]
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(pos.X - width/2, top.Y)
                esp.Box.Color = color
                esp.Box.Visible = espEnabled

                esp.Name.Text = string.format("%s [%s]", plr.Name, role)
                esp.Name.Position = Vector2.new(pos.X, top.Y - 25)
                esp.Name.Color = color
                esp.Name.Visible = espEnabled
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- ==================== Silent Aim ====================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if silentAim and getnamecallmethod() == "FireServer" and tostring(self) == "ShootGun" then
        local closestDist = math.huge
        local closestPart = nil

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPart = plr.Character.HumanoidRootPart
                end
            end
        end

        if closestPart then
            args[2] = closestPart.Position
        end
    end
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- ==================== Aura & Fling ====================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    -- Murder Aura
    if murderAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude < 30 then
                    plr.Character.Humanoid.Health = 0
                end
            end
        end
    end

    -- Better Fling
    if rageFling then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = plr.Character.HumanoidRootPart
                tRoot.Velocity = tRoot.Velocity + Vector3.new(math.random(-120,120), 120, math.random(-120,120))
            end
        end
    end
end)

-- ==================== Auto Farm ====================
RunService.Heartbeat:Connect(function()
    if autoFarm and LocalPlayer.Character then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Coin" or obj.Name == "Money" or obj:IsA("BasePart") and obj:FindFirstChild("TouchInterest") then
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    obj.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
end)

-- ==================== GUI ====================
local shootBtn = Instance.new("TextButton")
shootBtn.Size = UDim2.new(0, 130, 0, 130)
shootBtn.Position = UDim2.new(0.8, 0, 0.6, 0)
shootBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
shootBtn.Text = "🔫\nAUTO\nSHOOT"
shootBtn.TextScaled = true
shootBtn.Font = Enum.Font.GothamBold
shootBtn.Parent = LocalPlayer:WaitForChild("PlayerGui")

shootBtn.MouseButton1Click:Connect(function()
    if autoShoot then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- Combat Tab
Tabs.Combat:AddToggle("SilentAim", {Title = "Silent Aim", Default = true, Callback = function(v) silentAim = v end})
Tabs.Combat:AddToggle("MurderAura", {Title = "Murder Aura", Default = false, Callback = function(v) murderAura = v end})
Tabs.Combat:AddToggle("RageFling", {Title = "Rage Fling", Default = false, Callback = function(v) rageFling = v end})
Tabs.Combat:AddToggle("AutoShoot", {Title = "Auto Shoot + Button", Default = false, Callback = function(v) 
    autoShoot = v 
    shootBtn.Visible = v 
end})

-- ESP Tab
Tabs.ESP:AddToggle("ESP", {Title = "Enable ESP", Default = true, Callback = function(v) espEnabled = v end})

-- Movement Tab
Tabs.Movement:AddSlider("WalkSpeed", {Title = "WalkSpeed", Min = 16, Max = 300, Default = 70, Callback = function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})

Tabs.Movement:AddToggle("GodMode", {Title = "God Mode", Default = false, Callback = function(v)
    godMode = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.MaxHealth = 9e9
        LocalPlayer.Character.Humanoid.Health = 9e9
    end
end})

-- Farm Tab
Tabs.Farm:AddToggle("AutoFarm", {Title = "Auto Farm Coins", Default = false, Callback = function(v) autoFarm = v end})

-- Misc Tab
Tabs.Misc:AddToggle("AntiStaff", {Title = "Anti-Staff", Default = true, Callback = function(v) antiStaff = v end})

-- Settings
Tabs.Settings:AddButton({Title = "Destroy GUI", Callback = function()
    shootBtn:Destroy()
    Window:Destroy()
end})

Fluent:Notify({Title = "Success", Content = "Bin's Ultimate MM2 Hub загружен. Делай что хочешь.", Duration = 5})
