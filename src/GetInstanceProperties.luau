--[[
    Maui - Roblox Studio Plugin for Packing Modules as Executable Luau Scripts
    Licensed Under the MIT License | Copyright (c) 2022-2023 Latte Softworks <latte.to>
    https://github.com/latte-soft/maui

    File: /src/Codegen/InstanceProperties.lua
    Desc: Gets the latest full API dump from Max's repo via HttpService, then parses each
    class entry to get the properties of each class, respecting all inheritance
]]

local HttpService = game:GetService("HttpService")

local Config = {
    ApiDumpUrl = "https://github.com/MaximumADHD/Roblox-Client-Tracker/raw/roblox/Full-API-Dump.json",
    HttpMaxRetryAttempts = 5,
    HttpRetryDelay = 5,
    CacheDelay = 60 * 60 * 1.5 -- 1h30m
}

-- Cache the current API dump for however long (`Config.CacheDelay`)
local CurrentApiDump, ApiDumpLastFetched

local function GetApiDump(_currentRetryCount)
    -- Check if there's a cached API dump
    if CurrentApiDump and ApiDumpLastFetched and tick() - ApiDumpLastFetched < Config.CacheDelay then
        return CurrentApiDump, true -- The `true` means it returned a cached dump
    end

    -- For the HTTP retry delay sys
    _currentRetryCount = _currentRetryCount or 0

    if _currentRetryCount > Config.HttpMaxRetryAttempts then
        -- Signal back that it couldn't be found!
        return nil, false
    end

    local ResponseOk, ApiDumpResponse = pcall(HttpService.GetAsync, HttpService, Config.ApiDumpUrl)

    if not ResponseOk then -- Then `ApiDumpResponse` is the error message
        _currentRetryCount += 1

        if _currentRetryCount >= Config.HttpMaxRetryAttempts then
            -- Signal back that it couldn't be found
            return nil, false
        else
            warn(`Maui: Failed to get API dump: HTTP Error ({_currentRetryCount} retries so far, maximum: {Config.HttpMaxRetryAttempts})\nError: "{ApiDumpResponse or "[No error message attached]"}"`)

            -- Delay, run `GetApiDump` again, make sure to attach times
            return task.delay(
                Config.HttpRetryDelay,
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
        warn(`Maui: Failed to get API Dump: Format version incorrect; expected 1, got "{ApiDump.Version}"\nYou may need to update Maui for the latest format support`)

        return nil, WasCached
    end

    local InstanceProperties = {}
    local IndividualInstanceProperties = {}
    local InheritedClassBindings = {}

    for _, ClassObject in ApiDump.Classes do
        local Properties = {}

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

        for _, MemberObject in ClassObject.Members do
            -- We can now respect serialization tags with the full api dump
            if MemberObject.MemberType == "Property" and (MemberObject.Serialization and MemberObject.Serialization.CanSave and MemberObject.Serialization.CanLoad) then
                table.insert(Properties, MemberObject.Name)
            end
        end

        IndividualInstanceProperties[ClassObject.Name] = Properties
    end

    for ClassName, InheritedClasses in InheritedClassBindings do
        local ClassInstanceProperties = table.clone(IndividualInstanceProperties[ClassName])

        for _, InheritedClass in InheritedClasses do
            for _, PropertyName in IndividualInstanceProperties[InheritedClass] do
                table.insert(ClassInstanceProperties, PropertyName)
            end
        end

        InstanceProperties[ClassName] = ClassInstanceProperties
    end

    return InstanceProperties, WasCached
end

return GetInstanceProperties
