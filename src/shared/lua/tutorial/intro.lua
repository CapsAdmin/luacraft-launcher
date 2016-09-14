--[[
	Minecraft forge er en mod til minecraft som gjør det enklere og lage mods til minecraft med Java.
	På samme måte er Luacraft en mod til Minecraft forge som
	gjør det enklere å lage mods til Minecraft. Men med programerings språket Lua i stedet for Java.

	Lua er ett veldig simpelt men kraftig programerings	språk som har en fordel med å være
	enkelt å lese og forstå relativt til andre språk.

	For å starte luacraft trykker du på den grønne pilen i toolbaren. Dette vil starte både client og server.
	**Første gang du starter kan ta lang tid. Du vil kunne se progressjonen i Output nederst i editoren.**

	Når serveren er oppe må du joine den ved å trykke multiplayer, direct connect, skriv "localhost" som ip og join.

	Det første blå ikonet vil kjøre skriptet du ser på server.
	Det andre gule ikonet vil kjøre skriptet du ser på på client.
]]

--  Vi skal prøve å forstå hvordan denne koden fungerer samtidig med hvordan Lua fungerer:
	local me = World():GetPlayers()[1]
	local there = me:GetEyeTrace().HitPos
	me:SetPos(there)

--  Først henter vi verden:
	World()

--  Så finner vi alle spillerene som befinner seg i verden og får dem igjennom en liste
	World():GetPlayers()

--  Så henter vi den første spilleren i den listen og lagrer den spilleren i `me`
	local me = World():GetPlayers()[1]

--  Så henter vi en liste med informasjon om hva spilleren ser på
	local there = me:GetEyeTrace()

--  I denne listen vil vi ha HitPos som er posisjonen spilleren ser på
	local there = me:GetEyeTrace().HitPos

--  Så til slutt flytter vi spilleren `me` til den posisjonen spilleren ser på `there`
	me:SetPos(there)

--  SetPos ligner /tp kommandoen

-- [neste side](macro:inline(ide:LoadFile("tutorial/mellomrom.lua")))