local WindUI = AppleHub.WindUI
local config = AppleHub.Config

local SettingsTab = AppleHub.Window:Tab({ Title = "Settings" })

local themes = config.themes or {"Silver", "Dark", "Light", "Neon"}
local currentTheme = "Silver"

SettingsTab:Dropdown({
    Title = "Theme",
    Values = themes,
    Default = currentTheme,
    Callback = function(value)
        currentTheme = value
        WindUI:SetTheme(value)
        WindUI:Notify({ Title = "Theme", Content = "Switched to " .. value, Duration = 2 })
    end
})

SettingsTab:Button({
    Title = "Check for Updates",
    Callback = function()
        local BASE_URL = "https://raw.githubusercontent.com/crimiv/applehub/main/"
        local success, remoteConfig = pcall(function()
            return game:HttpGet(BASE_URL .. "shared/config.lua")
        end)
        if success then
            local fn, err = loadstring(remoteConfig)
            if fn then
                local remote = fn()
                if remote and remote.version then
                    if remote.version ~= config.version then
                        WindUI:Notify({
                            Title = "Update Available",
                            Content = "New version " .. remote.version .. " is available. Please reload the hub.",
                            Duration = 5,
                        })
                    else
                        WindUI:Notify({
                            Title = "No Updates",
                            Content = "You are on the latest version.",
                            Duration = 3,
                        })
                    end
                end
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Failed to check for updates.",
                Duration = 3,
            })
        end
    end
})