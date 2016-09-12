local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

local ent = World():CreateEntity("Rabbit")
ent:SetPos(there)
ent:Spawn()

function ent:OnJump()
	self:AddVelocity(Vector(0,0,0.25))
	World():AddLightning(self:GetPos())
end

function ent:OnUpdate()
	ent:MoveTo(me:GetPos())
end

function ent:OnStruckByLightning()
	self:SetHealth(self:GetMaxHealth())
end

function ent:OnFall()
	World():GetBlock(self:GetPos()):SetID(1)
end