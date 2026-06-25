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

function AppleHub.Notify(params)
    local success, result = pcall(function()
        local title = params.Title or ""
        local text = params.Content or params.Text or ""
        local duration = params.Duration or 3
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

return AppleHub