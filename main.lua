local function Fetch(url)
    return game:HttpGet(url)
end

local BASE_URL = "https://raw.githubusercontent.com/crimiv/applehub/main/"

local function LoadScript(name)
    local script = Fetch(BASE_URL .. name)
    assert(loadstring(script))()
end

local gamesList = Fetch(BASE_URL .. "games.lua")
local games = assert(loadstring(gamesList))()

local placeId = game.PlaceId or game.GameId
local gameEntry = games[placeId]
if not gameEntry then
    return
end

LoadScript(gameEntry)
