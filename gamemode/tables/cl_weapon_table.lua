local meta = FindMetaTable("Weapon")

function meta:DrawWeaponCrosshair()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end

	DrawCrosshairCircle(self:GetCone())
	self:DrawCrosshairDot()
end

local ironsightscrosshair = CreateClientConVar("zs_ironsightscrosshair", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_ironsightscrosshair", function(cvar, oldvalue, newvalue)
	ironsightscrosshair = tonumber(newvalue) == 1
end)

local baserot = 0
function meta:DrawCrosshairCircle()
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5

	local cone = self:GetCone()

	if cone <= 0 then return end

	--cone = ScrH() / 76.8 * cone
	cone = ScrH() * 0.0003125 * cone
	cone = cone * 90 / MySelf:GetFOV()

	--CrossHairScale = cone --math.Approach(CrossHairScale, cone, FrameTime() * math.max(5, math.abs(CrossHairScale - cone) * 0.02))

	local radius = 40 * cone --CrossHairScale

	local vel = MySelf:GetVelocity()
	local len = vel:LengthSqr()
	vel:Normalize()

	local thickness = 1

	surface.DrawCircle( x, y, radius, MySelf:GetCrosshairColor())
end

function meta:DrawCrosshairDot()
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5
	local thickness = 0.5
	local size = 4 * thickness
	local hsize = size/2

	surface.SetDrawColor(MySelf:GetCrosshairColor())
	surface.DrawRect(x - hsize, y - hsize, size, size)
	surface.SetDrawColor(0, 0, 0, 1)
	surface.DrawOutlinedRect(x - hsize, y - hsize, size, size)

	if GAMEMODE.LastOTSBlocked and MySelf:Team() == TEAM_HUMAN and GAMEMODE:UseOverTheShoulder() then
		GAMEMODE:DrawCircle(x, y, 8, COLOR_RED)
	end
end

function meta:DrawCrosshairTicks()

end

local matScope = Material("zombiesurvival/scope")
function meta:DrawRegularScope()
	local scrw, scrh = ScrW(), ScrH()
	local size = math.min(scrw, scrh)
	surface.SetMaterial(matScope)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, size)
	surface.SetDrawColor(0, 0, 0, 255)
	if scrw > size then
		local extra = (scrw - size) * 0.5
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end
	if scrh > size then
		local extra = (scrh - size) * 0.5
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end
end

local texGradientU = Material("vgui/gradient-u")
local texGradientD = Material("vgui/gradient-d")
local texGradientR = Material("vgui/gradient-r")
function meta:DrawFuturisticScope()
	local scrw, scrh = ScrW(), ScrH()
	local size = math.min(scrw, scrh)
	local hw,hh = scrw * 0.5, scrh * 0.5
	local screenscale = BetterScreenScale()
	local gradsize = math.ceil(size * 0.14)
	local line = 38 * screenscale

	for i=0,6 do
		local rectsize = math.floor(screenscale * 44) + i * math.floor(130 * screenscale)
		local hrectsize = rectsize * 0.5
		surface.SetDrawColor(0,145,255,math.max(35,25 + i * 30)/2)
		surface.DrawOutlinedRect(hw-hrectsize,hh-hrectsize,rectsize,rectsize)
	end
	if scrw > size then
		local extra = (scrw - size) * 0.5
		for i=0,12 do
			surface.SetDrawColor(0,145,255, math.max(10,255 - i * 21.25)/2)
			surface.DrawLine(hw,i*line,hw,i*line+line)
			surface.DrawLine(hw,scrh-i*line,hw,scrh-i*line-line)
			surface.DrawLine(i*line+extra,hh,i*line+line+extra,hh)
			surface.DrawLine(scrw-i*line-extra,hh,scrw-i*line-line-extra,hh)
		end
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end
	if scrh > size then
		local extra = (scrh - size) * 0.5
		for i=0,12 do
			surface.SetDrawColor(0,145,255, math.max(10,255 - i * 21.25)/2)
			surface.DrawLine(hw,i*line+extra,hw,i*line+line+extra)
			surface.DrawLine(hw,scrh-i*line-extra,hw,scrh-i*line-line-extra)
			surface.DrawLine(i*line,hh,i*line+line,hh)
			surface.DrawLine(scrw-i*line,hh,scrw-i*line-line,hh)
		end
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end

	surface.SetMaterial(texGradientU)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, gradsize)
	surface.SetMaterial(texGradientD)
	surface.DrawTexturedRect((scrw - size) * 0.5, scrh - (scrh - size) * 0.5 - gradsize, size, gradsize)
	surface.SetMaterial(texGradientR)
	surface.DrawTexturedRect(scrw - (scrw - size) * 0.5 - gradsize, (scrh - size) * 0.5, gradsize, size)
	surface.DrawTexturedRectRotated((scrw - size) * 0.5 + gradsize / 2, (scrh - size) * 0.5 + size / 2, gradsize, size, 180)
end

function meta:BaseDrawWeaponSelection(x, y, wide, tall, alpha)
	local ammotype1 = self:ValidPrimaryAmmo()
	local ammotype2 = self:ValidSecondaryAmmo()

	--killicon.Draw(x + wide * 0.5, y + tall * 0.5, self:GetClass(), 255)
	-- Doesn't work with pngs...
	local ki = killicon.Get(self:GetClass())
	local cols = ki and ki[#ki] or ""

	if ki and #ki == 3 then
		draw.SimpleText(ki[2], ki[1] .. "ws", x + wide * 0.5, y + tall * 0.5 + 18 * BetterScreenScale(), Color(cols.r, cols.g, cols.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ki then
		local material = Material(ki[1])
		local wid, hei = material:Width(), material:Height()

		surface.SetMaterial(material)
		surface.SetDrawColor(cols.r, cols.g, cols.b, alpha )
		surface.DrawTexturedRect(x + wide * 0.5 - wid * 0.5, y + tall * 0.5 - hei * 0.5, wid, hei)
	end

	draw.SimpleTextBlur(self:GetPrintName(), "ZSHUDFontSmaller", x + wide * 0.5, y + tall * 0.15, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if ammotype1 then
		local total = self:GetPrimaryAmmoCount()
		local inclip = self:Clip1()
		if inclip >= 0 then
			if self.Primary and self.Primary.ClipSize and self.Primary.ClipSize == 1 then
				draw.SimpleTextBlur("["..total.."]", "ZSHUDFontSmaller", x + wide * 0.05, y + tall * 0.8, total == 0 and COLOR_RED or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM_REAL)
			else
				draw.SimpleTextBlur("["..inclip.." / ".. total - inclip .."]", "ZSHUDFontSmaller", x + wide * 0.05, y + tall * 0.8, total == 0 and COLOR_RED or inclip == 0 and COLOR_YELLOW or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM_REAL)
			end
		end
	end

	if ammotype2 then
		local total = self:GetSecondaryAmmoCount()
		local inclip = self:Clip2()
		if inclip >= 0 then
			if self.Secondary and self.Secondary.ClipSize and self.Secondary.ClipSize == 1 then
				draw.SimpleTextBlur("["..total.."]", "ZSHUDFontSmaller", x + wide * 0.95, y + tall * 0.8, total == 0 and COLOR_RED or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM_REAL)
			else
				draw.SimpleTextBlur("["..inclip.." / ".. total - inclip .."]", "ZSHUDFontSmaller", x + wide * 0.95, y + tall * 0.8, total == 0 and COLOR_RED or inclip == 0 and COLOR_YELLOW or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM_REAL)
			end
		end
	end

	return true
end

local function empty() end
function meta:HideWorldModel()
	self:DrawShadow(false)
	self.DrawWorldModel = empty
	self.DrawWorldModelTranslucent = empty
end

local function HiddenViewModel(self, pos, ang)
	return pos + ang:Forward() * -256, ang
end
function meta:HideViewModel()
	self.GetViewModelPosition = HiddenViewModel
end
