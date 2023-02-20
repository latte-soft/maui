--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/Components/Console.lua
    Desc: Console component for front-end app
]]

local Root = script.Parent.Parent
local Packages = Root.Packages

local Fusion = require(Packages.Fusion)

-- Fusion definitions
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Value = Fusion.Value
local Computed = Fusion.Computed
local Out = Fusion.Out

local StudioTheme = settings().Studio.Theme

--[[
    props = {
        Text: string/Value<string> = ""
        AnchorPoint: Vector2/Value<Vector2>? = Vector2.new(0, 0)
        Position: UDim2/Value<UDim2>? = UDim2.fromOffset(0, 0)
        Size: UDim2/Value<UDim2>? = UDim2.fromOffset(300, 200)
        AutoScrollEnabled: Value<boolean>? = false
        RightClickContextMenu: PluginMenu? = nil
    }
]]
return function(props)
    -- We need to keep track of these properties later for autoscroll
    local CanvasPosition = Value(Vector2.new(0, 0))

    return New "Frame" {
        Name = "Console",

        AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
        Position = props.Position or UDim2.fromOffset(0, 0),
        Size = props.Size or UDim2.fromOffset(300, 200),

        BackgroundColor3 = StudioTheme:GetColor("ScrollBarBackground"),
        BorderSizePixel = 1,
        BorderColor3 = StudioTheme:GetColor("Border"),

        [Children] = {
            New "TextLabel" {
                Name = "AutoScrollIndicator",

                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 24),

                BackgroundColor3 = StudioTheme:GetColor("Titlebar"),
                BorderSizePixel = 1,
                BorderColor3 = StudioTheme:GetColor("Border"),

                Text = Computed(function()
                    return "Autoscrolling Enabled: " .. tostring(if props.AutoScrollEnabled then props.AutoScrollEnabled:get() else false)
                end),
                Font = Enum.Font.SourceSans,
                TextColor3 = StudioTheme:GetColor("MainText"),
                TextXAlignment = Enum.TextXAlignment.Right,

                [Children] = {
                    New "UIPadding" {
                        PaddingRight = UDim.new(0, 6)
                    }
                }
            },

            New "ScrollingFrame" {
                Name = "ScrollWindow",

                Size = UDim2.new(1, 0, 1, -25), -- 1 pixel less so the X scrollbar doesnt overlap border

                BackgroundTransparency = 1,

                AutomaticCanvasSize = Enum.AutomaticSize.XY,
                ScrollingDirection = Enum.ScrollingDirection.XY,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageColor3 = StudioTheme:GetColor("ScrollBar"),
                ScrollBarThickness = 12,
                VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
                HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
                ElasticBehavior = Enum.ElasticBehavior.Never,
                TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",

                -- Keep track of for auto scroll
                CanvasPosition = CanvasPosition,
                [Out "CanvasPosition"] = CanvasPosition,

                [OnChange "AbsoluteCanvasSize"] = if not props.AutoScrollEnabled then Fusion.doNothing else function(newCanvasSize)
                    if props.AutoScrollEnabled:get() then
                        CanvasPosition:set(Vector2.new(CanvasPosition:get().X, newCanvasSize.Y))
                    end
                end,

                -- Check if there's a context menu to run on right click end
                [OnEvent "InputEnded"] = if not props.RightClickContextMenu then Fusion.doNothing else function(inputObject)
                    if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
                        -- This yields, but it's expected that any `PluginAction.Triggered` events were setup when this prop was passed
                        props.RightClickContextMenu:ShowAsync()
                    end
                end,

                [Children] = {
                    New "TextLabel" {
                        Name = "ConsoleText",

                        AutomaticSize = Enum.AutomaticSize.XY,
                        Size = UDim2.fromScale(1, 0),

                        BackgroundTransparency = 1,

                        Text = props.Text,
                        Font = Enum.Font.Code,
                        LineHeight = 1.1,
                        TextColor3 = StudioTheme:GetColor("SubText"),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,

                        [Children] = {
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0, 8),
                                PaddingRight = UDim.new(0, -8),
                                PaddingTop = UDim.new(0, 6),
                                PaddingBottom = UDim.new(0, 6),
                            }
                        }
                    }
                }
            }
        }
    }
end
