local function f()
    local function f2()
        print("test 4 (from a function inside another function); getfenv(0): " .. tostring(getfenv(0)) ..  ", getfenv(1): " .. tostring(getfenv(1)))
    end

    f2()
end

f()
