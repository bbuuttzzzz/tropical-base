local M_Entity = FindMetaTable("Entity")
local M_Player = FindMetaTable("Player")
local M_CMoveData = FindMetaTable("CMoveData")

local M_SetVelocity = M_CMoveData.SetVelocity
local M_GetVelocity = M_CMoveData.GetVelocity
local M_SetMaxSpeed = M_CMoveData.SetMaxSpeed
local M_GetMaxSpeed = M_CMoveData.GetMaxSpeed
local M_SetMaxClientSpeed = M_CMoveData.SetMaxClientSpeed
local M_GetMaxClientSpeed = M_CMoveData.GetMaxClientSpeed
local M_GetForwardSpeed = M_CMoveData.GetForwardSpeed
local M_GetSideSpeed = M_CMoveData.GetSideSpeed

function GM:OnPlayerHitGround(pl, inwater, hitfloater, speed)
    if inwater then return end

    if speed > 64 then
        pl.LandSlow = true;
    end
end

-- what fraction of our speed over the target speed we should lose per jump
local antiBhopDecayRate = 0.3

function GM:FinishMove(playerTable, move)
    -- Anti bhopping - If we are going over a speed cap, lose speed whenever we hit the ground

    --we only care if we just hit the ground going an appreciable speed
    if playerTable.LandSlow then
        playerTable.LandSlow = false;

        vel = M_GetVelocity(move)
        currentSpeed = vel:Length()

        -- this line decides the speed that we should slow down to as we bhop
        targetSpeed = M_GetMaxSpeed(move)

        if targetSpeed < currentSpeed then
            mul = 1 - antiBhopDecayRate + antiBhopDecayRate * targetSpeed / currentSpeed
			vel.x = vel.x * mul
			vel.y = vel.y * mul
			M_SetVelocity(move, vel)
        end
    end
end
