-- Bin's MM2 Advanced Hub for Delta
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Bin's MM2 Hub",
    SubTitle = "Delta | Full Rage Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(590, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Murder = Window:AddTab({ Title = "Murder", Icon = "🔪" }),
    Sheriff = Window:AddTab({ Title = "Sheriff", Icon = "🔫" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "👁" }),
    Player = Window:AddTab({ Title = "Player", Icon = "👤" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "⚙" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "⚙️" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local espTable = {}
local autoShoot = false
local rageFling = false
local murderAura = false
local silentAim = false
local antiStaff = true
local autoFarm = false

-- === ESP ===
local function CreateESP(character, color, text)
    if espTable[character] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2.5
    box.Filled = false
    box.Color = color
    box.Transparency = 1

    local name = Drawing.new("Text")
    name.Size = 17
    name.Center = true
    name.Outline = true
    name.Color = color
    name.Text = text

    espTable[character] = {Box = box, Name = name}
end

local function UpdateESP()
    for char, drawings in pairs(espTable) do
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = plr.leaderstats and plr.leaderstats.Role or "Innocent"
            local color = (role == "Murderer" and Color3.new(1,0,0)) or (role == "Sheriff" and Color3.new(0,0.7,1)) or Color3.new(1,1,1)

            if not espTable[plr.Character] then
                CreateESP(plr.Character, color, plr.Name .. " ["..role.."]")
            end

            local root = plr.Character.HumanoidRootPart
            local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
            
            if onScreen then
                local top = Workspace.CurrentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.5, 0))
                local bottom = Workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = bottom.Y - top.Y
                local w = h * 0.65

                local esp = espTable[plr.Character]
                esp.Box.Size = Vector2.new(w, h)
                esp.Box.Position = Vector2.new(screenPos.X - w/2, top.Y)
                esp.Box.Visible = true

                esp.Name.Position = Vector2.new(screenPos.X, top.Y - 22)
                esp.Name.Text = plr.Name .. " ["..role.."]"
                esp.Name.Visible = true
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- === Silent Aim ===
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if silentAim and method == "FireServer" and self.Name == "ShootGun" then
        local closest = nil
        local shortest = math.huge

        for _, plr in pairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = plr.Character.HumanoidRootPart
                end
            end
        end

        if closest then
            args[2] = closest.Position
        end
    end

    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- === Murder Aura ===
RunService.Heartbeat:Connect(function()
    if murderAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 25 then
                    plr.Character.Humanoid.Health = 0
                end
            end
        end
    end
end)

-- === Better Fling ===
RunService.Heartbeat:Connect(function()
    if rageFling and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        for _, plr in pairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = plr.Character.HumanoidRootPart
                targetRoot.Velocity = targetRoot.Velocity + (targetRoot.Position - root.Position).Unit * 150 + Vector3.new(0, 80, 0)
            end
        end
    end
end)

-- === Auto Farm Coins ===
RunService.Heartbeat:Connect(function()
    if autoFarm then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "Coin" or v.Name == "Money" or v.Name == "Drop" then
                if v:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    v.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
end)

-- === Anti-Staff ===
Players.PlayerAdded:Connect(function(plr)
    if antiStaff and (plr.Name:lower():find("mod") or plr.Name:lower():find("admin") or plr.Name:lower():find("staff")) then
        Fluent:Notify({Title = "ANTI-STAFF", Content = "Staff detected: " .. plr.Name, Duration = 8})
        LocalPlayer:Kick("Staff joined. Stay safe.")
    end
end)

-- GUI
local shootButton = Instance.new("TextButton")
shootButton.Size = UDim2.new(0, 110, 0, 110)
shootButton.Position = UDim2.new(0.82, 0, 0.65, 0)
shootButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
shootButton.Text = "🔫 AUTO\nSHOOT"
shootButton.TextScaled = true
shootButton.Font = Enum.Font.GothamBold
shootButton.Parent = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

shootButton.MouseButton1Click:Connect(function()
    if autoShoot then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- Tabs
Tabs.Murder:AddToggle("MurderAura", {Title = "Murder Aura (Kill Nearby)", Default = false, Callback = function(v) murderAura = v end})
Tabs.Murder:AddToggle("RageFling", {Title = "Better Rage Fling", Default = false, Callback = function(v) rageFling = v end})

Tabs.Sheriff:AddToggle("AutoShoot", {Title = "Auto Shoot + On-Screen Button", Default = false, Callback = function(v) 
    autoShoot = v 
    shootButton.Visible = v 
end})

Tabs.ESP:AddToggle("ESP", {Title = "Full ESP (Roles)", Default = true, Callback = function() end})

Tabs.Player:AddSlider("WalkSpeed", {Title = "WalkSpeed", Min = 16, Max = 250, Default = 70, Callback = function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})

Tabs.Misc:AddToggle("SilentAim", {Title = "Silent Aim", Default = false, Callback = function(v) silentAim = v end})
Tabs.Misc:AddToggle("AutoFarm", {Title = "Auto Farm Coins", Default = false, Callback = function(v) autoFarm = v end})
Tabs.Misc:AddToggle("AntiStaff", {Title = "Anti-Staff (Kick on Join)", Default = true, Callback = function(v) antiStaff = v end})

Tabs.Settings:AddButton({Title = "Destroy All", Callback = function()
    shootButton:Destroy()
    Window:Destroy()
end})

Fluent:Notify({Title = "Loaded", Content = "Bin's MM2 Rage Hub готов. Не сливайся.", Duration = 6})
