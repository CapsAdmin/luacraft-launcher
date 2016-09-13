--  `local me =` og `local there =` er en måte å lage variabler på.
--  Dette er nyttig slik at man ikke trenger å skrive så mye kode på nytt.

--  Hvis vi skulle ha skrevet koden uten `local me =` og `local there =` ville det sett slik ut:
	World():GetPlayers()[1]:SetPos(World():GetPlayers()[1]:GetEyeTrace().HitPos)

--  Merk at man må skrive GetPlayers 2 ganger og at det blir vanskeligere å lese

--  En variabel kan hete hva som helst:
	local meg = World():GetPlayers()[1]
	local der = meg:GetEyeTrace().HitPos
	meg:SetPos(der)

--  Eller:
	local aaaaaAAAA = World():GetPlayers()[1]
	local BBBBBBBBBBBBBB = aaaaaAAAA:GetEyeTrace().HitPos
	meg:SetPos(BBBBBBBBBBBBBB)

--  Så lenge man skriver det samme. Bemerk også at små og store bokstaver er også viktig.
--  `there` er ikke det samme som `TheRrE`.

--  Hvor variablene befinner seg i koden har mye å si.
--  Lua ser etter variabler baklengs i koden, eller i fortiden.

--  Man ikke skrive følgene: (de 2 første linjene er bytta om)
	local there = me:GetEyeTrace().HitPos
	local me = World():GetPlayers()[1]
	me:SetPos(there)

-- 	Fordi lua ikke ville skjønt hva me er.

--[[
	Dette kan sammenlignes med å si |Jeg spiller minecraft. Jeg syntes spillet er kjempe gøy|
	Hvor ordet “spillet” betyr minecraft siden det var nevnt før i setningen.

	Hvis du bare hadde sagt |Jeg syntes spillet er kjempe gøy.| Uten å ha nevnt minecraft først
	ville man ikke skjønt hva slags spill "spillet" er.
]]

--  Nå skal vi prøve å lage lyn der hvor vi ser
--  Høyre klikk på den øverste mappa i fil treet og velg new file
--  La skriptet hete lyn.lua og åpne det
--  Så kjører du minecraft