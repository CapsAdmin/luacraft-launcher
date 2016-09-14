-- Ordet `local` betyr at variablen eksisterer lokalt etter man har skrevet den. Man kan skrive uten `local`:

me = World():GetPlayers()[1]
there = me:GetEyeTrace().HitPos
me:SetPos(there)

--[[
Men da eksisterer me og there globalt eller overalt i lua. Dette kan være nyttig I noen tilfeller.
Ett eksempel er å skrive `!l min_posisjon = here` I chatten.
Da vil min_posisjon være tilgjengelig overalt i lua. Da kan du skrive `me:SetPos(min_posisjon)`
i en lua fil eller i chatten så vil `min_posisjon` være posisjon du var på
da du skrev `!l min_posisjon = here`
]]