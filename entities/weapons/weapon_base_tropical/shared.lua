SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.DryFireSound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Damage = 30
SWEP.Primary.KnockbackScale = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

SWEP.ConeMax = 1.5
SWEP.ConeMin = 0.5
SWEP.ConeRamp = 2

SWEP.CSMuzzleFlashes = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "primary"
SWEP.MaxSpareAmmo = 120

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

SWEP.HoldType = "pistol"

SWEP.Recoil = 0

SWEP.IdleActivity = ACT_VM_IDLE

function SWEP:Initialize()
	if not self:IsValid() then return end --???

	self:SetWeaponHoldType(self.HoldType)
	GAMEMODE:DoChangeDeploySpeed(self)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	self:EmitFireSound()
	self:TakePrimaryAmmo(1)
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, math.rad(self:GetCone()))
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	local owner = self:GetOwner()

	-- Custom reload function to change reload speed.
	if self:CanReload() then
		self.IdleAnimation = CurTime() + self:SequenceDuration()
		self:SetNextReload(self.IdleAnimation)
		self:SetReloadStart(CurTime())

		self:SendReloadAnimation()
		self:ProcessReloadEndTime()

		owner:DoReloadEvent()

		self:EmitReloadSound()
	end
end


function SWEP:FinishReload()
	self:SendWeaponAnim(ACT_VM_IDLE)
	self:SetNextReload(0)
	self:SetReloadStart(0)
	self:SetReloadFinish(0)
	self:EmitReloadFinishSound()

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local max1 = self:GetMaxClip1()
	local max2 = self:GetMaxClip2()

	if max1 > 0 then
		local ammotype = self:GetPrimaryAmmoType()
		local spare = owner:GetAmmoCount(ammotype)
		local current = self:Clip1()
		local needed = max1 - current

		needed = math.min(spare, needed)

		self:SetClip1(current + needed)
		if SERVER then
			owner:RemoveAmmo(needed, ammotype)
		end
	end

	if max2 > 0 then
		local ammotype = self:GetSecondaryAmmoType()
		local spare = owner:GetAmmoCount(ammotype)
		local current = self:Clip2()
		local needed = max2 - current

		needed = math.min(spare, needed)

		self:SetClip2(current + needed)
		if SERVER then
			owner:RemoveAmmo(needed, ammotype)
		end
	end
end

function SWEP:GetCone()
	local owner = self:GetOwner()

	local basecone = self.ConeMin
	local conedelta = self.ConeMax - basecone

	local speedFrac = math.min(owner:GetVelocity():Length() / self:GetWalkSpeed(), 1)
	local multiplier = speedFrac * 0.5

    if not owner:OnGround() then multiplier = multiplier + 0.25 end

	if not owner:Crouching() then multiplier = multiplier + 0.25 end

	return (basecone + conedelta * (multiplier) ^ self.ConeRamp)
end

function SWEP:GetWalkSpeedMultiplier()
	return 1
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound)
end

function SWEP:Deploy()
	self:SetNextReload(0)
	self:SetReloadFinish(0)

	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

function SWEP:Holster()
	if CLIENT then
		self:Anim_Holster()
	end

	return true
end

function SWEP:EmitReloadSound()
	if self.ReloadSound and IsFirstTimePredicted() then
		self:EmitSound(self.ReloadSound, 75, 100, 1, CHAN_WEAPON + 21)
	end
end

function SWEP:EmitReloadFinishSound()
	if self.ReloadFinishSound and IsFirstTimePredicted() then
		self:EmitSound(self.ReloadFinishSound, 75, 100, 1, CHAN_WEAPON + 21)
	end
end

function SWEP:CanReload()
	return not self:GetOwner():IsHolding() and self:GetNextReload() <= CurTime() and self:GetReloadFinish() == 0 and
		(
			self:GetMaxClip1() > 0 and self:Clip1() < self:GetMaxClip1() and self:ValidPrimaryAmmo() and self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) > 0
			or self:GetMaxClip2() > 0 and self:Clip1() < self:GetMaxClip2() and self:ValidSecondaryAmmo() and self:GetOwner():GetAmmoCount(self:GetSecondaryAmmoType()) > 0
		)
end

function SWEP:CanPrimaryAttack()
    if self:GetReloadFinish() > 0 then
        return false
    end

	if self:Clip1() < 1 then
		self:EmitSound(self.DryFireSound)
		self:SetNextPrimaryFire(CurTime() + math.max(0.25, self.Primary.Delay))
		return false
	end

	return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed or 1)
end

function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_RELOAD)
end


function SWEP:ProcessReloadEndTime()
	local reloadspeed = self.ReloadSpeedMultiplier or 1

	self:SetReloadFinish(CurTime() + self:SequenceDuration() / reloadspeed)
	if not self.DontScaleReloadSpeed then
		self:GetOwner():GetViewModel():SetPlaybackRate(reloadspeed)
	end
end

function SWEP:GetFireDelay()
	local owner = self:GetOwner()
	return self.Primary.Delay
end

--[[
shoot numbul bulletes, each dealing dmg damage, in a cone of cone radians
]]
function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()
	if self.Recoil > 0 then
		local r = math.Rand(0.8, 1)
		owner:ViewPunch(Angle(r * -self.Recoil, 0, (1 - r) * (math.random(2) == 1 and -1 or 1) * self.Recoil))
	end

    local bullet = {}
    bullet.Num = numbul
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector( cone, cone, 0)
    bullet.Tracer = self.TracerName
    bullet.Force = self.Primary.KnockbackScale * dmg
    bullet.Damage = dmg

    owner:FireBullets( bullet )
end

local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]      	= ACT_HL2MP_IDLE_DUEL,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA
}

function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ActIndex[ t ]

	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal) (from "..self:GetClass()..")\n" )
		t = "normal"
		index = ActIndex[ t ]
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM_IDLE ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= index+9

	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end

	-- these two aren't defined in ACTs for whatever reason
	if t == "knife" or t == "melee2" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = nil
	end
end

SWEP:SetWeaponHoldType("pistol")

function SWEP:TranslateActivity(act)
	return self.ActivityTranslate and self.ActivityTranslate[act] or -1
end

function SWEP:GetWalkSpeed()
	return self:GetOwner():GetWalkSpeed() * self:GetWalkSpeedMultiplier()
end
