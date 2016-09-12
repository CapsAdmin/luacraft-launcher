--	Lua leser skriptet fra første til siste bokstav og mellomrom har ikke noe å si.

--	Man kan skrive koden slik om man vil:
		local me = World():GetPlayers()[1] local there = me:GetEyeTrace().HitPos me:SetPos(there)

-- 	Eller slik:
		local     me = World  ( )  :GetPlayers(  )[ 1]
		local there      = me
					:GetEyeTrace(    )  .HitPos
		me  :SetPos(   there)

--[[
	Så lenge man gjør det mellom symboler.

	Symboler vil si det som er markert:
		local me |=| World |():| GetPlayers |()[| 1 |]|
		local there |=| me |:| GetEyeTrace |().| HitPos
		me |:| SetPos |(| there |)|

	Man kan _ikke_ skrive følgene markert:
		me:|Set  Pos|(there)
		|m  e|:SetPos(there)
		me:SetPos(|th ere|)
]]