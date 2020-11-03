local meta = FindMetaTable("Player")

local util_SharedRandom = util.SharedRandom
local PLAYERANIMEVENT_FLINCH_HEAD = PLAYERANIMEVENT_FLINCH_HEAD
local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY
local GESTURE_SLOT_FLINCH = GESTURE_SLOT_FLINCH
local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD
local HITGROUP_HEAD = HITGROUP_HEAD
local HITGROUP_CHEST = HITGROUP_CHEST
local HITGROUP_STOMACH = HITGROUP_STOMACH
local HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
local HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
local HITGROUP_LEFTARM = HITGROUP_LEFTARM
local HITGROUP_RIGHTARM = HITGROUP_RIGHTARM
local TEAM_UNDEAD = TEAM_UNDEAD
local TEAM_SPECTATOR = TEAM_SPECTATOR
local TEAM_HUMAN = TEAM_HUMAN
local IN_ZOOM = IN_ZOOM
local MASK_SOLID = MASK_SOLID
local MASK_SOLID_BRUSHONLY = MASK_SOLID_BRUSHONLY
local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull

local getmetatable = getmetatable

local M_Entity = FindMetaTable("Entity")

local P_Team = meta.Team

local E_IsValid = M_Entity.IsValid
local E_GetDTBool = M_Entity.GetDTBool
local E_SetDTBool = M_Entity.SetDTBool
local E_GetTable = M_Entity.GetTable

function meta:SetBarricadeGhosting(bValue)
    E_SetDTBool(self, 0, bValue)
end

function meta:GetBarricadeGhosting()
    return E_GetDTBool(self, 0)
end

local colCrosshairRed = Color(255,110,110, 255)
local colCrosshairBlue = Color(110,110,255, 255)
function meta:GetCrosshairColor()
    return colCrosshairRed;
end

--[[
    Gets the object the player is holding
    as anything other than null will evaluate as true, can be used to check if
    the player is holding as well

    return: the object the player is holding, else null
]]
function meta:GetHolding()
    --TODO reimplement statuses & holding
    --[[
    local status = self.status_human_holding
    if status and status:IsValid() then
        local obj = status:GetObject()
        if obj:IsValid() then return obj end
    end
    ]]

    return nil
end
meta.IsHolding = meta.GetHolding
