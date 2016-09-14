-- En funksjon er som en slags bit av kode man kan kjøre om igjen. Det kan på en måte sammenlignes med commands i minecraft.

-- Her lager vi en funksjon som heter teleport. For å kjøre funksjonen skriver man teleport() hvor symbolene () betyr at man kjører funksjonen.
local function teleport()
	local me = World():GetPlayers()[1]
	local there = me:GetEyeTrace().HitPos
	me:SetPos(there)
end
teleport()

-- En funksjon kan også ta i mot variabler:
local function teleport(where)
	local me = World():GetPlayers()[1]
	local there = me:GetEyeTrace().HitPos
	me:SetPos(where)
end
teleport(there)
teleport(here)

Eller returnere variabler:
local function teleport(where)
	local me = World():GetPlayers()[1]
	local there = me:GetEyeTrace().HitPos
	me:SetPos(where)
	return me
end
local me = teleport(there)

-- Eller begge deler + en funksjon som kjører en funksjon get_player:
local function get_player(index)
	return World():GetPlayers()[index]
end
local function teleport(player_index, where)
    local ply = get_player(player_index)
	local there = ply:GetEyeTrace().HitPos
	me:SetPos(where)
	return ply
end
local me = teleport(1, there)

-- I eksempelet kjører vi totalt 4 funksjoner:

World()
-- returnerer minecraft verdenen.

World():GetPlayers()
-- returnerer ett table med alle spillere. Hvis man spiller singleplayer så finnes det bare 1 spiller.

me:GetEyeTrace()
-- returnerer ett table med informasjon om hva man ser på.

me:SetPos(there)
-- returnerer ingenting men tar en posisjon som i dette tilfelle blir henta fra funksjonen over.
