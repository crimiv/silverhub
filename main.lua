local BASE_URL = "https://raw.githubusercontent.com/crimiv/linuxhub/main/"

local function Fetch(url)
    local request = syn and syn.request or request or http and http.request
    if not request then
        error("No HTTP request function found. Make sure you are using a supported executor.")
    end

    local response = request({
        Url = url,
        Method = "GET"
    })

    if response.StatusCode ~= 200 then
        error("Failed to fetch script. Status code: " .. response.StatusCode)
    end

    return response.Body
end

local gamesList = Fetch(BASE_URL .. "games.lua")
local games = assert(loadstring(gamesList))()

local placeId = game.PlaceId or game.GameId
local gameEntry = games[placeId]

if not gameEntry then
    _G.LINUXHUB_GAME_NAME = "Universal"
    LoadScript(BASE_URL .. "games/universal/init.lua")
    return
end

_G.LINUXHUB_GAME_NAME = gameEntry.name

LoadScript(BASE_URL .. gameEntry.path)
