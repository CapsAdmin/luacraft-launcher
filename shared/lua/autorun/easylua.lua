local easylua = {}

local function msg(ply, str)
	if CLIENT then
		game.Say("CLIENT: " .. str)
	end
	if SERVER then
		ply:Msg("SERVER: " .. str)
	end
end

function easylua.PCall(func, ply, ...)
	local ret = {pcall(func, ...)}
	if ret[1] then
		table.remove(ret, 1)
		if #ret > 0 then
			for i, v in ipairs(ret) do
				ret[i] = tostring(v)
			end

			msg(ply, table.concat(ret, ", "))
		end
	else
		msg(ply, tostring(ret[2])) -- bug?
	end
end

function easylua.RunLua(ply, code)
	local trace = ply:GetEyeTrace()

	local env = {
		{"me", ply},
		{"trace", trace},
		{"there", trace.HitPos},
		{"here", trace.StartPos},
		{"here", trace.StartPos},
		{"this", trace.HitEntity or trace.HitBlock},
		{"block", trace.HitBlock},
		{"world", setmetatable({}, {__index = function(_, key) local world = World() return function(...) return world[key](world, ...) end end})},

		{"print", function(...)
			local args = {}
			for i = 1, select("#", ...) do
				table.insert(args, tostring((select(i, ...))))
			end
			msg(ply, table.concat(args, ", "))
		end},
	}

	local locals = "local "
	for i, data in ipairs(env) do
		locals = locals .. data[1]
		if i ~= #env then
			locals = locals .. ", "
		end
	end

	local func = assert(loadstring(locals .. " = ... " .. code, code))

	local vars = {}
	for _, data in ipairs(env) do
		table.insert(vars, data[2])
	end

	return func(unpack(vars))
end

local commands = {}

if CLIENT then
	commands.lc = {
		help = "run lua",
		callback = function(ply, code)
			if ply:EntIndex() == LocalPlayer():EntIndex() then
				return easylua.RunLua(ply, code)
			end
		end,
	}

	commands.printc = {
		help = "print lua",
		callback = function(ply, code)
			if ply:EntIndex() == LocalPlayer():EntIndex() then
				return easylua.RunLua(ply, "print(" .. code .. ")")
			end
		end,
	}
end

if SERVER then
	commands.l = {
		help = "run lua",
		callback = function(ply, code)
			return easylua.RunLua(ply, code)
		end,
	}

	commands.print = {
		help = "print lua",
		callback = function(ply, code)
			return easylua.RunLua(ply, "print(" .. code .. ")")
		end,
	}
end

hook.Add("player.say", "easylua", function(ply, msg)
	if msg:sub(1, 1) ~= "!" then return end

	local name, cmd = msg:match("!(.-)%s+(.+)")

	if commands[name] then
		easylua.PCall(commands[name].callback, ply, ply, cmd)
	end
end)

if SERVER then
	for name, info in pairs(commands) do
		command.Add(name, function(ply, name, args, line)
			return easylua.PCall(info.callback, ply, ply, line)
		end, info.help)
	end
end

_G.easylua = easylua

do -- add entity events
	local events = {
		attacked = "OnAttacked",
		death = "OnDeath",
		fall = "OnFall",
		jump = "OnJump",
		lightning = "OnStruckByLightning",
		removed = "OnRemove",
		spawned = "OnSpawn",
		update = "OnUpdate",
		dropall = "OnDropLoot",
		joinworld = "OnJoinWorld",
	}

	for event, entity_func in pairs(events) do
		hook.Add("entity." .. event, "entity_update", function(ent, ...)
			if ent and ent[entity_func] then
				ent[entity_func](ent, ...)
			end
		end)
	end
end