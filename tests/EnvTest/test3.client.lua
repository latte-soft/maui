local function f()
    print("test 3 (from inside a function); getfenv(0): " .. tostring(getfenv(0)) ..  ", getfenv(1): " .. tostring(getfenv(1)))
end

f()
