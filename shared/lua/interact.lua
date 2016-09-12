local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

local cow = World():CreateEntity("Cow")
cow:SetPos(there)
cow:Spawn()

hook.Add("player.interact", "lol", function(ply, ent)
	if ent == cow then
		World():AddLightning(cow:GetPos())
	end
end)