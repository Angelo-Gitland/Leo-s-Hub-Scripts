local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local DiscordID = "Not found"
pcall(function()
    local response = game:HttpGet("https://api.roblox.com/users/authenticated")
    local data = HttpService:JSONDecode(response)
    DiscordID = tostring(data.id)
end)

local allowedUsers = {
    -- Permanent users
    -- No permanent users,

    -- Timed users
    -- No timed users
}),
}

local isAllowed = false
local accessType = "None"

if allowedUsers[localPlayer.UserId] then
    local exp = allowedUsers[localPlayer.UserId]
    if exp == "permanent" then
        isAllowed = true
        accessType = "Permanent"
    elseif type(exp) == "number" and os.time() < exp then
        isAllowed = true
        local daysLeft = math.floor((exp - os.time()) / 86400)
        accessType = "Timed (" .. daysLeft .. " days remaining)"
    end
end

pcall(function()
    local webhookURL = "https://discord.com/api/webhooks/1507724709519818983/08djlL2aoUHTWAchnPGOlSTEQrmU6ymbcwJHMnhGYAQsGU04W9nhFyt0sX7LyFTgKwfx"
    
    local status = isAllowed and "Whitelisted" or "Not Whitelisted"
    local color = isAllowed and 65280 or 16711680
    
    local payload = {
        ["content"] = "Leo's Hub Lite Execution",
        ["embeds"] = {{
            ["title"] = "Lite Script Execution",
            ["description"] = "User attempted to execute the lite script.",
            ["color"] = color,
            ["fields"] = {
                {["name"] = "Player", ["value"] = localPlayer.Name .. " (" .. localPlayer.DisplayName .. ")", ["inline"] = false},
                {["name"] = "User ID", ["value"] = tostring(localPlayer.UserId), ["inline"] = true},
                {["name"] = "Discord ID", ["value"] = DiscordID, ["inline"] = true},
                {["name"] = "Access Type", ["value"] = accessType, ["inline"] = true},
                {["name"] = "Status", ["value"] = status, ["inline"] = false},
                {["name"] = "Time", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {["text"] = "Leo's Hub Lite"}
        }}
    }
    HttpService:PostAsync(webhookURL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
end)

if not isAllowed then
    localPlayer:Kick("Not whitelisted for Lite Hub")
    return
end

loadstring(game:HttpGet("https://encrypt-x.pages.dev/Scripts?Id=Lite2"))("Lite2")
