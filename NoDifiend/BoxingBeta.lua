-- Shity Function For Script-Ware
local FoundSW = getexecutorname() and identifyexecutor()

local ExploitCheck = syn and "Synapse" or KRNL_LOADED and "Krnl" or FoundSW and "ScriptWare" or "All"

loadstring(game:HttpGet("https://scripts.hoyo8020.repl.co/TotalUsed/CountExploit.php?exploit=" .. ExploitCheck))

local lp = game.Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local SolarisLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/HoyoGey/My-Lua-Project/main/UiLibs/SolarisBest.lua"))()

local Window = SolarisLib:New({
    Title = "Boxing Beta",
    FolderToSave = "FuckYou",
})

local CombatTab = Window:Tab("Combat")
local AuraSection = CombatTab:Section("Aura")

AuraSection:Toggle({
    Name = "Enable Aura",
    Default = false,
    Flag = "AuraEnabled",
    Callback = function(value)
        getgenv().AuraEnabled = value
        print("Toggle value changed to", value)
    end,
})

AuraSection:Slider({
    Name = "Range Studs",
    Minimum = 1,
    Maximum = 10,
    Default = 4,
    Increment = 1,
    Flag = "Range",
    Callback = function(value)
        getgenv().Range = value
        print("Slider value changed to", value)
    end,
})

local BlockSection = CombatTab:Section("Auto Block")

BlockSection:Toggle({
    Name = "While Block",
    Default = false,
    Flag = "BlockEnabled",
    Callback = function(value)
        getgenv().BlockEnabled = value
        print("Toggle value changed to", value)
    end,
})

local function GetClosestPlayer()
    local target = nil
    local distance = getgenv().Range

    for i, v in pairs(game.Players:GetPlayers()) do
        if v and v ~= lp and v.Character and v.Character:FindFirstChildOfClass("Humanoid") and v.Character:FindFirstChildOfClass("Humanoid").RootPart then
            local plrdist = lp:DistanceFromCharacter(v.Character:FindFirstChildOfClass("Humanoid").RootPart.Position)
            if plrdist < distance then
                target = v
                distance = plrdist
            end
        end
    end
    return target
end

task.spawn(function()
    while true do
        if GetClosestPlayer() and getgenv().AuraEnabled then
            game:GetService("ReplicatedStorage").RemoteEvents.PlayerDamageRemote:FireServer(GetClosestPlayer(), nil, "left", false)
        end
        if getgenv().BlockEnabled then
            game:GetService("ReplicatedStorage").RemoteEvents.PlayerStaminaRemote:FireServer("blockTrue", 5206.0082215)
        end
        wait()
    end
end)

task.spawn(function()
    while true do
        if getgenv().AuraEnabled and GetClosestPlayer() then
            SolarisLib:Notification("Combat Aura", "Targeting Player: " .. (GetClosestPlayer() and GetClosestPlayer().Name or "None"), 5)
        end
        wait()
    end
end)
