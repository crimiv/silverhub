local WindUI = SilverHub.WindUI
local utils = SilverHub.Utils
local config = SilverHub.Config

local TrollTab = SilverHub.Window:Tab({ Title = "Troll" })

local function IsSeated(player)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and (hum.SeatPart or hum:GetState() == Enum.HumanoidStateType.Seated)
end

local function FlingPlayer(target, silent)
    if not target or target == game.Players.LocalPlayer then
        return false
    end
    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = target.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    if not hrp or not tHrp or not tHum or tHum.Health <= 0 then
        return false
    end
    if IsSeated(target) then
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
    return launched
end

TrollTab:Button({
    Title = "Fling Murderer",
    Callback = function()
        local murderer = SilverHub.GetCurrentMurderer()
        if murderer then
            FlingPlayer(murderer, false)
        end
    end
})

TrollTab:Button({
    Title = "Fling Sheriff",
    Callback = function()
        local sheriff = SilverHub.GetCurrentSheriff()
        if sheriff then
            FlingPlayer(sheriff, false)
        end
    end
})

local autoFlingMurdererEnabled = false
local autoFlingSheriffEnabled = false
local autoFlingMurdererCoroutine = nil
local autoFlingSheriffCoroutine = nil

TrollTab:Toggle({
    Title = "Auto Fling Murderer",
    Value = false,
    Callback = function(state)
        autoFlingMurdererEnabled = state
        if autoFlingMurdererEnabled then
            if autoFlingMurdererCoroutine then
                autoFlingMurdererCoroutine = nil
            end
            autoFlingMurdererCoroutine = coroutine.create(function()
                while autoFlingMurdererEnabled do
                    local target = SilverHub.GetCurrentMurderer()
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
    Value = false,
    Callback = function(state)
        autoFlingSheriffEnabled = state
        if autoFlingSheriffEnabled then
            if autoFlingSheriffCoroutine then
                autoFlingSheriffCoroutine = nil
            end
            autoFlingSheriffCoroutine = coroutine.create(function()
                while autoFlingSheriffEnabled do
                    local target = SilverHub.GetCurrentSheriff()
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

local selectedFlingPlayer = nil
local flingDropdown = nil

local function GetPlayerNamesForFling()
    local names = {}
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function CreateFlingDropdown()
    if flingDropdown then
        flingDropdown:Destroy()
        flingDropdown = nil
    end
    local playerNames = GetPlayerNamesForFling()
    if #playerNames == 0 then
        playerNames = {"No other players"}
        selectedFlingPlayer = nil
    else
        selectedFlingPlayer = playerNames[1]
    end
    flingDropdown = TrollTab:Dropdown({
        Title = "Select Player to Fling",
        Values = playerNames,
        Default = playerNames[1] or "No other players",
        Callback = function(value)
            selectedFlingPlayer = value
        end
    })
end

CreateFlingDropdown()

TrollTab:Button({
    Title = "Refresh Players",
    Callback = function()
        CreateFlingDropdown()
    end
})

TrollTab:Button({
    Title = "Fling Selected Player",
    Callback = function()
        if not selectedFlingPlayer or selectedFlingPlayer == "No other players" then
            return
        end
        local targetPlayer = game.Players:FindFirstChild(selectedFlingPlayer)
        if not targetPlayer then
            return
        end
        task.spawn(function()
            while targetPlayer and targetPlayer.Parent do
                local launched = FlingPlayer(targetPlayer, true)
                if launched then
                    break
                end
                task.wait(0.5)
            end
        end)
    end
})

game.Players.PlayerAdded:Connect(CreateFlingDropdown)
game.Players.PlayerRemoving:Connect(CreateFlingDropdown)
