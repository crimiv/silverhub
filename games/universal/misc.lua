local WindUI = AppleHub.WindUI

local MiscTab = AppleHub.Window:Tab({ Title = "Misc" })

local antiFlingEnabled = AppleHub.Toggles.antiFlingEnabled or false
local antiFlingHeartbeat = nil
local movementKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right}
local movementKeysPressed = {}

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    for _, key in ipairs(movementKeys) do
        if input.KeyCode == key then
            movementKeysPressed[key] = true
            break
        end
    end
end)
UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    for _, key in ipairs(movementKeys) do
        if input.KeyCode == key then
            movementKeysPressed[key] = nil
            break
        end
    end
end)

local function IsMoving()
    for _, key in ipairs(movementKeys) do
        if movementKeysPressed[key] then
            return true
        end
    end
    return false
end

local function AntiFlingLoop()
    if not antiFlingEnabled then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local localChar = localPlayer.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                root.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                root.CanCollide = false
            end)
        end
    end

    if not IsMoving() then
        if localRoot.Velocity.Magnitude > 0.1 then
            localRoot.Velocity = Vector3.new(0, 0, 0)
            localRoot.RotVelocity = Vector3.new(0, 0, 0)
        end
    end

    for _, child in ipairs(localChar:GetDescendants()) do
        if child:IsA("BodyVelocity") or child:IsA("BodyAngularVelocity") or child:IsA("BodyForce") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("BodyThrust") then
            child:Destroy()
        end
    end
end

local function SetupAntiFling()
    if antiFlingHeartbeat then
        antiFlingHeartbeat:Disconnect()
        antiFlingHeartbeat = nil
    end
    if antiFlingEnabled then
        antiFlingHeartbeat = game:GetService("RunService").Heartbeat:Connect(AntiFlingLoop)
    end
end

MiscTab:Toggle({
    Title = "Anti-Fling",
    Value = antiFlingEnabled,
    Callback = function(state)
        antiFlingEnabled = state
        AppleHub.Toggles.antiFlingEnabled = state
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        WindUI:Notify({
            Title = "Anti-Fling",
            Content = antiFlingEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        SetupAntiFling()
    end
})

AppleHub.DisableAll = function()
    antiFlingEnabled = false
    AppleHub.Toggles.antiFlingEnabled = false
    if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    if antiFlingHeartbeat then
        antiFlingHeartbeat:Disconnect()
        antiFlingHeartbeat = nil
    end
end