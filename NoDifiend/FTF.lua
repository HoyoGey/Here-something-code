-- Shity Function For Script-Ware
local FoundSW = getexecutorname() and identifyexecutor()

local ExploitCheck = syn and "Synapse" or KRNL_LOADED and "Krnl" or FoundSW and "ScriptWare" or "All"

loadstring(game:HttpGet("https://scripts.hoyo8020.repl.co/TotalUsed/CountExploit.php?exploit=" .. ExploitCheck))

local mapValue = game.ReplicatedStorage.CurrentMap
local TempPlayerStatsModule = require(game.Players.LocalPlayer:WaitForChild("TempPlayerStatsModule"));

local SolarisLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/HoyoGey/My-Lua-Project/main/UiLibs/SolarisBest.lua"))()
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/HoyoGey/My-Lua-Project/main/Utils/Esp.lua"))()

local playersesp = esp:addESP("player", {
    tag = true,
    distance = true,
    outline = true,
    nolplr = true,
    outlineSameAsFill = true,
    customColor = function(v)
        if v ~= game.Players.LocalPlayer then
            if v:FindFirstChild("Hammer") then
                return Color3.fromRGB(225, 50, 44)
            end
            if not v:FindFirstChild("Hammer") then
                return Color3.fromRGB(44, 120, 224)
            end
        end
    end
})

playersesp:Value(false)

local Window = SolarisLib:New({
    Title = "Flee The Facility",
    FolderToSave = "FuckYou"
})

local EspTab = Window:Tab("Esp")

local PlayerNudes = EspTab:Section("Esp Player's")

PlayerNudes:Toggle({
    Name = "Enable Esp",
    Default = false,
    Flag = "I Can't Don Like Of This Shit",
    Callback = function(value)
        print("Esp Enabled", value)
        getgenv().WhyDoYouSeeItFukingFreak = value
        playersesp:Value(getgenv().WhyDoYouSeeItFukingFreak)
    end
})

local NotPlayerNudes = EspTab:Section("Esp Objects")

local PCChams = {}
NotPlayerNudes:Toggle({
    Name = "Computer Esp",
    Default = false,
    Flag = "I Can't Don Like Of This Shit",
    Callback = function(value)
        print("Esp Enabled", value)
        getgenv().CantWhatTheFuck = value
        for i, v in pairs(PCChams) do
            v.Enabled = getgenv().CantWhatTheFuck
        end
    end
})

local function ApplyPCChams(inst)
    wait()
    local Cham = Instance.new("Highlight")

    Cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Cham.FillTransparency = 0.6
    Cham.OutlineTransparency = 0.3
    Cham.FillColor = inst.Screen.Color
    Cham.OutlineColor = inst.Screen.Color
    inst.Screen.Changed:Connect(function()
        Cham.FillColor = inst.Screen.Color
        Cham.OutlineColor = inst.Screen.Color
    end)
    Cham.Parent = inst
    Cham.Enabled = _G.PCChams
    Cham.Adornee = inst
    Cham.RobloxLocked = true
    return Cham
end

local EtcTab = Window:Tab("Etc Shit")
local FuckNudes = EtcTab:Section("What Of This Name Section")

FuckNudes:Toggle({
    Name = "Auto Hack",
    Default = false,
    Flag = "I Love Fuck Niggers",
    Callback = function(t)
        getgenv().CumInYourAss = t
        while getgenv().CumInYourAss == true do
            game.ReplicatedStorage.RemoteEvent:FireServer("SetPlayerMinigameResult", true)
            wait()
        end
    end
})

FuckNudes:Toggle({
    Name = "Enable Crawling",
    Default = false,
    Flag = "I Love Fuck Niggers",
    Callback = function(value)
        getgenv().EhFuckYouFukingMonkey = t
        while getgenv().EhFuckYouFukingMonkey == true do
            wait()
            if game.Players.LocalPlayer.TempPlayerStatsModule.IsBeast.Value == true then
                game:GetService("Players").LocalPlayer.TempPlayerStatsModule.DisableCrawl.Value = false
            end
        end
    end
})

FuckNudes:Button({
    Name = "No Jump Slowdown",
    Callback = function()
        local oldnc
        oldnc = hookmetamethod(game, "__namecall", newcclosure(function(name, ...)
            local Args = {...}
            if not checkcaller() and tostring(name) == "PowersEvent" and Args[1] == "Jumped" then
                return wait(9e9)
            end
            return oldnc(name, unpack(Args))
        end))
    end
})

FuckNudes:Button({
    Name = "Unlock Camers",
    Callback = function()
        workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
        workspace.CurrentCamera.CameraType = "Custom"
        game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
        game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
        game.Players.LocalPlayer.CameraMode = "Classic"
        game.Players.LocalPlayer.Character.Head.Anchored = false
    end
})

-- local ComputerAdded = 0
function updateMAP()
    local map = tostring(mapValue.Value)
    map = workspace:WaitForChild(map, 30)
    if not map then
        return warn('no map found in workspace')
    end

    for _, v in ipairs(game.Players:GetPlayers()) do
        if v:FindFirstChild("Hammer") and v ~= game.Players.LocalPlayer then
            SolarisLib:Notification("New Best", "Name Him: " .. v.Name, 5)
        end
    end

    -- ComputerAdded = 0

    map.DescendantAdded:Connect(function(v)
        if v.Name == "ComputerTable" then
            table.insert(PCChams, ApplyPCChams(v))
        end
    end)

    for i, v in pairs(map:GetDescendants()) do
        if v.Name == "ComputerTable" then
            table.insert(PCChams, ApplyPCChams(v))
        end
    end
end

updateMAP()
mapValue.Changed:Connect(updateMAP)

local DS = Window:Tab("Pls join")
local DSS = DS:Section("Discord")

DSS:Button({
    Name = "Discord Server",
    Callback = function()
        setclipboard("https://discord.gg/dgU6ffNnqT")
    end
})
