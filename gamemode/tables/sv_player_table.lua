local meta = FindMetaTable("Player")
local P_Team = meta.Team

--[[
    SetClass - set the player's
]]
function meta:SetClass(iIndex)
    local tClass = GAMEMODE.Classes[index]
    if tClass then
        self.Class = tClass

        net.Start("al_class")
            net.WriteEntity(self)
            net.WriteUInt(iIndex, 8)
        net.Broadcast()
    end
end

--[[
    Gives the player a weapon

    sWeaponName [string]: the name of the weapon (e.g. "weapon_al_base")
    eDoFillAmmo [GIVE_WEAPON_FILL_*]: what ammo behavior to use for the weapon
        default case: set clip and spare to equal weapon.MaxSpareAmmo
    return: false if failed to give weapon, else true
]]
GIVE_WEAPON_FILL_FULL = nil
GIVE_WEAPON_FILL_EMPTY = 1
GIVE_WEAPON_FILL_CLIP_ONLY = 2
function meta:GiveWeapon(sWeaponName, eDoFillAmmo)
    local twWeapon = self:Give(sWeaponName, true)

    if ( not twWeapon or not twWeapon:IsValid()) then return false end

    -- empty the clip if eDoFillAmmo says to, else fill it
    twWeapon:SetClip1( eDoFillAmmo == GIVE_WEAPON_FILL_EMPTY and 0
        or twWeapon.Primary.ClipSize )

    if ( eDoFillAmmo == GIVE_WEAPON_FILL_FULL ) then
        self:RefillWeapon(twWeapon, true)
    end
end

--[[
    Fills the player's supply of ammo for a particular weapon

    twWeapon: the weapon table
    bFillClip: if true, also reload the weapon
]]
function meta:RefillWeapon(twWeapon, bFillClip)
    local extraAmmo = bFillClip and 0 or twWeapon.Primary.ClipSize - twWeapon:Clip1()

    self:SetAmmo( twWeapon.MaxSpareAmmo + extraAmmo, twWeapon.Primary.Ammo )
end
