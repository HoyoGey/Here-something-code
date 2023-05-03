-- Shity Function For Script-Ware
local FoundSW = getexecutorname() and identifyexecutor()

local ExploitCheck = syn and "Synapse" or KRNL_LOADED and "Krnl" or FoundSW and "ScriptWare" or "All"

loadstring(game:HttpGet("https://scripts.hoyo8020.repl.co/TotalUsed/CountExploit.php?exploit=" .. ExploitCheck))

local SolarisLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/HoyoGey/My-Lua-Project/main/UiLibs/SolarisBest.lua"))()
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/HoyoGey/My-Lua-Project/main/Utils/Esp.lua"))()

local function teleportCharacter(character, position)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CFrame = CFrame.new(position)
        end
    end
end


function fireproximite(whatneedyonk)
    local workspace = game:GetService("Workspace")
    local collectablesFolder = whatneedyonk --workspace.Items.Collectable

    for _, collectable in pairs(collectablesFolder:GetChildren()) do
        local core = collectable:FindFirstChild("Core")
        if core then
            local proximityPrompt = core:FindFirstChildOfClass("ProximityPrompt")
            if proximityPrompt then
                teleportCharacter(game.Players.LocalPlayer.Character, core.Position)
                wait(1)
                print(string.format("Founded Core With ProximityPrompt In Model %s", collectable.Name))
                fireproximityprompt(proximityPrompt)
                wait(0.5)
            end
        end
    end

end

local Stick = esp:addESP("game.Workspace.Monster.StickMan", {
    tag = true,
    distance = true,
    outline = true,
    nolplr = true,
    outlineSameAsFill = true,
    Color = Color3.new(1,1,1)
})

local Items = esp:addESP("game.Workspace.Items", {
    tag = true,
    distance = true,
    outline = true,
    nolplr = true,
    outlineSameAsFill = true,
    Color = Color3.new(1,1,1)
})


local Window = SolarisLib:New({
    Title = "Color Or Die",
    FolderToSave = "FuckYou"
})

local EspTab = Window:Tab("All")
local EspNudes = EspTab:Section("Esp")

EspNudes:Toggle({
    Name = "Monster Esp",
    Default = false,
    Flag = "I Can't Don Like Of This Shit",
    Callback = function(value)
        Stick:Value(value)
    end
})

EspNudes:Toggle({
    Name = "Item's Esp",
    Default = false,
    Flag = "I Can't Don Like Of This Shit",
    Callback = function(value)
        Items:Value(value)
    end
})

local PlayerNudes = EspTab:Section("Get Colors")

PlayerNudes:Button({
    Name = "Get All Collectable Colors",
    Callback = function()
        fireproximite(workspace.Items.Collectable)
    end
})

PlayerNudes:Button({
    Name = "Get All Paint Bucket",
    Callback = function()
        fireproximite(game:GetService("Workspace").Items.PaintBucket)
    end
})

PlayerNudes:Button({
    Name = "Get All Tool's",
    Callback = function()
        fireproximite(game:GetService("Workspace").Items.Tool)
    end
})

local DS = Window:Tab("Pls join")
local DSS = DS:Section("Discord")

DSS:Button({
    Name = "Discord Server",
    Callback = function()
        setclipboard("https://discord.gg/dgU6ffNnqT")
    end
})
