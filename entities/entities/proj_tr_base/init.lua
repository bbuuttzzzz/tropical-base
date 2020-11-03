 --all subclasses must AddCSLuaFile and include
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
  self.DieTime = CurTime() + self.Lifetime

	self:SetModel(self.Model)
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(self.DrawColor)

  local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0.0001)
		phys:EnableMotion(true)
		phys:EnableGravity(self.bEnableGravity)
		phys:EnableDrag(false)
		phys:Wake()
	end
end
function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DieTime <= CurTime() then
    if self.bFizzleOnTimeout then
		  self:Remove()
    else
      self:Explode()
    end
	end
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed >= 50 then
		self.PhysicsData = data
		self:NextThink(CurTime())
	end
end

function ENT:StartTouch(ent)
	if self.DieTime ~= 0 and ent:IsValidLivingPlayer() then
		local owner = self:GetOwner()
		if not owner:IsValid() then owner = self end

		if ent ~= owner and ent:Team() ~= self.Team() then
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav")
      if self.DirectDamage > 0 then
        ent:TakeSpecialDamage(self.DirectDamage, DMG_CLUB, owner, self, nil)
      end
      self:Explode()
		end
	end
end


function ENT:Explode(hitpos, hitnormal)
	if self.DieTime == 0 then return end
	self.DieTime = 0

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local pos = self:GetPos()

		--deal damage to everyone except the attacker
		--inf, att, center, radius, damage, damagetype, maxFalloffFrac, doIgnoreAttacker, force
		util.BlastDamagePlayer(self, owner, pos, self.GrenadeRadius or 256, self.GrenadeDamage or 256, DMG_ALWAYSGIB, 0.5, true, self.GrenadeKnockback or 200)

		--deal damage to the attacker
		util.BlastDamageSingle(self, owner, owner, pos, self.GrenadeRadius or 256, self.OwnerDamage or 100, DMG_ALWAYSGIB, 1, 100)

		local effectdata = EffectData()
			effectdata:SetOrigin(pos + Vector(0, 0, -1))
			effectdata:SetNormal(Vector(0, 0, -1))
		util.Effect("decal_scorch", effectdata)
		util.Effect("explosion_rocket", effectdata)
		--self:EmitSound("npc/env_headcrabcanister/explosion.wav", 85, 100)
	end

	self:NextThink(CurTime())
end

function ENT:PhysicsCollide(data, phys)
    if data.Speed >=50 then
      self.tPhysicsData = data
      self:NextThink(CurTime())
    end
end
