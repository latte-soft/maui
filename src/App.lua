--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the LGPLv3 | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/App.lua
    Desc: Initializes the front-end app client, works with codegen assembler and Fusion
    components for UI
]]

local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local ScriptEditorService = game:GetService("ScriptEditorService")

local Root = script.Parent
local Submodules = Root.Submodules
local Components = Root.Components

local Codegen = require(Root.Codegen)
local Fusion = require(Submodules.Fusion)

-- Constants
local DEFAULT_CONSOLE_TEXT = "Maui | Copyright (c) 2022-2023 Latte Softworks <latte.to>\nGitHub: latte-soft/maui\n\nTo build a new script from a model, make a selection in your explorer, then just use the options below.\nRight click this console for further options.\n\n"
local INITIAL_OUTPUT_TEXT = "-- Maui: Waiting to add real script output to the editor..\n"

-- Default options for the `.maui` format
local DEFAULT_OPTIONS = {
    FormatVersion = 1, -- Isn't necessary in the project file, but just for future proofing the format incase we ever change anything

    -- All output options
    Output = {
        MinifyTable = false, -- If the codegen table itself (made from LuaEncode) is to be minified
        UseMinifiedLoader = true -- Use the pre-minified LoadModule script in the codegen, which is always predefined and not useful for debugging
    },

    -- Property wl/bl overrides
    Properties = {
        Whitelist = {}, -- [ClassName] = {PropertyName, ...}
        Blacklist = {} --  ^^^
    }
}

-- Fusion definitions
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer

-- Fusion UI components
local Button = require(Components.Button)
local Console = require(Components.Console)

-- yeah.. classic
local function DeepClone(inputTable)
    local NewTable = {}

    for Key, NewValue in inputTable do
        NewTable[Key] = if type(NewValue) == "table" then DeepClone(NewValue) else NewValue
    end

    return NewTable
end

-- Fixes "invalid unicode" error w/ EditTextAsync if there's unicode in any closure comments removed from orig.
-- This was taken from our LuaEncode project: https://github.com/regginator/LuaEncode/blob/master/src/LuaEncode.lua#L48-L86
local EscapeUnicode do
    local SpecialCharacters = {}

    for Index = 0, 255 do
        local Character = string.char(Index)

        if not SpecialCharacters[Character] and Index > 126 then
            SpecialCharacters[Character] = "\\" .. Index
        end
    end

    function EscapeUnicode(inputString)
        return string.gsub(inputString, "[\127-\255]", SpecialCharacters)
    end
end

return function(plugin, pluginWidget)
    -- We need to pass through the plugin object here
    local PluginSettings = require(Root.PluginSettings)(plugin)

    local CurrentSelection = Value({})
    local SelectedScript = Value(nil)

    -- GUI console state values
    local ConsoleOutput = Value(DEFAULT_CONSOLE_TEXT)
    local AutoScrollEnabled = Value(PluginSettings.Get("ConsoleAutoscroll")) -- Can be changed thru context menu

    local function Log(text, logStack)
        ConsoleOutput:set(ConsoleOutput:get() .. string.rep("-", logStack or 1) .. "> " .. text .. "\n")
    end

    -- Send everything to the codegen assembler when a build is requested
    local function Build()
        local SelectionToBuild = CurrentSelection:get()
        local FirstObjectSelected = SelectionToBuild[1]

        -- Check if ther selection actually CONTAINS anything..
        if not FirstObjectSelected or not Codegen.CanReadInstance(FirstObjectSelected) then
            return
        end

        -- Get default options, and if there's a `.maui` project file, use those
        local Options, MauiProjectFileModule = DeepClone(DEFAULT_OPTIONS), FirstObjectSelected:FindFirstChild(".maui") do 
            if MauiProjectFileModule then
                -- Try to read and parse project format
                local MauiProjectFile = require(MauiProjectFileModule)
                if type(MauiProjectFile) ~= "table" then
                    Log("`.maui` project file given isn't a valid Lua/JSON module, failed to parse.")
                    return
                end

                if MauiProjectFile["FormatVersion"] and MauiProjectFile.FormatVersion ~= 1 then
                    Log("Invalid format version in `.maui` project file. Expected 1, got " .. tostring(MauiProjectFile.FormatVersion))
                    return
                end

                Log("Reading `.maui` project file..")

                -- Replace all eligable options for output
                if MauiProjectFile["Output"] then
                    local function RecursiveAddOptions(realTable, outputOptions)
                        for Key, NewValue in outputOptions do
                            if realTable[Key] ~= nil then -- Then it's in the real default options, we can add
                                -- If the value is just another table, we'll recursively go thru (yep:tm: x2)
                                if type(NewValue) == "table" then
                                    RecursiveAddOptions(realTable[Key], NewValue)
                                    continue
                                end

                                realTable[Key] = NewValue
                            else
                                Log("Invalid output option \"" .. tostring(Key) .. "\" in project file, did you make a typo?", 2)
                            end
                        end
                    end

                    RecursiveAddOptions(Options.Output, MauiProjectFile.Output)
                end

                -- Handle custom property overwrites
                if MauiProjectFile["Properties"] then
                    local PropertyOptions = MauiProjectFile["Properties"]

                    local Whitelist = PropertyOptions["Whitelist"]
                    local Blacklist = PropertyOptions["Blacklist"]

                    if Whitelist then
                        local RealWhitelist = Options.Properties.Whitelist

                        for ClassName, ClassProperties in Whitelist do
                            RealWhitelist[ClassName] = ClassProperties
                        end
                    end

                    if Blacklist then
                        local RealBlacklist = Options.Properties.Blacklist

                        for ClassName, ClassProperties in Blacklist do
                            RealBlacklist[ClassName] = ClassProperties
                        end
                    end
                end
            end
        end

        -- Make the first object in the selection (USUALLY the only) the name of the outputted script, just
        -- so we can have something to base off of. We'll remove all ctrl chars, spaces, and periods from this
        -- string, so it's a little more friendly for the explorer. We'll also truncate to 50 characters
        local ScriptName = FirstObjectSelected.Name:sub(1, 50):gsub("[\0-\31\127-\255]", ""):gsub("[\32%.]", "_")

        Log("Attempting to build script \"" .. ScriptName .. "\"")

        -- Pass through the log function aswell, for detailed steps of what the assembler is actually doing
        local DidBuild, GeneratedScriptOrError = pcall(Codegen.BuildFromSelection, SelectionToBuild, Log, Options, MauiProjectFileModule)

        if not DidBuild then
            Log("Failed to build due to error: \"" .. GeneratedScriptOrError or "[No error message attached]" .. "\"", 2)
            return
        end

        Log("Successfully built, opening..", 2)

        -- ServerStorage["Maui | Built Scripts"]
        local MauiScriptsFolder = ServerStorage:FindFirstChild("Maui | Built Scripts")
        if not MauiScriptsFolder then
            MauiScriptsFolder = Instance.new("Folder")
            MauiScriptsFolder.Name = "Maui | Built Scripts"
            MauiScriptsFolder.Parent = ServerStorage
        end

        -- ServerStorage["Maui | Built Scripts"][ScriptName]
        local SpecificScriptBuilds = MauiScriptsFolder:FindFirstChild(ScriptName)
        if not SpecificScriptBuilds then
            SpecificScriptBuilds = Instance.new("Folder")
            SpecificScriptBuilds.Name = ScriptName
            SpecificScriptBuilds.Parent = MauiScriptsFolder
        end

        -- Studio may prompt the user to give the plugin access to writing `Script.Source`, it
        -- doesn't just yield and set it when they click "Allow", we have to do it again outselves
        -- ALSO, setting this property can err if the str is too long (yay!)
        local CreateScriptOk, ErrorMessage = pcall(function()
            -- Create the real script obj
            local ScriptObject = Instance.new("Script")

            -- Format the current date-time into the name, just for basic organization for
            -- the user. I'd make it just the epoch time, but just doing this for readability
            ScriptObject.Name = os.date(ScriptName .. "_%Y-%m-%d_%H-%M-%S")

            pcall(function()
                ScriptObject.Source = INITIAL_OUTPUT_TEXT
            end)

            ScriptObject.Parent = SpecificScriptBuilds
            Selection:Set({ScriptObject}) -- Select the script object for the "Save" button feature
            ScriptEditorService:OpenScriptDocumentAsync(ScriptObject)

            Log("Opened from location \"" .. ScriptObject:GetFullName() .. "\", adding output..", 2)

            if #GeneratedScriptOrError < 200000 then
                ScriptObject.Source = GeneratedScriptOrError
            else
                -- Yes, this is VERY HACKY, but we have to do this instead due to `Script.Source`'s internal
                -- __newindex set limit. We have to escape all "invalid" unicode from strings in the script,
                -- or `ScriptDocument:EditTextAsync` will error with a cryptic message to the user
                local EscapedScript = EscapeUnicode(GeneratedScriptOrError)

                local ScriptDocument = ScriptEditorService:FindScriptDocument(ScriptObject)
                if not ScriptDocument then
                    error("Failed to get the open `ScriptDocument` object to edit source, was the script disallowed from opening?", 0)
                end

                local DidEdit, EditTextErrorMessage = ScriptDocument:EditTextAsync(EscapedScript, 1, 1, 1, #EscapedScript)

                if DidEdit then
                    Log("Added full output to script", 2)
                elseif EditTextErrorMessage then
                    error("`ScriptDocument:EditTextAsync` error: " .. EditTextErrorMessage, 0)
                end
            end
        end)

        if not CreateScriptOk and ErrorMessage then
            Log("Failed to open script due to error: \"" .. ErrorMessage .. "\"", 2)
        end
    end

    -- Sadly, the `plugin:PromptSaveSelection` API doesn't really allow for any custom extension
    -- trickery like ".client.lua" or ".server.lua", so we just have to deal with that I guess..
    local function SaveScript()
        local ScriptToSave = SelectedScript:get()

        if not ScriptToSave then
            return
        end

        Log("Attempting to save file: \"" .. ScriptToSave.Name .. ".lua\"")

        -- This call yields btw
        local DidSave = plugin:PromptSaveSelection(ScriptToSave.Name)

        if DidSave then
            Log("Successfully saved to disk", 2)
        else
            Log("Failed to save, prompt failed/cancelled", 2)
        end
    end

    -- We need to always keep track of if there's a script selected. For best measure,
    -- let's initialize the observer right now
    Observer(CurrentSelection):onChange(function()
        local SelectionFromState = CurrentSelection:get()

        -- The save selection functionality should only have a single script selected
        if #SelectionFromState == 1 then
            local SelectionObject = SelectionFromState[1]

            local CallOk, IsASaveableScript = pcall(function()
                return if SelectionObject:IsA("LuaSourceContainer") and #SelectionObject:GetChildren() == 0 then true else false
            end)

            if CallOk and IsASaveableScript then
                SelectedScript:set(SelectionObject)
                return
            end
        end

        -- Fallback to no script selected
        SelectedScript:set(nil)
    end)

    -- SelectionChanged listener
    Selection.SelectionChanged:Connect(function()
        CurrentSelection:set(Selection:Get()) -- For the UI to know that there is/isn't currently a selection
    end)

    -- Context menu for the console menu, we'll provide this to the console component to run later
    local ConsoleContextMenu do
        ConsoleContextMenu = plugin:CreatePluginMenu("MauiConsoleContextMenu", "Maui Console Context Menu")

        local ClearConsoleAction = ConsoleContextMenu:AddNewAction("MauiConsoleContextMenuClearConsole", "Clear Console")
        ClearConsoleAction.Triggered:Connect(function()
            ConsoleOutput:set("")
        end)

        local ReloadConsoleAction = ConsoleContextMenu:AddNewAction("MauiConsoleContextMenuReloadConsole", "Reload Console")
        ReloadConsoleAction.Triggered:Connect(function()
            ConsoleOutput:set(DEFAULT_CONSOLE_TEXT)
        end)

        local ToggleAutoscrollAction = ConsoleContextMenu:AddNewAction("MauiConsoleContextMenuToggleAutoscroll", "Toggle Autoscroll")
        ToggleAutoscrollAction.Triggered:Connect(function()
            local NewStatus = not AutoScrollEnabled:get()

            AutoScrollEnabled:set(NewStatus)
            PluginSettings.Set("ConsoleAutoscroll", NewStatus)
        end)
    end

    -- Assemble the interface with the button and console components
    New "Frame" {
        Name = "Window",
        Parent = pluginWidget,

        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,

        [Children] = {
            Console {
                Text = ConsoleOutput,
                Position = UDim2.fromOffset(12, 12),
                Size = UDim2.new(1, -24, 1, -24 - 24 - 12), -- Make sure to account for the control bar!
                AutoScrollEnabled = AutoScrollEnabled,
                RightClickContextMenu = ConsoleContextMenu
            },

            -- Control bar w/ buttons
            New "Frame" {
                Name = "ControlBar",

                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, -12),
                Size = UDim2.new(1, 0, 0, 24),

                BackgroundTransparency = 1,

                [Children] = {
                    New "UIListLayout" {
                        Padding = UDim.new(0, 6),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    },

                    -- Build & open new script
                    Button {
                        Text = "Build",
                        Enabled = Computed(function()
                            return #CurrentSelection:get() >= 1
                        end),
                        OnClick = Build,
                        LayoutOrder = 1
                    },

                    -- Save script (selection) to file
                    Button {
                        Text = "Save",
                        Enabled = Computed(function()
                            return SelectedScript:get() ~= nil
                        end),
                        OnClick = SaveScript,
                        LayoutOrder = 1
                    }
                }
            }
        }
    }
end
