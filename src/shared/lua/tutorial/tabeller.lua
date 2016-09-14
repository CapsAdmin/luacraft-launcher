-- Dette kaller man table i lua som oversatt til norsk betyr en tabel. Det kan være en slags liste med forskjellige variabler. Det er ikke ett bord.

-- local trace = me:GetEyeTrace() returnerer en liste med informasjon av hva man ser på som kan se slik ut:

local trace = {
    Hit = true,
    HitPos = Vector(2305, 34, 463),
    HitNormal = Vector(0,0,1),
}

-- For å hente HitPos fra listen så skriver vi trace.HitPos med punktum før HitPos

local players = World():GetPlayers() returnerer en liste med alle spillere som er i verdenen. (I singleplayer er det bare 1 spiller.) det kan se slikt ut:

local trace = {
    [1] = PlayerTruls,
    [2] = PlayerNils,
    [3] = PlayerArne,
}

-- For å hente første spiller fra listen så skriver vi players[1] eller andre spiller players[2] osv

-- Man kan ikke skrive PlayerTruls, PlayerNils og PlayerArne i lua, det er bare en måte jeg representerer spillerene på her i dette dokumentet.--