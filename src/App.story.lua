--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/App.story.lua
    Desc: UI storybook script for Hoarcekat, lists all UI components
]]

local Root = script.Parent
local Submodules = Root.Submodules
local Components = Root.Components

local Fusion = require(Submodules.Fusion)

-- Components
local Button = require(Components.Button)
local Console = require(Components.Console)

-- Fusion definitions
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value

return function(target)
    local List = New "Frame" {
        Name = "MauiAppPreview",
        Parent = target,

        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -12, 1, -12),

        BackgroundTransparency = 1,

        [Children] = {
            New "UIListLayout" {
                Padding = UDim.new(0, 12),
            },

            -- COMPONENTS --

            Button {
                Text = "Hello, world!",
            },

            Button {
                Text = "This button is disabled..",
                Enabled = false
            },

            Console {
                Text = Value("This is a (pretty cool) console!\n\n")
            }
        }
    }

    -- Destructor function
    return function()
        pcall(List.Destroy, Button)
    end
end
