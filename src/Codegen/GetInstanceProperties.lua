--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the LGPLv3 | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/Codegen/InstanceProperties.lua
    Desc: Gets the latest API dump from Max's repo via HttpService, then parses each
    class entry to get the properties of each class, respecting all inheritance
]]

local HttpService = game:GetService("HttpService")

local CONFIG = {
    ApiDumpUrl = "https://github.com/MaximumADHD/Roblox-Client-Tracker/raw/roblox/Mini-API-Dump.json",
    HttpMaxRetryAttempts = 5,
    HttpRetryDelay = 5,
    CacheDelay = 60 * 60 * 1.5 -- 1h30m
}

-- The API dump isn't 100% reliable, and we don't want to encode any properties
-- that are really just aliases of another. This is NOT all of the props you need to respect
-- for *input*, just actually reading an object would be useful to respect these
local WhitelistedProperties = {
    Instance = {"Archivable"},
    BallSocketConstraint = {"MaxFrictionTorque"},
    BasePart = {"Size", "Color", "MaterialVariant"},
    Fire = {"Heat", "Size"},
    LocalizationTable = {"Root"},
    Part = {"Shape"},
    TrussPart = {"Style"},
    Smoke = {"Opacity", "RiseVelocity", "Size"},
    Sound = {"RollOffMaxDistance", "RollOffMinDistance"},
    WeldConstraint = {"Enabled", "Part0", "Part1"}
}

local BlacklistedProperties = {}

-- Cache the current API dump for however long (`CONFIG.CacheDelay`)
local CurrentApiDump, ApiDumpLastFetched

local function GetApiDump(_currentRetryCount)
    -- Check if there's a cached API dump
    if CurrentApiDump and ApiDumpLastFetched and tick() - ApiDumpLastFetched < CONFIG.CacheDelay then
        return CurrentApiDump, true -- The `true` means it returned a cached dump
    end

    -- For the HTTP retry delay sys
    _currentRetryCount = _currentRetryCount or 0

    if _currentRetryCount > CONFIG.HttpMaxRetryAttempts then
        -- Signal back that it couldn't be found!
        return nil, false
    end

    local ResponseOk, ApiDumpResponse = pcall(HttpService.GetAsync, HttpService, CONFIG.ApiDumpUrl)

    if not ResponseOk then -- Then `ApiDumpResponse` is the error message
        _currentRetryCount += 1

        if _currentRetryCount >= CONFIG.HttpMaxRetryAttempts then
            -- Signal back that it couldn't be found
            return nil, false
        else
            warn(string.format(
                "Maui: Failed to get API dump: HTTP Error (%d retries so far, maximum: %d)\nError: \"%s\"",
                _currentRetryCount,
                CONFIG.HttpMaxRetryAttempts,
                ApiDumpResponse or "[No error message attached]"
            ))

            -- Delay, run `GetApiDump` again, make sure to attach times
            return task.delay(
                CONFIG.HttpRetryDelay,
                GetApiDump,
                _currentRetryCount
            )
        end
    end

    local ApiDumpJson = HttpService:JSONDecode(ApiDumpResponse)

    -- Set the cached dump & current time
    CurrentApiDump = ApiDumpJson
    ApiDumpLastFetched = tick()

    return ApiDumpJson, false
end

local function GetInstanceProperties(propertyOverrides)
    local ApiDump, WasCached = GetApiDump()

    if not ApiDump then
        error("Maui: Failed to get API dump: No value returned", 0)
    end

    -- Check API dump format version
    if ApiDump.Version ~= 1 then
        warn(string.format(
            "Maui: Failed to get API Dump: Format version incorrect; expected %d, got %s\nYou may need to update Maui for the latest format support",
            1,
            tostring(ApiDump.Version) -- JIC it's not actually a number, just get the raw val
        ))

        return nil, WasCached
    end

    -- All instance properties will be placed here
    local InstanceProperties = {} do
        -- First, we'll get each class's individual properties, and later after we track
        -- all inherited superclasses, we'll set them to `InstanceProperties`
        local IndividualInstanceProperties = {}

        -- Track all inherited super-classes on classes for later
        local InheritedClassBindings = {} -- [ClassName] = {...}

        -- Loop through all classes and set props in index order. This only get's a class's
        -- OWN properties for now, inheritance will be handled next
        for _, ClassObject in ApiDump.Classes do
            local Properties = {}
            local ClassName = ClassObject.Name

            local ClassWhitelistedProperties = WhitelistedProperties[ClassName]
            local ClassBlacklistedProperties = BlacklistedProperties[ClassName]

            -- The .maui project file inputted property overrides, if given
            local ClassWhitelistedOverrides = propertyOverrides and propertyOverrides.Whitelist[ClassName]
            local ClassBlacklistedOverrides = propertyOverrides and propertyOverrides.Blacklist[ClassName]

            -- Assign inherited classes (again, for later!)
            if ClassObject.Superclass ~= "<<<ROOT>>>" then
                local InheritedClasses = {ClassObject.Superclass}

                local SuperClassInheritedClasses = InheritedClassBindings[ClassObject.Superclass]
                if SuperClassInheritedClasses then
                    for _, ClassName in SuperClassInheritedClasses do
                        table.insert(InheritedClasses, ClassName)
                    end
                end

                InheritedClassBindings[ClassObject.Name] = InheritedClasses
            end

            -- Go through prop members of the current class now
            for _, MemberObject in ClassObject.Members do
                local PropertyName = MemberObject.Name

                if (ClassBlacklistedProperties and table.find(ClassBlacklistedProperties, PropertyName)) or (ClassBlacklistedOverrides and table.find(ClassBlacklistedOverrides, PropertyName)) then
                    continue
                end

                -- It isn't always a property, and we may need to check whitelisted props too
                if MemberObject.MemberType == "Property" and ((MemberObject.Serialization and MemberObject.Serialization.CanSave) or (ClassWhitelistedProperties and table.find(ClassWhitelistedProperties, PropertyName)) or (ClassWhitelistedOverrides and table.find(ClassWhitelistedOverrides, PropertyName))) then
                    table.insert(Properties, MemberObject.Name)
                end
            end

            IndividualInstanceProperties[ClassObject.Name] = Properties
        end

        -- Now, we'll bind all inherited properties for classes
        for ClassName, InheritedClasses in InheritedClassBindings do
            -- Shallow-clone the known individual properties
            local ClassInstanceProperties = table.clone(IndividualInstanceProperties[ClassName])

            -- We now need to go through EVERY inherited class and get each property of those classes
            for _, InheritedClass in InheritedClasses do
                for _, PropertyName in IndividualInstanceProperties[InheritedClass] do
                    table.insert(ClassInstanceProperties, PropertyName)
                end
            end

            InstanceProperties[ClassName] = ClassInstanceProperties
        end
    end

    return InstanceProperties, WasCached
end

return GetInstanceProperties
