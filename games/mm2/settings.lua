local WindUI = AppleHub.WindUI
local utils = AppleHub.Utils
local config = AppleHub.Config

local SettingsTab = AppleHub.Window:Tab({ Title = "Settings" })

local themes = config.themes or {"Silver", "Dark", "Light", "Neon", "Ocean", "Forest", "Sunset", "Midnight", "Candy", "Royal", "Matrix", "Coffee", "Lavender", "Mint", "Coral", "Cyber", "Pastel", "Fire", "Ice", "Galaxy", "Rose", "Sky", "Earth", "Grape"}
local currentTheme = AppleHub.CurrentTheme or "Silver"

SettingsTab:Dropdown({
    Title = "Theme",
    Values = themes,
    Default = currentTheme,
    Callback = function(value)
        currentTheme = value
        AppleHub.CurrentTheme = value
        WindUI:SetTheme(value)
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        utils.Notify({ Title = "Theme", Content = "Switched to " .. value, Duration = 2 })
    end
})