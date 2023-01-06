--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the LGPLv3 | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/Components/Button.lua
    Desc: Button component for front-end app
]]

local Root = script.Parent.Parent
local Submodules = Root.Submodules

local Fusion = require(Submodules.Fusion)

-- Fusion definitions
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Computed = Fusion.Computed

local StudioTheme = settings().Studio.Theme

--[[
    props = {
        Text: string/Value<string>? = "Button"
        Enabled: boolean/Value<boolean>? = true
        IsPrimary boolean/Value<boolean>? = false
        AnchorPoint: Vector2/Value<Vector2>? = Vector2.new(0, 0)
        Position: UDim2/Value<UDim2>? = UDim2.fromOffset(0, 0)
        Size: UDim2/Value<UDim2>? = UDim2.fromOffset(0, 24)
        LayoutOrder = number/Value<number>? = 1
        TextWrapped: boolean/Value<boolean>? = false
        OnClick: function? = nil
    }
]]
return function(props)
    -- Set default value of `props.Enabled` if needed
    props.Enabled = if props.Enabled == nil then
            Value(true)
        elseif type(props.Enabled) == "boolean" then
            Value(props.Enabled)
        else props.Enabled

    -- Again, set `props.IsPrimary` if needed, which is the "blue" color Studio
    -- uses on some buttons they want to highlight out or whatever
    props.IsPrimary = if props.IsPrimary == nil then
            Value(false)
        elseif type(props.IsPrimary) == "boolean" then
            Value(props.IsPrimary)
        else props.IsPrimary

    -- For bg effects and such
    local IsSelected = Value(false)
    local IsHovering = Value(false)

    -- Automatically get `StudioStyleGuideModifier` for objs based on state
    local function GetStyleGuideModifier()
        return if not props.Enabled:get() then
                Enum.StudioStyleGuideModifier.Disabled
            elseif IsSelected:get() then
                Enum.StudioStyleGuideModifier.Pressed
            elseif IsHovering:get() then
                Enum.StudioStyleGuideModifier.Hover
            else
                Enum.StudioStyleGuideModifier.Default
    end
    
    return New "TextButton" {
        Name = "Button",
        LayoutOrder = props.LayoutOrder or 1,

        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
        Position = props.Position or UDim2.fromOffset(0, 0),
        Size = props.Size or UDim2.fromOffset(0, 24), -- AutomaticSize is enabled for X

        BackgroundColor3 = Computed(function()
            return StudioTheme:GetColor(
                if props.IsPrimary:get() then "MainButton" else "Button",
                GetStyleGuideModifier()
            )
        end),
        BorderSizePixel = 1,
        BorderColor3 = Computed(function()
            return StudioTheme:GetColor("Border", GetStyleGuideModifier())
        end),

        Text = props.Text or "Button",
        Font = Enum.Font.SourceSans,
        TextSize = 16,
        TextWrapped = props.TextWrapped or false,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Computed(function()
            return StudioTheme:GetColor(
                if props.IsPrimary:get() then "BrightText" else "MainText",
                GetStyleGuideModifier()
            )
        end),

        -- Events
        [OnEvent "MouseButton1Click"] = function()
            if props.Enabled:get() and props.OnClick then
                props.OnClick()
            end
        end,

        [OnEvent "MouseButton1Down"] = function()
            IsSelected:set(true)
        end,

        [OnEvent "MouseButton1Up"] = function()
            IsSelected:set(false)
        end,

        [OnEvent "MouseEnter"] = function()
            IsHovering:set(true)
        end,

        [OnEvent "MouseLeave"] = function()
            IsHovering:set(false)
            IsSelected:set(false)
        end,

        [Children] = {
            New "UIPadding" {
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
            }
        }
    }
end
