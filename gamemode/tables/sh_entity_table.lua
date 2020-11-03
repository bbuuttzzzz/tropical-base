local meta = FindMetaTable("Entity")

function meta:FireBulletsLua(src, dir, spread, num, damage, attacker, force_mul, tracer, callback, hull_size, hit_own_team, max_distance, filter, inflictor)
	max_distance = max_distance or 56756
	attacker = attacker or self
	if not E_IsValid(attacker) then attacker = self end
	force_mul = force_mul or 1
	if num < 0 then
		damage = math.Round(damage / #BULLETPATTERNS[num], 1)
	end

	temp_shooter = self
	temp_attacker = attacker
	attacker_player = attacker:IsPlayer()
	inflictor_weapon = inflictor and inflictor:IsWeapon()

	bullet_trace.start = src
	if filter then
		bullet_trace.filter = filter
	else
		bullet_trace.filter = BaseBulletFilter
		if not hit_own_team and attacker_player then
			temp_ignore_team = P_Team(attacker)
		else
			temp_ignore_team = nil
		end
	end

	if hull_size then
		bullet_trace.maxs = Vector(hull_size, hull_size, hull_size) * 0.5
		bullet_trace.mins = bullet_trace.maxs * -1
		method_to_use = util_TraceHull
	else
		method_to_use = util_TraceLine
	end

	base_ang = dir:Angle()
	temp_has_spread = spread > 0
	temp_dirs[1] = dir

	if SERVER and num ~= 1 and attacker_player then attacker:StartDamageNumberSession() end

	if num > 0 then -- random pattern
		for i=1, num do
			if temp_has_spread then
				temp_angle:Set(base_ang)
				temp_angle:RotateAroundAxis(
					temp_angle:Forward(),
					inflictor_weapon and util_SharedRandom("bulletrotate" .. i, 0, 360) or math.Rand(0, 360)
				)
				temp_angle:RotateAroundAxis(
					temp_angle:Up(),
					inflictor_weapon and util_SharedRandom("bulletangle" .. i, -spread, spread) or math.Rand(-spread, spread)
				)

				temp_dirs[i] = temp_angle:Forward()
			end
		end
	else -- set pattern weapons
		for i=1, #BULLETPATTERNS[num] do
			temp_angle:Set(base_ang)
			temp_angle:RotateAroundAxis(
				temp_angle:Forward(),
				BULLETPATTERNS[num][i][2]
			)
			temp_angle:RotateAroundAxis(
				temp_angle:Up(),
				BULLETPATTERNS[num][i][1] * spread
			)

			temp_dirs[i] = temp_angle:Forward()
		end
		num = #BULLETPATTERNS[num]
	end

	for i=1, num do
		dir = temp_dirs[i]
		bullet_trace.endpos = src + dir * max_distance
		bullet_tr = method_to_use(bullet_trace)

		CheckFHB(bullet_tr)

		local hitwater
		if bit.band(util.PointContents(bullet_tr.HitPos), CONTENTS_LIQUID) ~= 0 then
			hitwater = HandleShotImpactingWater(damage)
		end

		local damageinfo = DamageInfo()
		damageinfo:SetDamageType(DMG_BULLET)
		damageinfo:SetDamage(damage)
		damageinfo:SetDamagePosition(bullet_tr.HitPos)
		damageinfo:SetAttacker(attacker)
		damageinfo:SetInflictor(inflictor or self)
		if force_mul > 0 then
			damageinfo:SetDamageForce(force_mul * damage * 70 * dir:GetNormalized())
		else
			damageinfo:SetDamageForce(Vector(0, 0, 1))
		end

		local use_tracer = true
		local use_impact = true
		local use_ragdoll_impact = true
		local use_damage = true

		if callback then
			local ret = callback(attacker, bullet_tr, damageinfo)
			if ret then
				if ret.donothing then continue end

				if ret.tracer ~= nil then use_tracer = ret.tracer end
				if ret.impact ~= nil then use_impact = ret.impact end
				if ret.ragdoll_impact ~= nil then use_ragdoll_impact = ret.ragdoll_impact end
				if ret.damage ~= nil then use_damage = ret.damage end
			end
		end

		local ent = bullet_tr.Entity
		if E_IsValid(ent) and use_damage then
			if ent:IsPlayer() then
				temp_vel_ents[ent] = temp_vel_ents[ent] or ent:GetVelocity()
				if SERVER then
					ent:SetLastHitGroup(bullet_tr.HitGroup)
					if bullet_tr.HitGroup == HITGROUP_HEAD then
						ent:SetWasHitInHead()
					end
				end
			elseif attacker:IsValidPlayer() then
				local phys = ent:GetPhysicsObject()
				if ent:GetMoveType() == MOVETYPE_VPHYSICS and phys:IsValid() and phys:IsMoveable() then
					ent:SetPhysicsAttacker(attacker)
				end
			end

			ent:DispatchTraceAttack(damageinfo, bullet_tr, dir)
		end

		if SERVER and num ~= 1 and i == num and attacker_player then
			local dmg, dmgpos, haspl = attacker:PopDamageNumberSession()

			if dmg > 0 and dmgpos then
				GAMEMODE:DamageFloater(attacker, ent, dmgpos, dmg, haspl)
			end
		end

		if IsFirstTimePredicted() then
			local effectdata = EffectData()
			effectdata:SetOrigin(bullet_tr.HitPos)
			effectdata:SetStart(src)
			effectdata:SetNormal(bullet_tr.HitNormal)

			if hitwater then
				-- We may not impact, but we DO need to affect ragdolls on the client
				if use_ragdoll_impact then
					util.Effect("RagdollImpact", effectdata)
				end
			elseif use_impact and not bullet_tr.HitSky and bullet_tr.Fraction < 1 then
				effectdata:SetSurfaceProp(bullet_tr.SurfaceProps)
				effectdata:SetDamageType(DMG_BULLET)
				effectdata:SetHitBox(bullet_tr.HitBox)
				effectdata:SetEntity(ent)
				util.Effect("Impact", effectdata)
			end

			if use_tracer then
				if self:IsPlayer() and E_IsValid(self:GetActiveWeapon()) then
					effectdata:SetFlags( 0x0003 ) --TRACER_FLAG_USEATTACHMENT + TRACER_FLAG_WHIZ
					effectdata:SetEntity(self:GetActiveWeapon())
					effectdata:SetAttachment(1)
				else
					effectdata:SetEntity(self)
					effectdata:SetFlags( 0x0001 ) -- TRACER_FLAG_WHIZ
				end
				effectdata:SetScale(5000) -- Tracer travel speed
				util.Effect(tracer or "Tracer", effectdata)
			end
		end
	end

	-- No knockback vs. players. Do this ONLY once to migitate lag compensation issues instead of per bullet. Might just disable lag comp here.
	for ent, vel in pairs(temp_vel_ents) do
		ent:SetLocalVelocity(vel)
	end
	table.Empty(temp_vel_ents)
end

function meta:ApplyDamage(nAmount, eType, tpAttacker, tInflictor, vHitPos, nForce)


end
