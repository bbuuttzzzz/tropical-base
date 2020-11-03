-- Useful macros for the 3 file system
function INC_SERVER()
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
	include("shared.lua")
end

function INC_CLIENT()
	include("shared.lua")
end
INC_CLIENT_NO_SHARED = INC_CLIENT

function INC_SERVER_NO_SHARED()
	AddCSLuaFile("cl_init.lua")
end

function INC_SERVER_NO_CLIENT()
	AddCSLuaFile("shared.lua")
    include("shared.lua")
end

function GM:DoChangeDeploySpeed(wep)
	if wep:IsValid() and wep.SetDeploySpeed then
		local owner = wep:GetOwner()
		wep:SetDeploySpeed(wep.DeploySpeedMultiplier or 1)
	end
end
