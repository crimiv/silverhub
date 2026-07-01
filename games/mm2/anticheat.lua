local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils

local AntiCheatTab = LinuxHub.Window:Tab({ Title = "Anti-Cheat" })

local anticheatEnabled = LinuxHub.Toggles.anticheatEnabled or false
local suspiciousPlayers = {}
local detectionHistory = {}
local lastPositions = {}
local playerAirTime = {}
local updateCooldown = 0

local function ClearDetections()
    suspiciousPlayers = {}
    detectionHistory = {}
end

local function AddSuspicion(player, reason)
    if not player then return end
    
    if not suspiciousPlayers[player.Name] then
        suspiciousPlayers[player.Name] = {
            player = player,
            suspicionLevel = 0,
            reasons = {}
        }
    end
    
    if not suspiciousPlayers[player.Name].reasons[reason] then
        suspiciousPlayers[player.Name].reasons[reason] = 0
        suspiciousPlayers[player.Name].suspicionLevel = suspiciousPlayers[player.Name].suspicionLevel + 1
    end
    suspiciousPlayers[player.Name].reasons[reason] = suspiciousPlayers[player.Name].reasons[reason] + 1
    
    table.insert(detectionHistory, {
        player = player.Name,
        reason = reason,
        time = os.time()
    })
end

local function DetectSpeedHacks(player)
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local currentPos = humanoidRootPart.Position
    local lastPos = lastPositions[player.Name]
    
    if lastPos then
        local distance = (currentPos - lastPos).Magnitude
        local maxExpectedDistance = 0.3 * 50 -- humanoid max speed * delta time (~0.3s)
        
        if distance > maxExpectedDistance * 2 then
            AddSuspicion(player, "Speed Hack Detected")
        end
    end
    
    lastPositions[player.Name] = currentPos
end

local function DetectPhysicsExploits(player)
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Detect BodyVelocity (used in fly scripts like the example)
    local bodyVelocity = humanoidRootPart:FindFirstChild("BodyVelocity")
    if bodyVelocity then
        AddSuspicion(player, "BodyVelocity Exploit Detected")
    end
    
    -- Detect BodyGyro (used in fly scripts for rotation control)
    local bodyGyro = humanoidRootPart:FindFirstChild("BodyGyro")
    if bodyGyro then
        AddSuspicion(player, "BodyGyro Exploit Detected")
    end
    
    -- Detect platform stand abuse (used in fly scripts)
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid and humanoid.PlatformStand then
        AddSuspicion(player, "PlatformStand Exploit")
    end
end

local function DetectFlying(player)
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then return end
    
    -- Initialize air time tracking
    if not playerAirTime[player.Name] then
        playerAirTime[player.Name] = 0
    end
    
    -- Check if player is in air (not on floor and not jumping normally)
    if humanoid:GetState() == Enum.HumanoidStateType.Flying then
        AddSuspicion(player, "Flying State Detected")
        return
    end
    
    -- Check for freefall state lasting too long
    if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        playerAirTime[player.Name] = playerAirTime[player.Name] + 0.3
        
        -- If in freefall for more than 5 seconds without jumping, likely flying
        if playerAirTime[player.Name] > 5 then
            AddSuspicion(player, "Prolonged Flight Detected")
        end
    else
        playerAirTime[player.Name] = 0
    end
    
    -- Check for unnatural vertical movement
    local currentY = humanoidRootPart.Position.Y
    local lastPos = lastPositions[player.Name]
    
    if lastPos then
        local verticalMovement = currentY - lastPos.Y
        
        -- Constant upward movement without jumping (gravity should pull down)
        if verticalMovement > 2 and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            AddSuspicion(player, "Unnatural Upward Movement")
        end
    end
end

local function CheckRoleCounts()
    local murdererCount = 0
    local sheriffCount = 0
    local murderers = {}
    local sheriffs = {}
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(plr, "Knife") then
            murdererCount = murdererCount + 1
            table.insert(murderers, plr)
        end
        if utils.PlayerHasTool(plr, "Gun") then
            sheriffCount = sheriffCount + 1
            table.insert(sheriffs, plr)
        end
    end
    
    -- Flag all if there's more than 1 of each role
    if murdererCount > 1 then
        for _, plr in pairs(murderers) do
            AddSuspicion(plr, "Multiple Murderers Exploit")
        end
    end
    
    if sheriffCount > 1 then
        for _, plr in pairs(sheriffs) do
            AddSuspicion(plr, "Multiple Sheriffs Exploit")
        end
    end
end

local function DetectTeleportation(player)
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local currentPos = humanoidRootPart.Position
    local lastPos = lastPositions[player.Name]
    
    if lastPos then
        local distance = (currentPos - lastPos).Magnitude
        
        -- Teleporting more than 100 studs instantly
        if distance > 100 then
            AddSuspicion(player, "Teleportation Detected")
        end
    end
end

local function UpdateAntiCheat()
    if _G.LINUXHUB_UPDATING then
        ClearDetections()
        return
    end
    
    if not anticheatEnabled then return end
    
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    
    -- Check role counts once globally
    CheckRoleCounts()
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        
        DetectSpeedHacks(player)
        DetectPhysicsExploits(player)
        DetectFlying(player)
        DetectTeleportation(player)
    end
end

AntiCheatTab:Toggle({
    Title = "Anti-Cheat Detection",
    Value = anticheatEnabled,
    Callback = function(state)
        anticheatEnabled = state
        LinuxHub.Toggles.anticheatEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Anti-Cheat",
            Content = anticheatEnabled and "Detection Enabled" or "Detection Disabled",
            Duration = 2,
        })
        if not anticheatEnabled then
            ClearDetections()
        end
    end
})

AntiCheatTab:Label({
    Title = "Suspicious Players: " .. tostring(#suspiciousPlayers),
})

local suspiciousPlayersLabel = AntiCheatTab:Label({ Title = "Loading..." })

AntiCheatTab:Button({
    Title = "Refresh Detections",
    Callback = function()
        UpdateAntiCheat()
        
        local playerList = {}
        for name, data in pairs(suspiciousPlayers) do
            if data.suspicionLevel > 0 then
                table.insert(playerList, name .. " (Suspicion: " .. tostring(data.suspicionLevel) .. ")")
            end
        end
        
        local displayText = #playerList > 0 and table.concat(playerList, ", ") or "None detected"
        suspiciousPlayersLabel:Set("Suspicious Players: " .. displayText)
        
        WindUI:Notify({
            Title = "Anti-Cheat",
            Content = "Scan complete. Found " .. tostring(#playerList) .. " suspicious player(s)",
            Duration = 2,
        })
    end
})

AntiCheatTab:Button({
    Title = "Clear Detections",
    Callback = function()
        ClearDetections()
        suspiciousPlayersLabel:Set("Suspicious Players: None")
        WindUI:Notify({
            Title = "Anti-Cheat",
            Content = "Detections cleared",
            Duration = 2,
        })
    end
})

AntiCheatTab:Label({
    Title = "Detection History (Last 10):",
})

local historyLabel = AntiCheatTab:Label({ Title = "None" })

AntiCheatTab:Button({
    Title = "View Detection History",
    Callback = function()
        local recentHistory = {}
        for i = math.max(1, #detectionHistory - 9), #detectionHistory do
            if detectionHistory[i] then
                table.insert(recentHistory, detectionHistory[i].player .. ": " .. detectionHistory[i].reason)
            end
        end
        
        local displayText = #recentHistory > 0 and table.concat(recentHistory, "\n") or "No detections yet"
        historyLabel:Set(displayText)
    end
})

-- Auto-update anti-cheat detection
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.LINUXHUB_UPDATING then return end
    
    if anticheatEnabled then
        local now = tick()
        if now - updateCooldown >= 1 then
            updateCooldown = now
            UpdateAntiCheat()
        end
    end
end)

-- Clean up when player leaves
game.Players.PlayerRemoving:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    
    suspiciousPlayers[player.Name] = nil
    lastPositions[player.Name] = nil
    playerAirTime[player.Name] = nil
end)

-- Clean up air time on respawn
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        playerAirTime[player.Name] = nil
    end)
end)

LinuxHub.DisableAll = (function()
    local original = LinuxHub.DisableAll
    return function()
        anticheatEnabled = false
        LinuxHub.Toggles.anticheatEnabled = false
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        ClearDetections()
        if original then original() end
    end
end)()
