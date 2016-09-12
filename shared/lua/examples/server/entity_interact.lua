local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

local cow = World():CreateEntity("Cow")
cow:SetPos(there)
cow:Spawn()

function cow:OnPlayerInteract(ply)
	World():AddLightning(self:GetPos())
end