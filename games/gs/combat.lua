local WindUI = BanditHub.WindUI
local utils = BanditHub.Utils
local config = BanditHub.Config

local CombatTab = BanditHub.Window:Tab({ Title = "Combat" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AeroServices = ReplicatedStorage:WaitForChild("Aero"):WaitForChild("AeroRemoteServices"):WaitForChild("GameService")
local AttackStart = AeroServices:WaitForChild("WeaponAttackStart")
local AnimComplete = AeroServices:WaitForChild("WeaponAnimComplete")

local autoSwingEnabled = BanditHub.Toggles.AutoSwing or false
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
        BanditHub.Toggles.AutoSwing = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end
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

BanditHub.DisableAll = BanditHub.DisableAll or function() end
local oldDisable = BanditHub.DisableAll
BanditHub.DisableAll = function()
    autoSwingEnabled = false
    BanditHub.Toggles.AutoSwing = false
    if BanditHub.SaveSettings then BanditHub.SaveSettings() end
    oldDisable()
end
