local WindUI = SilverHub.WindUI
local utils = SilverHub.Utils

local MiscTab = SilverHub.Window:Tab({ Title = "Misc" })

local selectedPlayerName = nil
local playerDropdown = nil

local function GetPlayerNames()
    local names = {}
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function CreatePlayerDropdown()
    if playerDropdown then
        playerDropdown:Destroy()
        playerDropdown = nil
    end
    local playerNames = GetPlayerNames()
    if #playerNames == 0 then
        playerNames = {"No other players"}
        selectedPlayerName = nil
    else
        selectedPlayerName = playerNames[1]
    end
    playerDropdown = MiscTab:Dropdown({
        Title = "Select Player",
        Values = playerNames,
        Default = playerNames[1] or "No other players",
        Callback = function(value)
            selectedPlayerName = value
        end
    })
end

CreatePlayerDropdown()

MiscTab:Button({
    Title = "Refresh Players",
    Callback = function()
        CreatePlayerDropdown()
    end
})

MiscTab:Button({
    Title = "Teleport to Selected Player",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then return end
        if not selectedPlayerName or selectedPlayerName == "No other players" then
            return
        end
        local targetPlayer = game.Players:FindFirstChild(selectedPlayerName)
        if not targetPlayer then return end
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        local localCharacter = localPlayer.Character
        if not localCharacter then return end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        localRoot.CFrame = targetRoot.CFrame
    end
})

game.Players.PlayerAdded:Connect(CreatePlayerDropdown)
game.Players.PlayerRemoving:Connect(CreatePlayerDropdown)
