--  `local me =` og `local there =` er en måte å lagre variabler på.
--  Dette er nyttig slik at man ikke trenger å skrive så mye kode på nytt.

--  Hvis vi skulle ha skrevet teleporterings koden uten
--  `local me =` og `local there =` ville det sett slikt ut:
	World():GetPlayers()[1]:SetPos(World():GetPlayers()[1]:GetEyeTrace().HitPos)

--  Merk at man må skrive World():GetPlayers()[1] 2 ganger.
--  Det kan også fort bli vanskeligere å lese hvis man ungår å bruke local

--  En variabel kan hete hva som helst:
	local meg = World():GetPlayers()[1]
	local der = meg:GetEyeTrace().HitPos
	meg:SetPos(der)

--  Eller:
	local aaaaaAAAA = World():GetPlayers()[1]
	local BBBBBBBBBBBBBB = aaaaaAAAA:GetEyeTrace().HitPos
	meg:SetPos(BBBBBBBBBBBBBB)

--  Så lenge man skriver det samme.
--  **Husk små og store bokstaver er viktig!**
--  `there` er **ikke** det samme som `TheRrE` eller `There`.

--  Hvor variablene befinner seg i koden har mye å si.
--  Lua ser etter variabler bakover.

--  Man ikke skrive følgene: (de 2 første linjene er bytta om)
--                |__|
	local there = me:GetEyeTrace().HitPos
	local me = World():GetPlayers()[1]
	me:SetPos(there)

-- 	Fordi Lua skjønner ikke hva `me` er.
--  Variablen `me` må lagres før man bruker me:GetEyeTrace().HitPos

--[[
	Dette kan sammenlignes med å si:
		|Jeg spillte minecraft igår. Jeg ble drept av zombier|.
	Hvor "Jeg spillte minecraft igår" informerer om at det var det du gjorde.

	Hvis man bare hadde sagt:
		|Jeg ble drept av zombier.|
	Uten å nevne at du spillte minecraft igår ville man ikke skjønt hva du mente.

	Så på samme måte hvis ikke `me` nevnes før `there` vil ikke lua skjønne hva du mente og vil gi en feilmelding.
]]

-- [neste side](macro:inline(ide:LoadFile("tutorial/oppgave.lua")))