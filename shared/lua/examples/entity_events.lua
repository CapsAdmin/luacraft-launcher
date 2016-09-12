local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

local ent = World():CreateEntity("Rabbit")
ent:SetPos(there)
ent:Spawn()

function ent:OnJump()
	self:AddVelocity(Vector(0,0,1))
	World():AddLightning(self:GetPos())
end

function ent:OnStruckByLightning()
	self:SetHealth(self:GetMaxHealth())
end

function ent:OnFall()
	World():GetBlock(self:GetPos()):SetID(11)
end

function ent:OnDeath()
	World():AddExplosion(self:GetPos(), 10, true, true)
end