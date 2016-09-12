--[[
	Minecraft forge er en mod til minecraft som gjør det enklere og lage mods til minecraft med java.
	På samme måte er luacraft en mod til minecraft forge som gjør det enklere å lage mods til minecraft.

	Men med programerings språket lua i stedet for java. Lua er ett veldig simpelt men kraftig programerings
	språk som har en fordel med å være enkelt å lese og forstå relativt til andre språk.
]]

 -- Vi skal prøve å forstå hvordan denne koden fungerer samtidig med hvordan Lua fungerer:
	local me = World():GetPlayers()[1]
	local there = me:GetEyeTrace().HitPos
	me:SetPos(there)

--[[
	Denne koden teleporterer den første spilleren til posisjonen han/hun ser på.
	Den første spilleren i singleplayer er altid deg.
	du kan kjøre dette skriptet ved å skrive /lua include("tutorial/intro.lua")
]]

-- [neste side](macro:inline(ide:LoadFile("tutorial/mellomrom.lua")))