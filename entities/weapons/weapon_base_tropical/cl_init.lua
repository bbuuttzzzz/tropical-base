include("shared.lua")

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = true
SWEP.BobScale = 1
SWEP.SwayScale = 1


function SWEP:Deploy()
	return true
end

function SWEP:PreDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(0)
	end
end

function SWEP:PostDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(1)
	end
end

local colBG = Color(16, 16, 16, 90)
local colRed = Color(220, 0, 0, 230)
local colYellow = Color(220, 220, 0, 230)
local colWhite = Color(220, 220, 220, 230)
local colAmmo = Color(255, 255, 255, 230)
local colSpare = colWhite
local function UpdateAmmoColor(clip, maxclip)
	if clip == 0 then
		colAmmo.r = 255 colAmmo.g = 0 colAmmo.b = 0
	else
		local sat = clip / maxclip
		colAmmo.r = 255
		colAmmo.g = sat ^ 0.3 * 255
		colAmmo.b = sat * 255
	end
end
local function UpdatSpareAmmoColor(spare, maxclip)
	colSpare = (spare == 0 and colRed or spare <= maxclip and colYellow or colWhite)
end

function SWEP:Draw2DHUD()
	local screenscale = BetterScreenScale()

	local wid, hei = 180 * screenscale, 64 * screenscale
	local x, y = ScrW() - wid - screenscale * 128, ScrH() - hei - screenscale * 72
	local clip = self:Clip1()
	local spare = self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
	local maxclip = self.Primary.ClipSize


	draw.RoundedBox(16, x, y, wid, hei, colBG)

	local displayspare = maxclip > 0 and self.Primary.DefaultClip ~= 99999
	if displayspare then
		UpdateAmmoColor(spare, maxclip)
		draw.SimpleText( spare, "DermaDefault", x + wid * 0.75, y + hei * 0.5, colSpare, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	UpdateAmmoColor(clip, maxclip)
	draw.SimpleText( spare, "DermaDefault", x + wid * (displayspare and 0.25 or 0.5), y + hei * 0.5, colAmmo, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function SWEP:Think()
	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end

		return
	elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(self.IdleActivity)
	end
end

local ghostlerp = 0
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	if self:GetOwner():GetBarricadeGhosting() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 5)
	end

	if ghostlerp > 0 then
		pos = pos + 3.5 * ghostlerp * ang:Up()
		ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
	end

	return pos, ang
end

/*
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
*/

function SWEP:DrawHUD()
	self:DrawWeaponCrosshair()

	--[[
	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:Draw2DHUD()
	end
	]]
end
