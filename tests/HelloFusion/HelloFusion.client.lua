-- Maui demo using Fusion with an exploit env

local CoreGui = game:GetService("CoreGui")

local Fusion = require(script.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed

local ExecutorName = identifyexecutor()
local ValueChanges = Value(0)

task.spawn(function()
    for _ = 1, 50 do
        ValueChanges:set(ValueChanges:get() + 1)
        task.wait(1)
    end
end)

New "ScreenGui" {
    Name = "MauiWithFusion",
    Parent = CoreGui,

    DisplayOrder = 100,
    ResetOnSpawn = false,

    [Children] = {
        New "TextLabel" {
            Name = "Hello",

            AutomaticSize = Enum.AutomaticSize.XY,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(44, 56, 63),

            Position = UDim2.fromScale(0.5, 0.5),

            Font = Enum.Font.GothamMedium,
            Text = Computed(function()
                return "Hello, Maui & Fusion!\nRunning on: " .. ExecutorName .. "\n\n" .. "Testing.. Testing... " .. ValueChanges:get()
            end),
            TextColor3 = Color3.fromRGB(218, 223, 228),
            TextSize = 16,
            TextWrapped = true,

            [Children] = {
                New "UIPadding" {
                    PaddingTop = UDim.new(0, 16),
                    PaddingBottom = UDim.new(0, 16),
                    PaddingLeft = UDim.new(0, 16),
                    PaddingRight = UDim.new(0, 16),
                },

                New "UICorner" {
                    CornerRadius = UDim.new(0, 4)
                },

                New "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(45, 51, 58)
                }
            }
        }
    }
}
