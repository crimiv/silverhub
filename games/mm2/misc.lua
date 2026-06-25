local WindUI = AppleHub.WindUI
local utils = AppleHub.Utils

local MiscTab = AppleHub.Window:Tab({ Title = "Misc" })

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
        WindUI:Notify({ Title = "Misc", Content = "Player list refreshed", Duration = 2 })
    end
})

MiscTab:Button({
    Title = "Teleport to Selected Player",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        if not selectedPlayerName or selectedPlayerName == "No other players" then
            WindUI:Notify({ Title = "Error", Content = "No valid player selected", Duration = 2 })
            return
        end
        local targetPlayer = game.Players:FindFirstChild(selectedPlayerName)
        if not targetPlayer then
            WindUI:Notify({ Title = "Error", Content = "Selected player not found", Duration = 2 })
            return
        end
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then
            WindUI:Notify({ Title = "Error", Content = "Selected player has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            WindUI:Notify({ Title = "Error", Content = "Selected player has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            WindUI:Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            WindUI:Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        WindUI:Notify({ Title = "Misc", Content = "Teleported to " .. targetPlayer.Name, Duration = 2 })
    end
})

game.Players.PlayerAdded:Connect(CreatePlayerDropdown)
game.Players.PlayerRemoving:Connect(CreatePlayerDropdown)