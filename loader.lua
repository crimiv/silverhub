-- BanditHub Script Loader
-- Usage (executed via loadstring):
--   _G.BANDITHUB_UI = "windui" | "rayfield" (default windui)
--   loadstring(game:HttpGet("<this loader url>"))()

local BASE_URL = "https://raw.githubusercontent.com/crimiv/bandithub/main/"

local function Fetch(url)
    return game:HttpGet(url)
end

local function LoadScript(name)
    local script = Fetch(BASE_URL .. name)
    local fn, err = loadstring(script)
    if not fn then
        error(err)
    end
    return fn()
end

-- Load the base scripts/tables that game entrypoints expect.
local UILoader = LoadScript("shared/uiloader.lua")

local adapter = UILoader.Load()

-- Create a compatibility surface for existing game scripts.
-- Existing scripts expect:
--  - BanditHub.WindUI
--  - BanditHub.Window
--  - WindUI:CreateWindow(...) (already used inside game entrypoints)
-- To avoid touching all game entrypoints, we set BanditHub.WindUI when windui is used.
-- For Rayfield, game entrypoints will need minimal refactor OR we provide BanditHub.WindUI compatibility.

BanditHub = BanditHub or {}

if adapter.Library == "windui" then
    BanditHub.WindUI = adapter.WindUI
else
    -- Minimal compatibility: some scripts reference BanditHub.WindUI directly.
    -- We expose an object with CreateWindow/Notify matching WindUI style.
    BanditHub.WindUI = {
        CreateWindow = function(config)
            return adapter.CreateWindow(config)
        end,
        Notify = function(payload)
            return adapter.Notify(payload)
        end,
    }
end

-- Expose adapter (optional for game scripts).
BanditHub.UI = adapter

-- Load game entrypoint by place id.
local games = assert(loadstring(Fetch(BASE_URL .. "games.lua")))()
local placeId = game.PlaceId or game.GameId
local gameEntry = games[placeId]

if not gameEntry then
    LoadScript("games/universal/init.lua")
    return
end

LoadScript(gameEntry)

