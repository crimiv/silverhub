local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local CombatTab = LinuxHub.Window:Tab({ Title = "Combat" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AeroServices = ReplicatedStorage:WaitForChild("Aero"):WaitForChild("AeroRemoteServices"):WaitForChild("GameService")
local AttackStart = AeroServices:WaitForChild("WeaponAttackStart")
local AnimComplete = AeroServices:WaitForChild("WeaponAnimComplete")

local autoSwingEnabled = LinuxHub.Toggles.AutoSwing or false
local lastSwingTime = 0
local SWING_COOLDOWN = 0.1

local function SwingWeapon()
    AttackStart:FireServer()
    AnimComplete:FireServer()
    if typeof(getNil) == "function" then
        pcall(function()
            getNil("Event", "BindableEvent"):Fire()
        end)
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if not autoSwingEnabled then return end
    local now = tick()
    if now - lastSwingTime >= SWING_COOLDOWN then
        lastSwingTime = now
        pcall(SwingWeapon)
    end
end)

CombatTab:Toggle({
    Title = "Auto Swing",
    Value = autoSwingEnabled,
    Callback = function(state)
        autoSwingEnabled = state
        LinuxHub.Toggles.AutoSwing = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Auto Swing",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
        })
        if state then
            lastSwingTime = tick()
        end
    end
})

LinuxHub.DisableAll = LinuxHub.DisableAll or function() end
local oldDisable = LinuxHub.DisableAll
LinuxHub.DisableAll = function()
    autoSwingEnabled = false
    LinuxHub.Toggles.AutoSwing = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    oldDisable()
end
