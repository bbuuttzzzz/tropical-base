--[[

Gmod Allstars

]]

// Add files to be downloaded by the client
include("sv_download_files.lua")

// Include files needed by the server
include("sh_includes.lua")
include("sv_includes.lua")

function GM:Initialize()
	self:InitializeAmmo()
end

function GM:PlayerInitialSpawn( pl )

end

function GM:PlayerSpawn( pl )
    pl:StripWeapons()
    pl:RemoveFlags(FL_ONGROUND)

    pl:SetBarricadeGhosting(false)

    if pl:GetMaterial() ~= "" then
		pl:SetMaterial("")
	end
end
