-- `local me =` og `local there =` er en måte å lage variabler på.
-- Dette er nyttig slik at man ikke trenger å skrive så mye kode på nytt.

-- Hvis vi skulle ha skrevet dette uten `local me =` og `local there =` ville det sett slik ut:
World():GetPlayers()[1]:SetPos(World():GetPlayers()[1]:GetEyeTrace().HitPos)

-- Variabler kan hete hva som helst:
local meg = World():GetPlayers()[1]
local der = meg:GetEyeTrace().HitPos
meg:SetPos(der)

-- Hvor variablene befinner seg i koden er viktig. Lua ser etter variabler baklengs i koden eller i fortiden.

-- Dette kan man ikke skrive:
local there = me:GetEyeTrace().HitPos
local me = World():GetPlayers()[1]
me:SetPos(there)

-- Fordi lua ikke ville skjønt hva me er.

--[[
Dette kan sammenlignes med å si:
`Jeg spiller minecraft. Jeg syntes spillet er kjempe gøy`

Hvor ordet “spillet” betyr minecraft siden du har sagt at du spiller det.

Hvis du bare hadde sagt :
`Jeg syntes spillet er kjempe gøy.`

Uten å ha nevnt minecraft først ville man ikke skjønt hva slags spill "spillet" er.
]]