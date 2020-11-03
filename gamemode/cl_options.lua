GM.InterfaceSize = math.Clamp(CreateClientConVar("al_interfacesize", 1, true, false):GetFloat(), 0.7, 1.5)
cvars.AddChangeCallback("al_interfacesize", function(cvar, oldvalue, newvalue)

end)
