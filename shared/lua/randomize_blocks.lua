local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

for x = -5, 5 do
	for y = -5, 5 do
		for z = -5, 5 do
			World():GetBlock(there + Vector(x,y,z)):SetID(math.random(256))
		end
	end
end