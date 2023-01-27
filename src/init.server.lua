--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/init.server.lua
    Desc: Creates the plugin widget, and connects to the front-end app
]]

assert(plugin, "Maui: Not running as a plugin, did you place this somewhere else by mistake?", 0)

local Tarmac = script.Tarmac -- Tarmac generated assets (See `/tarmac.toml`)
local Version = script.Version.Value -- /version.txt

local App = require(script.App) -- Front-end interface app
--local PluginSettings = require(script.PluginSettings) -- Global plugin config module
local Assets = require(Tarmac.Assets) -- Tarmac generated assets (See `/tarmac.toml`)

local NameWithVersion = "Maui " .. Version
local StudioTheme = settings().Studio.Theme

-- Initialize plugin widget
local PluginWidget do
    -- Proper icon color for the Studio theme, due to it being monochrome
    local WidgetToggleIcon = if StudioTheme.Name == "Light" then
        Assets["MauiLogo-LightMode"]
    else Assets["MauiLogo-DarkMode"] -- Then it's probably dark mode; default

    -- Create widget BEFORE the visible front-end toolbar
    PluginWidget = plugin:CreateDockWidgetPluginGui(
        "Maui", -- ID
        DockWidgetPluginGuiInfo.new(
            Enum.InitialDockState.Float, -- Floating widget by default
            false, -- NOT always be initially enabled
            false, -- DON'T override any saved enabled state
            250, -- Initial X size
            325, -- Initial Y size
            200, -- MINIMUM X size
            200 -- Minimum Y size
        )
    )

    -- Name & title it, it isn't assigned by default..
    PluginWidget.Name = NameWithVersion
    PluginWidget.Title = NameWithVersion
    PluginWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Toolbar = plugin:CreateToolbar(NameWithVersion)
    local WidgetToggle = Toolbar:CreateButton(
        "MauiToggle", -- ID
        "Open the Maui Widget", -- Tooltip; changes to "Open"/"Close" on toggle
        WidgetToggleIcon, -- Icon asset URL ("rbxasset://123456")
        "Maui"
    )

    -- Not true by default!
    WidgetToggle.ClickableWhenViewportHidden = true

    -- Fix enabled highlight on click
    WidgetToggle.Click:Connect(function()
        PluginWidget.Enabled = not PluginWidget.Enabled
        WidgetToggle:SetActive(PluginWidget.Enabled) -- Set the selected highlight to on/off
    end)

    -- When "X" is clicked on the plugins Qt widget
    PluginWidget:BindToClose(function()
        PluginWidget.Enabled = false
        WidgetToggle:SetActive(false) -- Like before, set the button to not active!
    end)
end

-- Initialize the real app with the plugin widget we've created
App(plugin, PluginWidget)
