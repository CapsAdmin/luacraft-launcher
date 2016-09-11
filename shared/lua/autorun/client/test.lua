local font = surface.GetDefaultFont()

hook.Add("render.gameoverlay", "test", function(time, phase)
	font:DrawText("hello world", 4, 4, true)
end)