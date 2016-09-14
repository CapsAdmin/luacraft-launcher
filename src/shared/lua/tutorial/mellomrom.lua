--  Lua leser ett skript fra første til siste bokstav.

--  Man kan skrive koden slik om man vil:
	local me = World():GetPlayers()[1] local there = me:GetEyeTrace().HitPos me:SetPos(there)

--  Eller slik:
	local     me = World  ( )  :GetPlayers(  )[ 1]
	local there      = me
				:GetEyeTrace(    )  .HitPos
	me  :SetPos(   there)

--  Så lenge man gjør det mellom symboler.

--[[
	Symboler vil si det som er markert her:
		local me |=| World |():| GetPlayers |()[| 1 |]|
		local there |=| me |:| GetEyeTrace |().| HitPos
		me |:| SetPos |(| there |)|

	Men man kan _ikke_ skrive følgene markert:
		me:|Set  Pos|(there)
		|m  e|:SetPos(there)
		me:SetPos(|th ere|)
]]

-- [neste side](macro:inline(ide:LoadFile("tutorial/variabler.lua")))