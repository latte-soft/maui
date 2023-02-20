--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/PluginSettings.lua
    Desc: Handles fairly basic (but convenient!) funcs for getting/setting internal
    plugin settings and configuration
]]

local Config = {
    Key = "MauiSettings",
    DefaultSettings = {
        ConsoleAutoscroll = false
    }
}

-- We need to pass the plugin object THROUGH the module.. yep
return function(plugin)
    -- Setup default settings (if just installed or whatever)
    if not plugin:GetSetting(Config.Key) then
        plugin:SetSetting(Config.Key, Config.DefaultSettings)
    end

    local function Get(settingName)
        local RealSettings = plugin:GetSetting(Config.Key)

        -- Index the tbl with a string recursively to get the value
        local FoundValue = RealSettings do
            for _, KeyName in string.split(settingName, ".") do
                FoundValue = FoundValue[KeyName]
            end
        end

        return FoundValue
    end

    local function Set(settingName, newValue)
        -- Get the real settings first, we can't set the value with the settingName without
        -- knowing it
        local RealSettings = plugin:GetSetting(Config.Key)

        -- Set the desired key with newValue
        local Parent, Key = RealSettings, nil do
            -- Need to pre-define here so we can check if there's a value after the current index
            local SplitPath = string.split(settingName, ".")

            for Index, KeyName in SplitPath do
                Key = KeyName

                -- If there's a key after the current index still, we still want to add the current
                -- index as the parent
                if next(SplitPath, Index) then
                    Parent = Parent[KeyName]
                end
            end
        end

        Parent[Key] = newValue

        -- And we're done!
        plugin:SetSetting(Config.Key, RealSettings) -- We've already modifed `RealSettings` with our new val!
    end

    return {
        Get = Get,
        Set = Set
    }
end
