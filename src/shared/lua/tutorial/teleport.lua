--  Vi skal prøve å forstå hvordan denne koden fungerer samtidig med hvordan Lua fungerer:
	local me = World():GetPlayers()[1]
	local there = me:GetEyeTrace().HitPos
	me:SetPos(there)

--  Først henter vi verden:
	World()

--  Så finner vi alle spillerene som befinner seg i verden og får dem igjennom en type liste
	World():GetPlayers()

--  Så henter vi den første spilleren i den listen og lagrer den spilleren i `me`
	local me = World():GetPlayers()[1]

--  Så henter vi en liste med informasjon om hva `me` ser på
	local there = me:GetEyeTrace()

--  I denne listen vil vi ha HitPos som er posisjonen spilleren ser på
	local there = me:GetEyeTrace().HitPos

--  Til slutt flytter vi spilleren `me` til `there`
	me:SetPos(there)

--  Altså spilleren teleporteres til posisjonen den ser på.
--  SetPos ligner /tp kommandoen

--  [neste side](macro:inline(ide:LoadFile("tutorial/mellomrom.lua")))