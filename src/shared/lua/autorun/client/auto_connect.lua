hook.Add("gui.init", "auto_connect", function()
	game.JoinServer("localhost", 25565)
	hook.remove("gui.init", "auto_connect")
end)