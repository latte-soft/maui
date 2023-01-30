local _, FunctionEnvironment = pcall(getfenv, 2)
print("`getfenv(2)` status (should be either an error or the same as getfenv(0/1)): " .. tostring(FunctionEnvironment))