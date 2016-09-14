local font = surface.GetDefaultFont()

hook.Add("render.gameoverlay", "test", function(time, phase)
	font:DrawText("luacraft", 4, 4, true)
end)