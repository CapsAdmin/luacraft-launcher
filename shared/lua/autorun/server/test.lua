hook.Add("player.connect", "test", function(player)
    ply:Msg("Hey" .. player:GetName() .. "! Welcome to luacraft!")
end)