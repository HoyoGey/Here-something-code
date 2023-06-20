-- Shity Function For Script-Ware
local FoundSW = getexecutorname() and identifyexecutor()

local ExploitCheck = syn and "Synapse X" or KRNL_LOADED and "Krnl" or FoundSW and "ScriptWare" or "Not Foud Exploit, Script not support:("

local scripts = {
	[893973440] = "https://raw.githubusercontent.com/HoyoGey/Here-something-code/main/supix/futf.lua",
	[9872472334] = "https://raw.githubusercontent.com/HoyoGey/Here-something-code/main/supix/Evade.lua",
	[192800] = "https://raw.githubusercontent.com/HoyoGey/Here-something-code/main/supix/workatapizzasourceopen.lua",
	[621129760] = "https://raw.githubusercontent.com/HoyoGey/Here-something-code/main/supix/KAT"
}

local function loadScript(gameId)
    if scripts[gameId] then
		loadstring(game:HttpGet(scripts[gameId]))()
    else
        warn("No script found for this Place ID.")
    end
end

loadScript(game.PlaceId)

-- No More Key-System AYAYA

-- local HttpService = game:GetService("HttpService")
-- local Players = game:GetService("Players")

-- local BLACKLIST = game:HttpGet("https://WhisperedBackAstronomy.hoyo8020.repl.co/bl.json")
-- local API_KEY = "https://WhisperedBackAstronomy.hoyo8020.repl.co/check.php?key="

-- local function checkKey(key)
--     local url = API_KEY .. key
--     local response = HttpService:GetAsync(url)
--     return response == "VALID_KEY"
-- end

-- local function checkBlacklist(player)
--     local playerName = player.Name
--     for i, name in ipairs(BLACKLIST) do
--         if playerName == name then
--             player:Kick("You are not allowed to play with this script.")
--         end
--     end
-- end

-- local valid = isfile("keyyyy.txt")
-- if valid then
--     if checkKey(key) then
--         rconsoleprint("Key is valid!\n")
--         checkBlacklist(game.Players.LocalPlayer)
--         if ExploitCheck ~= "Not Foud Exploit, Script not support:(" then
--             loadScript(game.PlaceId)
--         else
--             rconsoleprint("Oh No Ur Exploit Not Supported\n")
--             warn(ExploitCheck)
--             wait(5)
--             game.Players.LocalPlayer:Kick("Sorry:()")
--         end
--     else
--         delfile("keyyyy.txt")
--         rconsoleprint("Key is invalid!\nRe Execute Script!")
--     end
-- else
--     rconsoleclear()
--     rconsoleprint("Join in discord server!\nhttps://discord.gg/ASeMjwW2qP\nwait 5 sec for enter key\n")
--     wait()
--     rconsoleprint("Enter key: ")
--     local key = rconsoleinput()
--     if checkKey(key) then
--         rconsoleprint("Key is valid!\n")
--         writefile("keyyyy.txt", key)
--         checkBlacklist(game.Players.LocalPlayer)
--         if ExploitCheck ~= "Not Foud Exploit, Script not support:(" then
--             loadScript(game.PlaceId)
--         else
--             rconsoleprint("Oh No Ur Exploit Not Supported\n")
--             warn(ExploitCheck)
--             wait(5)
--             game.Players.LocalPlayer:Kick("Sorry:()")
--         end
--     else
--         delfile("keyyyy.txt")
--         rconsoleprint("Key is invalid!\nRe Execute Script!")
--     end
-- end
