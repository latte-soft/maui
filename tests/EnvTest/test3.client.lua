local function f()
    print("test 3: " .. tostring(getfenv(0)) ..  ", " .. tostring(getfenv(1)))
end

f()
