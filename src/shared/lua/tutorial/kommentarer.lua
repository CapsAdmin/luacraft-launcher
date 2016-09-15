--  Kommentarer vil si denne teksten du leser nå. Det er en måte å forklare koden på.

--  Man kan skrive kommentarer på denne måten

--[[
	Eller på denne måten.
	Med denne måten kan man skrive flere linjer uten repitere |--| hele tiden
]]

--  Her er noen eksempler på lua kode med kommentarer

--  denne koden endrer server navn til **min server**
	game.SetHostName("min server")

--  denne koden lager lyn på posisjonen 500, 200, 232 hvis det regner
	if World():IsRaining() then
		World():AddLightning(Vector(500, 200, 323))
	end

--  [neste side](macro:inline(ide:LoadFile("tutorial/teleport.lua")))