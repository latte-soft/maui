--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/Codegen/GetDefaultInstanceProperty.lua
    Desc: Get the "default" property of a certain instance class, Roblox doesn't provide
    these in the API dump, or as an engine API in general. This is an idea taken from the
    Roact script `getDefaultInstanceProperty.lua`: https://github.com/Roblox/roact/blob/master/src/getDefaultInstanceProperty.lua
]]

-- We'll cache all created instances, and indexed properties
local CachedInstances = {} -- [ClassName] = SomeInstance
local CachedPropertyValues = {} -- [ClassName] = {[PropertyName] = DefaultValue, ...}

-- Like Roact!
local PropertyValueOfNil = newproxy()

-- Returns `DefaultValue`, `PropertyValueIsNil`
local function GetDefaultInstanceProperty(className, propertyToGet)
    local CachedInstance = CachedInstances[className]
    local CachedProperties = CachedPropertyValues[propertyToGet]

    if CachedProperties then
        local PropertyInCache = CachedProperties[propertyToGet]

        -- Like noted in Roact's script, Lua doesn't tell the diff between a value actually being nil, or
        -- just not in a table. We'll use userdata symbols for if the property's default value is ACTUALLY nil
        if PropertyInCache == PropertyValueOfNil then
            return nil, true
        end

        if PropertyInCache ~= nil then
            return PropertyInCache, false
        end
    else
        -- Then add it
        CachedProperties = {}
        CachedPropertyValues[className] = CachedProperties
    end

    -- Get/add cached instance value
    if not CachedInstance then
        local CreatedOk, NewInstance = pcall(Instance.new, className)

        if not CreatedOk then
            return nil, false
        end

        CachedInstance = NewInstance
        CachedInstances[className] = CachedInstance
    end

    local DefaultValue = CachedInstance[propertyToGet]

    -- Add to cache
    if DefaultValue == nil then -- Then the value of the property is ACTUALLY `nil`\
        CachedProperties[propertyToGet] = PropertyValueOfNil
    else
        CachedProperties[propertyToGet] = DefaultValue
    end

    return DefaultValue, if DefaultValue == nil then true else false
end

return GetDefaultInstanceProperty
