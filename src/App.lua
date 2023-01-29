--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
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

-- Default options for the `.maui` format, assign a "Nil" marker for use later aswell
local Nil = newproxy()
local DEFAULT_OPTIONS = {
    FormatVersion = 1, -- Isn't necessary in the project file, but just for future proofing the format incase we ever change anything

    -- All output options
    Output = {
        Directory = Nil, -- A string/function/instance (supports all) denoting/returning a specific output path in the DataModel, and a string of the filename
        ScriptName = Nil, -- The actual name of the output script object, e.g. "SomeScript"
        ScriptType = "LocalScript", -- Accepts "LocalScript", "Script", and "ModuleScript"

        MinifyTable = false, -- If the codegen table itself (made from LuaEncode) is to be minified
        UseMinifiedLoader = true -- Use the pre-minified LoadModule script in the codegen, which is always predefined and not useful for debugging
    },

    -- "Fast-Flags" to be respected at runtime
    Flags = {
        ContextualExecution = true, -- If client/server context should be checked at runtime, and ignores LuaSourceContainer.Disabled (e.g. LocalScripts only run on the client, Scripts only run on the server)
        ReturnMainModule = true -- **If applicable**, return the contents of a "MainModule"-named ModuleScript from the root of the model. This behaves exactly like Roblox's MainModule system
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

-- To give a closure a script global of choice
local function GiveClosureScriptGlobal(closureToSet, scriptGlobal)
    local RealEnvironment = getfenv(0)
    local GlobalEnvironmentOverride = {
        ["script"] = scriptGlobal
    }

    -- Took this from the codegen's handler, works perfectly
    local VirtualEnvironment
    VirtualEnvironment = setmetatable({}, {
        __index = function(_, index)
            local IndexInVirtualEnvironment = rawget(VirtualEnvironment, index)
            if IndexInVirtualEnvironment ~= nil then
                return IndexInVirtualEnvironment
            end

            local IndexInGlobalEnvironmentOverride = GlobalEnvironmentOverride[index]
            if IndexInGlobalEnvironmentOverride ~= nil then
                return IndexInGlobalEnvironmentOverride
            end

            return RealEnvironment[index]
        end
    })

    setfenv(closureToSet, VirtualEnvironment)
    return closureToSet
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
        local Options = DeepClone(DEFAULT_OPTIONS)
        local MauiProjectFileModule = FirstObjectSelected:FindFirstChild(".maui")

        if MauiProjectFileModule then
            local ApplyOptionsSuccess, ApplyOptionsErrorMessage = pcall(function()
                Log("Reading `.maui` project file..")

                -- Try to read and parse project format; we're using `loadstring()` because of `require()` caching..
                local MauiProjectFileClosure, MauiProjectFileCompileError = loadstring(MauiProjectFileModule.Source)

                if MauiProjectFileClosure == nil and MauiProjectFileCompileError then
                    error("Error compiling project file: " .. MauiProjectFileCompileError, 0)
                end

                GiveClosureScriptGlobal(MauiProjectFileClosure, MauiProjectFileModule)
                local MauiProjectFile = MauiProjectFileClosure()

                if type(MauiProjectFile) ~= "table" then
                    error("`.maui` project file given isn't a valid Lua/JSON module, failed to parse.", 0)
                end

                -- All output options that could be specified
                local FormatVersion = MauiProjectFile["FormatVersion"]
                local Output = MauiProjectFile["Output"]
                local Flags = MauiProjectFile["Flags"]
                local Properties = MauiProjectFile["Properties"]

                if FormatVersion ~= nil and FormatVersion ~= 1 then
                    error("Invalid format version in `.maui` project file; expected 1, got " .. tostring(MauiProjectFile.FormatVersion, 0))
                end

                -- Replace all eligable options for output
                if Output ~= nil then
                    local OutputType = type(Output)
                    if OutputType ~= "table" then
                        error("Invalid DataType for `Output` in project file; expected \"table\", got \"" .. OutputType .. "\"", 0)
                    end

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
                                error("Invalid output option \"" .. tostring(Key) .. "\" in project file, did you make a typo?", 0)
                            end
                        end
                    end

                    RecursiveAddOptions(Options.Output, MauiProjectFile.Output)
                end

                if Flags ~= nil then
                    local FlagsType = type(Flags)
                    if FlagsType ~= "table" then
                        error("Invalid DataType for `Flags` in project file; expected \"table\", got \"" .. FlagsType .. "\"", 0)
                    end

                    local RealFlags = Options.Flags

                    -- It's only to be 1 stack of values, so only 1 shallow loop
                    for Key, NewValue in Flags do
                        if type(NewValue) == "table" then
                            error("No nested tables are allowed for `Flags` in the project file, can't set \"" .. tostring(Key) .. "\"", 0)
                        else
                            RealFlags[Key] = NewValue
                        end
                    end
                end

                -- Handle custom property overrides
                if Properties ~= nil then
                    local PropertiesType = type(Properties)
                    if PropertiesType ~= "table" then
                        error("Invalid DataType for `Properties` in project file; expected \"table\", got \"" .. PropertiesType .. "\"", 0)
                    end

                    local Whitelist = Properties["Whitelist"]
                    local Blacklist = Properties["Blacklist"]

                    if type(Whitelist) == "table" then
                        local RealWhitelist = Options.Properties.Whitelist

                        for ClassName, ClassProperties in Whitelist do
                            RealWhitelist[ClassName] = ClassProperties
                        end
                    end

                    if type(Blacklist) == "table" then
                        local RealBlacklist = Options.Properties.Blacklist

                        for ClassName, ClassProperties in Blacklist do
                            RealBlacklist[ClassName] = ClassProperties
                        end
                    end
                end
            end)

            if not ApplyOptionsSuccess and ApplyOptionsErrorMessage then
                Log("Error applying options from project file: \"" .. ApplyOptionsErrorMessage .. "\"")
                return
            end
        end

        -- Make the first object in the selection (USUALLY the only) the name of the outputted script, just
        -- so we can have something to base off of. We'll remove all ctrl chars, spaces, and periods from this
        -- string, so it's a little more friendly for the explorer. We'll also truncate to 50 characters
        local ScriptName, UsingCustomScriptName do
            -- This will just be "nil" if it doesn't exist, so no check
            local ScriptNameInOptions = Options.Output.ScriptName
            local ScriptNameInOptionsType = type(Options.Output.ScriptName)

            if ScriptNameInOptionsType == "string" then
                ScriptName = ScriptNameInOptions
                UsingCustomScriptName = true
            elseif ScriptNameInOptions ~= nil and ScriptNameInOptions ~= Nil then
                -- ^^ We'll just handle if it's provided, but not a str (would've passed above check if it were provided and was a str)
                Log("Invalid type for `Options.Output.ScriptName`; expected \"string\", got \"" .. ScriptNameInOptionsType .. "\"", 2)
                return
            else
                ScriptName = FirstObjectSelected.Name:sub(1, 50):gsub("[\0-\31\127-\255]", ""):gsub("[\32%.]", "_")
                UsingCustomScriptName = false
            end
        end

        Log("Attempting to build script \"" .. ScriptName .. "\"")

        -- Pass through the log function aswell, for detailed steps of what the assembler is actually doing
        local DidBuild, GeneratedScriptOrError = pcall(Codegen.BuildFromSelection, SelectionToBuild, Log, Options, MauiProjectFileModule)

        if not DidBuild then
            Log("Failed to build due to error: \"" .. GeneratedScriptOrError or "[No error message attached]" .. "\"", 2)
            return
        end

        Log("Successfully built, opening..", 2)

        local Directory do
            local DirectoryInOptions = Options.Output.Directory
            local DirectoryInOptionsTypeOf = typeof(Options.Output.Directory)

            -- So we aren't writing the same code twice.. (Since Options.Output.Directory respects both strings and funcs)
            local function GetDirectoryFromFunction(functionToCall)
                local ExpectedReturnPath = functionToCall()
                local ExpectedReturnPathTypeOf = typeof(ExpectedReturnPath)

                if ExpectedReturnPathTypeOf ~= "Instance" then
                    Log("Invalid return type for `Options.Output.Directory`; expected \"string\", got \"" .. ExpectedReturnPathTypeOf .. "\"", 2)
                    return
                end

                return ExpectedReturnPath
            end

            if DirectoryInOptionsTypeOf == "Instance" then
                Directory = DirectoryInOptions
            elseif DirectoryInOptionsTypeOf == "string" then
                -- We're expecting strings of this option to be literal Lua code that returns the path to use
                local DirectoryReturnClosure, ErrorMessage = loadstring(DirectoryInOptions)

                if not DirectoryReturnClosure and ErrorMessage then
                    Log("Expected valid Lua code for `Options.Output.Directory` (since a string was provided), but there was an error in loadstring: \"" .. ErrorMessage .. "\"", 2)
                    return
                end

                GiveClosureScriptGlobal(DirectoryReturnClosure, MauiProjectFileModule)

                Directory = GetDirectoryFromFunction(DirectoryReturnClosure)
                if not Directory then
                    return
                end
            elseif DirectoryInOptionsTypeOf == "function" then
                Directory = GetDirectoryFromFunction(DirectoryInOptions)
                if not Directory then
                    return
                end
            elseif DirectoryInOptions ~= nil and DirectoryInOptions ~= Nil then
                Log("Invalid type for `Options.Output.Directory`; expected \"string\", got \"" .. DirectoryInOptionsTypeOf .. "\"", 2)
                return
            else
                -- ServerStorage["Maui | Built Scripts"]
                local MauiScriptsFolder = ServerStorage:FindFirstChild("Maui | Built Scripts")
                if not MauiScriptsFolder then
                    MauiScriptsFolder = Instance.new("Folder")
                    MauiScriptsFolder.Name = "Maui | Built Scripts"
                    MauiScriptsFolder.Parent = ServerStorage
                end

                -- ServerStorage["Maui | Built Scripts"][ScriptName]
                Directory = MauiScriptsFolder:FindFirstChild(ScriptName)
                if not Directory then
                    Directory = Instance.new("Folder")
                    Directory.Name = ScriptName
                    Directory.Parent = MauiScriptsFolder
                end
            end
        end

        -- Studio may prompt the user to give the plugin access to writing `Script.Source`, it
        -- doesn't just yield and set it when they click "Allow", we have to do it again outselves
        -- ALSO, setting this property can err if the str is too long (yay!)
        local CreateScriptOk, ErrorMessage = pcall(function()
            local ScriptType = Options.Output.ScriptType

            -- Check Options.ScriptType first
            if not table.find({"LocalScript", "Script", "ModuleScript"}, ScriptType) then
                Log("Invalid ScriptType for `Options.ScriptType` in project file; expected LocalScript/Script/ModuleScript, got: \"" .. ScriptType .. "\"", 3)
                return
            end

            -- Create/find the real script obj
            local ScriptObject
            if UsingCustomScriptName then
                ScriptObject = Directory:FindFirstChild(ScriptName) or Instance.new(ScriptType)
                ScriptObject.Name = ScriptName
            else
                ScriptObject = Instance.new(ScriptType)

                -- Format the current date-time into the name, just for basic organization for
                -- the user. I'd make it just the epoch time, but just doing this for readability
                ScriptObject.Name = os.date(
                    FirstObjectSelected.Name:sub(1, 50):gsub("[\0-\31\127-\255]", ""):gsub("[\32%.]", "_") .. "_%Y%m%d_%H%M%S"
                )
            end

            ScriptObject.Parent = Directory
            Selection:Set({ScriptObject}) -- Select the script object for the "Save" button feature

            Log("Adding output..", 2)

            -- Setting LuaSourceContainer.Source with 200k chars or more gives us an error, if it isn't,
            -- we'll use our other method
            if #GeneratedScriptOrError < 200000 then
                ScriptObject.Source = GeneratedScriptOrError
                ScriptEditorService:OpenScriptDocumentAsync(ScriptObject)
            else
                Log("Output too large to set `LuaSourceContainer.Source` directly with, using EditTextAsync method..", 2)

                -- Yes, this is VERY HACKY, but we have to do this instead due to `Script.Source`'s internal
                -- __newindex set limit. We have to escape all "invalid" unicode from strings in the script,
                -- or `ScriptDocument:EditTextAsync` will error with a cryptic message to the user
                pcall(function()
                    ScriptObject.Source = INITIAL_OUTPUT_TEXT
                end)

                ScriptEditorService:OpenScriptDocumentAsync(ScriptObject)
                local ScriptDocument = ScriptEditorService:FindScriptDocument(ScriptObject)
                if not ScriptDocument then
                    error("Failed to get the open `ScriptDocument` object to edit source, was the script disallowed from opening?", 0)
                end

                local EscapedScript = EscapeUnicode(GeneratedScriptOrError)

                local DidEdit, EditTextErrorMessage = ScriptDocument:EditTextAsync(EscapedScript, 1, 1, 1, #EscapedScript)

                if DidEdit then
                    Log("Added full output to script from EditTextAsync", 3)
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
