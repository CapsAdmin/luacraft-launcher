-- Slik lager vi en teleport command:
	local function teleport(player)
		local there = player:GetEyeTrace().HitPos
		me:SetPos(there)
	end
	commands.Add("tp", teleport, "teleports to where you're looking")


-- Det kan også skrives på denne måten hvis man vil:
	commands.Add("tp", function(player)
		local there = player:GetEyeTrace().HitPos
		me:SetPos(there)
	end, "teleports to where you're looking")


-- En command kjøres med disse parameterene:
	local function mycommand(player, command_name, arguments, line)

	end
	commands.Add("mycommand", mycommand, "help text")

--[[
player:
	spilleren som kjørte kommandoen

command_name:
	navnet på kommandoen som er “mycommand” i dette tilfellet

arguments:
	en liste med argumenter. hvis du skriver  “/mycommand a b c d”
	så blir arguments[1] = “a” arguments[2] = “b”, arguments[3] = “c”, osv

line:
	hele kommando linjen. hvis du skriver “/mycommand a b c d”
	så blir line “/mycommand a b c d”

Merk at man ikke trenger å skrive , command_name, arguments, line hvis man ikke trenger disse variablene.
]]