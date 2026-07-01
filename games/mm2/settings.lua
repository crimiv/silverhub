local WindUI = BanditHub.WindUI
local config = BanditHub.Config

local SettingsTab = BanditHub.Window:Tab({ Title = "Settings" })

local themes = config.themes or {"Silver", "Dark", "Light", "Neon"}
local currentTheme = BanditHub.CurrentTheme or "Silver"

SettingsTab:Dropdown({
    Title = "Theme",
    Values = themes,
    Default = currentTheme,
    Callback = function(value)
        currentTheme = value
        BanditHub.CurrentTheme = value
        WindUI:SetTheme(value)
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end
        WindUI:Notify({ Title = "Theme", Content = "Switched to " .. value, Duration = 2 })
    end
})