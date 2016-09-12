hook.Add("game.tick", "lol", function()
	World():SetTime((math.sin(os.clock()) + 1)*32000)
end)