local function f()
    local function f2()
        print("test 4: " .. tostring(getfenv(0)) ..  ", " .. tostring(getfenv(1)))
    end

    f2()
end

f()
