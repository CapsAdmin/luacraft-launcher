local me = World():GetPlayers()[1]
local there = me:GetEyeTrace().HitPos

World():GetBlock(there):SetID(64)