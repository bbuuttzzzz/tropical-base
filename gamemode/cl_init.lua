MySelf = MySelf or NULL
hook.Add("InitPostEntity", "GetLocal", function()
	MySelf = LocalPlayer()

	GAMEMODE.HookGetLocal = GAMEMODE.HookGetLocal or function(g) end
	gamemode.Call("HookGetLocal", MySelf)
	RunConsoleCommand("initpostentity")

end)

include("cl_includes.lua")
include("sh_includes.lua")


function GM:SpawnMenuEnabled()
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:ContextMenuOpen()
	return false
end

function GM:ShouldDraw2DWeaponHUD()
	return true
end

-- Scales the screen based around 1080p but doesn't make things TOO tiny on low resolutions.
function BetterScreenScale()
	return math.max(ScrH() / 1080, 0.851) * GAMEMODE.InterfaceSize
end

function GM:Initialize()
	self:InitializeAmmo()
end
