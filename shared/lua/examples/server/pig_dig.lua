local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

local ent = World():CreateEntity("Pig")
ent:SetPos(there)
ent:Spawn()

ent:SetHealth(10000)

function ent:OnUpdate()
	for x = -1,1 do
		for y = -1,1 do
			for z = -1,1 do
				World():GetBlock(self:GetPos()+Vector(x,y,z)):SetID(0)
			end
		end
	end
end