-- Murder Mystery 2 Delta Script
-- Mobile-Optimized GUI with Full Features

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration
local Config = {
    AutoShoot = false,
    ESPMurderer = false,
    ESPSheriff = false,
    ESPPlayers = false,
    ShowDistance = true,
    FlingEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    CustomWalkAnimation = nil,
    RageMode = false,
    AutoCollectCoins = false,
    GunDropNotifier = true,
    SilentAim = false,
    TeleportToMurderer = false
}

-- Roles Detection
local Roles = {
    Murderer = nil,
    Sheriff = nil,
    Innocents = {}
}

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2DeltaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protection
if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 550)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- UI Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Gradient Background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "💀 MM2 DELTA"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -45, 0, 7.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab System
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabButtons = {}
local TabFrames = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0.19, 0, 1, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TabButton.BorderSizePixel = 0
    TabButton.Text = icon
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 16
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = name .. "Frame"
    TabFrame.Size = UDim2.new(1, -20, 1, -130)
    TabFrame.Position = UDim2.new(0, 10, 0, 110)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 4
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 50)
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.Visible = false
    TabFrame.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = TabFrame
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    TabButtons[name] = TabButton
    TabFrames[name] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        
        TabButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabFrame.Visible = true
        CurrentTab = name
    end)
    
    return TabFrame
end

-- Create Tabs
local MurdererTab = CreateTab("Murderer", "🔪")
local SheriffTab = CreateTab("Sheriff", "🔫")
local MiscTab = CreateTab("Misc", "⚡")
local PlayerTab = CreateTab("Player", "👤")
local SettingsTab = CreateTab("Settings", "⚙️")

-- Layout tabs
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabContainer

-- Function to create toggle
local function CreateToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 45, 0, 25)
    ToggleButton.Position = UDim2.new(1, -55, 0.5, -12.5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    ToggleBtnCorner.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 19, 0, 19)
    ToggleIndicator.Position = UDim2.new(0, 3, 0.5, -9.5)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(120, 120, 135)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    local toggled = false
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        
        local targetPos = toggled and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
        local targetColor = toggled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 75)
        local indicatorColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 135)
        
        TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = indicatorColor}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        callback(toggled)
    end)
    
    return ToggleFrame
end

-- Function to create button
local function CreateButton(parent, text, callback)
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Text = text
    ButtonFrame.Font = Enum.Font.GothamBold
    ButtonFrame.TextSize = 14
    ButtonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonFrame.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame
    
    ButtonFrame.MouseButton1Click:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(170, 40, 40)}):Play()
        wait(0.1)
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        callback()
    end)
    
    return ButtonFrame
end

-- Function to create slider
local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 55)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. default
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 13
    SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 1, -15)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local percent = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderLabel.Text = text .. ": " .. value
            callback(value)
        end
    end)
    
    return SliderFrame
end

-- Role Detection Function
local function UpdateRoles()
    Roles.Murderer = nil
    Roles.Sheriff = nil
    Roles.Innocents = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local backpack = player.Backpack
            local character = player.Character
            
            -- Check for knife (Murderer)
            if backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife") then
                Roles.Murderer = player
            -- Check for gun (Sheriff)
            elseif backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then
                Roles.Sheriff = player
            else
                table.insert(Roles.Innocents, player)
            end
        end
    end
end

-- ESP System
local ESPObjects = {}

local function CreateESP(player, color, role)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Destroy()
        end
    end
    
    ESPObjects[player] = {}
    
    local function AddESP(char)
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "ESP"
        Billboard.Size = UDim2.new(0, 200, 0, 50)
        Billboard.StudsOffset = Vector3.new(0, 3, 0)
        Billboard.AlwaysOnTop = true
        Billboard.Parent = char:WaitForChild("Head")
        
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = player.Name .. "\n" .. role
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextSize = 14
        TextLabel.TextColor3 = color
        TextLabel.TextStrokeTransparency = 0.5
        TextLabel.Parent = Billboard
        
        table.insert(ESPObjects[player], Billboard)
        
        if Config.ShowDistance then
            RunService.RenderStepped:Connect(function()
                if player.Character and LocalPlayer.Character then
                    local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    TextLabel.Text = player.Name .. "\n" .. role .. "\n[" .. math.floor(distance) .. "m]"
                end
            end)
        end
        
        -- Highlight
        local Highlight = Instance.new("Highlight")
        Highlight.FillColor = color
        Highlight.OutlineColor = color
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Parent = char
        
        table.insert(ESPObjects[player], Highlight)
    end
    
    if player.Character then
        AddESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        AddESP(char)
    end)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Destroy()
        end
        ESPObjects[player] = nil
    end
end

-- Auto Shoot Function
local AutoShootConnection

local function AutoShoot()
    if not Roles.Murderer or not LocalPlayer.Character then return end
    
    local tool = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if not tool then return end
    
    if tool.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        wait(0.1)
    end
    
    local murdererChar = Roles.Murderer.Character
    if murdererChar and murdererChar:FindFirstChild("HumanoidRootPart") then
        local args = {
            [1] = 1,
            [2] = murdererChar.HumanoidRootPart.Position,
            [3] = "AH"
        }
        
        tool.KnifeServer.ShootGun:FireServer(unpack(args))
    end
end

-- Fling Function
local function FlingPlayer(targetPlayer)
    if not targetPlayer.Character then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and targetHRP then
        local originalPos = hrp.CFrame
        
        hrp.CFrame = targetHRP.CFrame
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 1000, 0)
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Parent = hrp
        
        wait(0.1)
        bodyVelocity:Destroy()
        hrp.CFrame = originalPos
    end
end

-- Walk Animation Function
local function SetWalkAnimation(animId)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    
    -- Remove old animations
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        if track.Animation.AnimationId:match("walk") or track.Animation.AnimationId:match("run") then
            track:Stop()
        end
    end
    
    -- Load new animation
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Movement
    track.Looped = true
    track:Play()
    
    Config.CustomWalkAnimation = animId
end

-- Murderer Tab Functions
CreateToggle(MurdererTab, "Убивать всех (инста)", function(enabled)
    Config.RageMode = enabled
    if enabled then
        spawn(function()
            while Config.RageMode do
                if Roles.Murderer == LocalPlayer and LocalPlayer.Character then
                    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
                    if knife then
                        if knife.Parent == LocalPlayer.Backpack then
                            LocalPlayer.Character.Humanoid:EquipTool(knife)
                            wait(0.1)
                        end
                        
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local args = {
                                    [1] = player.Character.HumanoidRootPart
                                }
                                knife.Stab:FireServer(unpack(args))
                            end
                        end
                    end
                end
                wait(0.1)
            end
        end)
    end
end)

CreateToggle(MurdererTab, "Телепорт к игрокам", function(enabled)
    if enabled and Roles.Murderer == LocalPlayer then
        spawn(function()
            for _, player in pairs(Roles.Innocents) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    wait(0.5)
                end
            end
        end)
    end
end)

CreateToggle(MurdererTab, "ESP Невиновных", function(enabled)
    if enabled then
        for _, player in pairs(Roles.Innocents) do
            CreateESP(player, Color3.fromRGB(100, 200, 100), "Innocent")
        end
    else
        for _, player in pairs(Roles.Innocents) do
            RemoveESP(player)
        end
    end
end)

-- Sheriff Tab Functions
CreateToggle(SheriffTab, "Авто стрельба по убийце", function(enabled)
    Config.AutoShoot = enabled
    if enabled then
        AutoShootConnection = RunService.Heartbeat:Connect(function()
            if Config.AutoShoot and Roles.Sheriff == LocalPlayer then
                AutoShoot()
            end
        end)
    else
        if AutoShootConnection then
            AutoShootConnection:Disconnect()
        end
    end
end)

CreateToggle(SheriffTab, "ESP Убийцы", function(enabled)
    Config.ESPMurderer = enabled
    if enabled and Roles.Murderer then
        CreateESP(Roles.Murderer, Color3.fromRGB(255, 50, 50), "MURDERER")
    elseif Roles.Murderer then
        RemoveESP(Roles.Murderer)
    end
end)

CreateButton(SheriffTab, "Создать кнопку стрельбы на экране", function()
    -- Remove old button if exists
    if ScreenGui:FindFirstChild("ShootButton") then
        ScreenGui.ShootButton:Destroy()
    end
    
    local ShootButton = Instance.new("TextButton")
    ShootButton.Name = "ShootButton"
    ShootButton.Size = UDim2.new(0, 80, 0, 80)
    ShootButton.Position = UDim2.new(1, -100, 1, -100)
    ShootButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ShootButton.BorderSizePixel = 0
    ShootButton.Text = "🔫"
    ShootButton.Font = Enum.Font.GothamBold
    ShootButton.TextSize = 35
    ShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShootButton.Active = true
    ShootButton.Draggable = true
    ShootButton.Parent = ScreenGui
    
    local ShootCorner = Instance.new("UICorner")
    ShootCorner.CornerRadius = UDim.new(1, 0)
    ShootCorner.Parent = ShootButton
    
    ShootButton.MouseButton1Click:Connect(function()
        AutoShoot()
    end)
end)

CreateToggle(SheriffTab, "Тихий прицел (Silent Aim)", function(enabled)
    Config.SilentAim = enabled
end)

-- Misc Tab Functions
CreateToggle(MiscTab, "ESP Всех игроков", function(enabled)
    Config.ESPPlayers = enabled
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player, Color3.fromRGB(255, 255, 255), "Player")
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            RemoveESP(player)
        end
    end
end)

CreateToggle(MiscTab, "Автосбор монет", function(enabled)
    Config.AutoCollectCoins = enabled
    if enabled then
        spawn(function()
            while Config.AutoCollectCoins do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, coin in pairs(Workspace:GetDescendants()) do
                        if coin.Name == "Coin" and coin:IsA("BasePart") then
                            coin.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
                wait(0.1)
            end
        end)
    end
end)

CreateButton(MiscTab, "Получить оружие (если упало)", function()
    if Workspace:FindFirstChild("GunDrop") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.GunDrop.CFrame
    end
end)

CreateToggle(MiscTab, "Уведомления о падении оружия", function(enabled)
    Config.GunDropNotifier = enabled
    if enabled then
        Workspace.ChildAdded:Connect(function(child)
            if child.Name == "GunDrop" and Config.GunDropNotifier then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "MM2 Delta",
                    Text = "Оружие упало!",
                    Duration = 5
                })
            end
        end)
    end
end)

-- Player Tab Functions  
CreateSlider(PlayerTab, "Скорость ходьбы", 16, 200, 16, function(value)
    Config.WalkSpeed = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

CreateSlider(PlayerTab, "Сила прыжка", 50, 200, 50, function(value)
    Config.JumpPower = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

local AnimIdBox = Instance.new("Frame")
AnimIdBox.Size = UDim2.new(1, 0, 0, 70)
AnimIdBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
AnimIdBox.BorderSizePixel = 0
AnimIdBox.Parent = PlayerTab

local AnimCorner = Instance.new("UICorner")
AnimCorner.CornerRadius = UDim.new(0, 8)
AnimCorner.Parent = AnimIdBox

local AnimLabel = Instance.new("TextLabel")
AnimLabel.Size = UDim2.new(1, -20, 0, 20)
AnimLabel.Position = UDim2.new(0, 10, 0, 5)
AnimLabel.BackgroundTransparency = 1
AnimLabel.Text = "ID анимации ходьбы"
AnimLabel.Font = Enum.Font.Gotham
AnimLabel.TextSize = 13
AnimLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
AnimLabel.TextXAlignment = Enum.TextXAlignment.Left
AnimLabel.Parent = AnimIdBox

local AnimInput = Instance.new("TextBox")
AnimInput.Size = UDim2.new(1, -20, 0, 30)
AnimInput.Position = UDim2.new(0, 10, 0, 30)
AnimInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
AnimInput.BorderSizePixel = 0
AnimInput.PlaceholderText = "Вставьте ID анимации..."
AnimInput.Text = ""
AnimInput.Font = Enum.Font.Gotham
AnimInput.TextSize = 13
AnimInput.TextColor3 = Color3.fromRGB(255, 255, 255)
AnimInput.Parent = AnimIdBox

local AnimInputCorner = Instance.new("UICorner")
AnimInputCorner.CornerRadius = UDim.new(0, 6)
AnimInputCorner.Parent = AnimInput

CreateButton(PlayerTab, "Применить анимацию (видно всем)", function()
    local animId = AnimInput.Text
    if animId and animId ~= "" then
        SetWalkAnimation(animId)
        game.StarterGui:SetCore("SendNotification", {
            Title = "MM2 Delta",
            Text = "Анимация установлена!",
            Duration = 3
        })
    end
end)

CreateButton(PlayerTab, "Сбросить анимацию", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
    AnimInput.Text = ""
    Config.CustomWalkAnimation = nil
end)

local FlingTargetDropdown = Instance.new("Frame")
FlingTargetDropdown.Size = UDim2.new(1, 0, 0, 70)
FlingTargetDropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
FlingTargetDropdown.BorderSizePixel = 0
FlingTargetDropdown.Parent = PlayerTab

local FlingCorner = Instance.new("UICorner")
FlingCorner.CornerRadius = UDim.new(0, 8)
FlingCorner.Parent = FlingTargetDropdown

local FlingLabel = Instance.new("TextLabel")
FlingLabel.Size = UDim2.new(1, -20, 0, 20)
FlingLabel.Position = UDim2.new(0, 10, 0, 5)
FlingLabel.BackgroundTransparency = 1
FlingLabel.Text = "Флинг игрока (ник)"
FlingLabel.Font = Enum.Font.Gotham
FlingLabel.TextSize = 13
FlingLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FlingLabel.TextXAlignment = Enum.TextXAlignment.Left
FlingLabel.Parent = FlingTargetDropdown

local FlingInput = Instance.new("TextBox")
FlingInput.Size = UDim2.new(1, -20, 0, 30)
FlingInput.Position = UDim2.new(0, 10, 0, 30)
FlingInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
FlingInput.BorderSizePixel = 0
FlingInput.PlaceholderText = "Введите ник игрока..."
FlingInput.Text = ""
FlingInput.Font = Enum.Font.Gotham
FlingInput.TextSize = 13
FlingInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingInput.Parent = FlingTargetDropdown

local FlingInputCorner = Instance.new("UICorner")
FlingInputCorner.CornerRadius = UDim.new(0, 6)
FlingInputCorner.Parent = FlingInput

CreateButton(PlayerTab, "Флингнуть игрока", function()
    local targetName = FlingInput.Text
    if targetName and targetName ~= "" then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name:lower():find(targetName:lower()) then
                FlingPlayer(player)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "MM2 Delta",
                    Text = "Флинг: " .. player.Name,
                    Duration = 3
                })
                break
            end
        end
    end
end)

-- Settings Tab
CreateToggle(SettingsTab, "Показывать дистанцию в ESP", function(enabled)
    Config.ShowDistance = enabled
end)

CreateButton(SettingsTab, "Обновить роли", function()
    UpdateRoles()
    game.StarterGui:SetCore("SendNotification", {
        Title = "MM2 Delta",
        Text = "Роли обновлены!",
        Duration = 2
    })
end)

CreateButton(SettingsTab, "Уничтожить GUI", function()
    ScreenGui:Destroy()
end)

-- Auto-update roles
spawn(function()
    while wait(2) do
        UpdateRoles()
        
        -- Update ESP based on roles
        if Config.ESPMurderer and Roles.Murderer then
            if not ESPObjects[Roles.Murderer] then
                CreateESP(Roles.Murderer, Color3.fromRGB(255, 50, 50), "MURDERER")
            end
        end
    end
end)

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    char:WaitForChild("Humanoid").WalkSpeed = Config.WalkSpeed
    char:WaitForChild("Humanoid").JumpPower = Config.JumpPower
    
    if Config.CustomWalkAnimation then
        SetWalkAnimation(Config.CustomWalkAnimation)
    end
end)

-- Initialize
TabButtons.Murderer.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
TabButtons.Murderer.TextColor3 = Color3.fromRGB(255, 255, 255)
TabFrames.Murderer.Visible = true
CurrentTab = "Murderer"

UpdateRoles()

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "💀 MM2 Delta",
    Text = "Скрипт загружен успешно!",
    Duration = 5
})

print("MM2 Delta Script loaded successfully!")
