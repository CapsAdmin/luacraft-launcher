hook.Add("player.connect", "test", function(player)
    player:Msg("Hey" .. player:GetName() .. "! Welcome to luacraft!")
end)