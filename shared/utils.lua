local AppleHub = {}

function AppleHub.GetPlayerFromArg(arg)
    if typeof(arg) == "Instance" and arg:IsA("Player") then
        return arg
    elseif type(arg) == "string" then
        return game.Players:FindFirstChild(arg)
    end
    return nil
end

function AppleHub.PlayerHasTool(player, toolName)
    if not player then return false end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                return true
            end
        end
    end
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                return true
            end
        end
    end
    return false
end

function AppleHub.TeleportToCFrame(targetCFrame)
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return false end
    local character = localPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    rootPart.CFrame = targetCFrame
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    local originalSit = humanoid.Sit
    humanoid.Sit = true
    task.wait(0.1)
    humanoid.Sit = originalSit
    return true
end

return AppleHub