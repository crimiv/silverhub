local BASE_URL = "https://raw.githubusercontent.com/crimiv/bandithub/test/"

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

local UILoader = {}

local function GetUIName()
    local ui = _G.BANDITHUB_UI
    if typeof(ui) == "string" and ui ~= "" then
        return ui:lower()
    end
    return "windui"
end

local function CreateAdapterWindUI()
    local WindUI = LoadScript("shared/windui.lua")

    return {
        Library = "windui",
        WindUI = WindUI,
        CreateWindow = function(windowConfig)
            return WindUI:CreateWindow(windowConfig)
        end,
        Notify = function(payload)
            if WindUI and WindUI.Notify then
                return WindUI:Notify(payload)
            end
            return nil
        end,
        WindowApi = "WindUI",
    }
end

-- Rayfield adapter: provides a minimal compatibility layer for the existing hub.
-- This assumes Rayfield's common API: Rayfield:Notify({ ... }) and Rayfield:CreateWindow({ ... }).
-- If your Rayfield API differs, adjust this adapter only.
local function CreateAdapterRayfield()
    local Rayfield = LoadScript("shared/ui/rayfield.lua")
    return {
        Library = "rayfield",
        Rayfield = Rayfield,
        CreateWindow = function(windowConfig)
            return Rayfield:CreateWindow(windowConfig)
        end,
        Notify = function(payload)
            if Rayfield and Rayfield.Notify then
                return Rayfield:Notify(payload)
            end
            return nil
        end,
        WindowApi = "Rayfield",
    }
end

function UILoader.Load()
    local uiName = GetUIName()

    if uiName == "rayfield" then
        return CreateAdapterRayfield()
    end

    -- default
    return CreateAdapterWindUI()
end

return UILoader

