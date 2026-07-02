local WindUI = BanditHub.WindUI
local utils = BanditHub.Utils

local TrollTab = BanditHub.Window:Tab({ Title = "Troll" })


local function IsSeated(player)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and (hum.SeatPart or hum:GetState() == Enum.HumanoidStateType.Seated)
end

local function FlingPlayer(target, silent)
    if _G.BANDITHUB_UPDATING then return false end
    if not target or target == game.Players.LocalPlayer then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Invalid target", Duration = 2 }) end
        return false
    end

    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = target.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")

    if not hrp or not tHrp or not tHum or tHum.Health <= 0 then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Target invalid or dead", Duration = 2 }) end
        return false
    end

    if IsSeated(target) then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Target is seated", Duration = 2 }) end
        return false
    end

    local originalFPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0

    local oldPos = hrp.CFrame
    local targetStartPos = tHrp.Position
    local launched = false

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 1000000, 0)
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Parent = hrp

    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(1000000, 1000000, 1000000)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = hrp

    local timeout = tick() + 3
    while tick() < timeout and not launched do
        if _G.BANDITHUB_UPDATING then break end
        if not target.Parent or tHum.Health <= 0 then break end
        hrp.CFrame = tHrp.CFrame

        if (tHrp.Position - targetStartPos).Magnitude > 60 or tHrp.Velocity.Magnitude > 180 then
            launched = true
            break
        end

        task.wait()
    end

    bv:Destroy()
    bav:Destroy()

    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    hrp.CFrame = oldPos

    workspace.FallenPartsDestroyHeight = originalFPDH

    if launched then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Flung " .. target.Name, Duration = 2 }) end
    else
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Failed to fling " .. target.Name, Duration = 2 }) end
    end

    return launched
end

TrollTab:Button({
    Title = "Fling Murderer",
    Callback = function()
        if _G.BANDITHUB_UPDATING then return end
        local murderer = BanditHub.GetCurrentMurderer()
        if murderer then
            FlingPlayer(murderer, false)
        else
            WindUI:Notify({ Title = "Fling", Content = "No murderer found", Duration = 2 })
        end
    end
})

TrollTab:Button({
    Title = "Fling Sheriff",
    Callback = function()
        if _G.BANDITHUB_UPDATING then return end
        local sheriff = BanditHub.GetCurrentSheriff()
        if sheriff then
            FlingPlayer(sheriff, false)
        else
            WindUI:Notify({ Title = "Fling", Content = "No sheriff found", Duration = 2 })
        end
    end
})


local autoFlingMurdererEnabled = BanditHub.Toggles.autoFlingMurdererEnabled or false
local autoFlingSheriffEnabled = BanditHub.Toggles.autoFlingSheriffEnabled or false
local autoFlingMurdererCoroutine = nil
local autoFlingSheriffCoroutine = nil

TrollTab:Toggle({
    Title = "Auto Fling Murderer",
    Value = autoFlingMurdererEnabled,
    Callback = function(state)
        autoFlingMurdererEnabled = state
        BanditHub.Toggles.autoFlingMurdererEnabled = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end
        WindUI:Notify({
            Title = "Auto Fling Murderer",
            Content = autoFlingMurdererEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })

        if autoFlingMurdererEnabled then
            if autoFlingMurdererCoroutine then
                autoFlingMurdererCoroutine = nil
            end

            autoFlingMurdererCoroutine = coroutine.create(function()
                while autoFlingMurdererEnabled do
                    if _G.BANDITHUB_UPDATING then break end
                    local target = BanditHub.GetCurrentMurderer()
                    if target then
                        local launched = FlingPlayer(target, true)
                        if launched then
                            task.wait(0.5)
                        else
                            task.wait(0.1)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)

            coroutine.resume(autoFlingMurdererCoroutine)
        else
            if autoFlingMurdererCoroutine then
                autoFlingMurdererCoroutine = nil
            end
        end
    end
})

TrollTab:Toggle({
    Title = "Auto Fling Sheriff",
    Value = autoFlingSheriffEnabled,
    Callback = function(state)
        autoFlingSheriffEnabled = state
        BanditHub.Toggles.autoFlingSheriffEnabled = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end
        WindUI:Notify({
            Title = "Auto Fling Sheriff",
            Content = autoFlingSheriffEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })

        if autoFlingSheriffEnabled then
            if autoFlingSheriffCoroutine then
                autoFlingSheriffCoroutine = nil
            end

            autoFlingSheriffCoroutine = coroutine.create(function()
                while autoFlingSheriffEnabled do
                    if _G.BANDITHUB_UPDATING then break end
                    local target = BanditHub.GetCurrentSheriff()
                    if target then
                        local launched = FlingPlayer(target, true)
                        if launched then
                            task.wait(0.5)
                        else
                            task.wait(0.1)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)

            coroutine.resume(autoFlingSheriffCoroutine)
        else
            if autoFlingSheriffCoroutine then
                autoFlingSheriffCoroutine = nil
            end
        end
    end
})








local autoBreakGunEnabled = BanditHub.Toggles.autoBreakGunEnabled or false
local autoBreakGunBusy = false
local autoBreakGunConn = nil
local autoBreakGunLastTrigger = 0
local AUTO_BREAK_GUN_COOLDOWN = 3


local function GetClosestGunDrop(maxDistance)
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return nil end
    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest = nil
    local closestDist = maxDistance or math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                local primary = obj.PrimaryPart
                if primary then
                    pos = primary.Position
                else
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pos = part.Position
                            break
                        end
                    end
                end
            end
            if pos then
                local dist = (root.Position - pos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end
    end
    return closest
end

local function TeleportToLobbyAndRespawn()
    local lp = game.Players.LocalPlayer
    if not lp or not lp.Character then return end

    local lobby = workspace:FindFirstChild("RegularLobby")
    if lobby and lobby:IsA("Model") then
        local pivot = lobby:GetPivot()
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = pivot * CFrame.new(0, 3, 0)
        end
    end

    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.Health = 0
        end)
    end
end

local function BreakGunAndRespawn()
    if _G.BANDITHUB_UPDATING then return end
    if autoBreakGunBusy then return end

    local now = tick()
    if (now - autoBreakGunLastTrigger) < AUTO_BREAK_GUN_COOLDOWN then
        return
    end

    autoBreakGunBusy = true
    autoBreakGunLastTrigger = now

    pcall(function()
        -- Try to grab the gun drop (teleport close, wait briefly)
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer or not localPlayer.Character then return end

        local localHum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if localHum and localHum.Health <= 0 then return end

        local gunDrop = GetClosestGunDrop(60)
        if not gunDrop then return end

        local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetCFrame = nil
        if gunDrop:IsA("BasePart") then
            targetCFrame = gunDrop.CFrame
        elseif gunDrop:IsA("Model") then
            local primary = gunDrop.PrimaryPart
            if primary then
                targetCFrame = primary.CFrame
            else
                for _, part in ipairs(gunDrop:GetDescendants()) do
                    if part:IsA("BasePart") then
                        targetCFrame = part.CFrame
                        break
                    end
                end
            end
        end
        if not targetCFrame then return end

        hrp.CFrame = targetCFrame * CFrame.new(0, 2, 0)

        -- short wait to allow pickup to register
        task.wait(0.5)
    end)

    pcall(TeleportToLobbyAndRespawn)

    task.wait(0.2)
    autoBreakGunBusy = false
end


TrollTab:Toggle({
    Title = "Auto Break Gun",
    Value = autoBreakGunEnabled,
    Callback = function(state)
        autoBreakGunEnabled = state
        BanditHub.Toggles.autoBreakGunEnabled = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end

        if not autoBreakGunEnabled then
            if autoBreakGunConn then
                autoBreakGunConn:Disconnect()
                autoBreakGunConn = nil
            end
            return
        end

        -- Listen for new GunDrop or periodically attempt.
        if autoBreakGunConn then
            autoBreakGunConn:Disconnect()
            autoBreakGunConn = nil
        end

        autoBreakGunConn = game:GetService("RunService").Stepped:Connect(function()
            if not autoBreakGunEnabled then return end
            if _G.BANDITHUB_UPDATING then return end
            if autoBreakGunBusy then return end

            -- If there is at least one GunDrop, attempt grab+respawn.
            local found = nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "GunDrop" then
                    found = obj
                    break
                end
            end
            if found then
                BreakGunAndRespawn()
            end
        end)

        WindUI:Notify({
            Title = "Auto Break Gun",
            Content = autoBreakGunEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
    end
})




BanditHub.DisableAll = function()
    autoFlingMurdererEnabled = false
    BanditHub.Toggles.autoFlingMurdererEnabled = false
    autoFlingSheriffEnabled = false
    BanditHub.Toggles.autoFlingSheriffEnabled = false

    autoBreakGunEnabled = false
    BanditHub.Toggles.autoBreakGunEnabled = false

    if BanditHub.SaveSettings then BanditHub.SaveSettings() end

    if autoBreakGunConn then
        autoBreakGunConn:Disconnect()
        autoBreakGunConn = nil
    end
    autoBreakGunBusy = false
end


