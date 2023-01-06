local Ok, FunctionEnvironment = pcall(getfenv, 2)
print("`getfenv(2)` status (should be an error): " .. tostring(FunctionEnvironment))