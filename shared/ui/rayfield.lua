-- Rayfield adapter (sirius.menu)
-- Docs snippet:
--   local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Normalize the config format coming from existing hub entrypoints.
-- This repo’s WindUI config expects fields like Title/Author/Theme/Size.
-- Rayfield’s API differs; we map only the common ones.
local function ToRayfieldWindowConfig(config)
    config = config or {}
    return {
        Name = config.Title or config.Name or "Bandit Hub",
        LoadingTitle = config.LoadingTitle or (config.Title or "Bandit Hub"),
        LoadingSubtitle = config.LoadingSubtitle or "",
        Theme = config.Theme or config.ColorScheme or "Default",
        KeySystem = false,
    }
end

local RayfieldUI = {}

function RayfieldUI:CreateWindow(config)
    -- Rayfield window creation (typical API)
    -- Rayfield:CreateWindow(options)
    local window = Rayfield:CreateWindow(ToRayfieldWindowConfig(config))
    return window
end

function RayfieldUI:Notify(payload)
    -- payload expected: {Title=, Content=, Duration=}
    payload = payload or {}
    local title = payload.Title or "Notification"
    local content = payload.Content or payload.Text or ""
    local duration = payload.Duration or 5

    -- Rayfield:Notify({Title=, Content=, Duration=, Image=, ...})
    return Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration,
    })
end

-- For compatibility with adapter expectations in shared/uiloader.lua
RayfieldUI.Notify = RayfieldUI.Notify

return RayfieldUI


