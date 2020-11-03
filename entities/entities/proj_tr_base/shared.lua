ENT.Type = "anim"

ENT.DrawColor = COLOR_RED
ENT.Model = "models/props/cs_italy/orange.mdl"
ENT.Lifetime = 15 -- time in seconds before self destruct
--ENT.bFizzleOnTimeout -- if true, do not explode when lifetime is over
--ENT.bEnableGravity
ENT.DirectDamage = 50
ENT.BlastDamage = 90

function ENT:ShouldNotCollide(ent)
  return ent:IsPlayer() and ent:Team() == self:GetOwner():Team()
end
