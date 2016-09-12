-- this is supposed to be a workaround for not having sockets

local function handle_line(line)
	if World() and World():GetPlayers()[1] then
		local ok, err = pcall(easylua.RunLua, World():GetPlayers()[1], line, true)
		if not ok then
			print(err)
		end
		return
	end
	local ok, err = loadstring(line)
	if ok then
		local res = {pcall(ok)}
		if res[1] then
			if res[2] then
				table.remove(res, 1)
				table.Print(res)
			end
		else
			print("error running line: ", res[2])
		end
	else
		print("error parsing line: ", err)
	end
end

local file_name = "./ide_input"
local last_update = 0

if CLIENT then
	file_name = file_name .. "_client"
end

if SERVER then
	file_name = file_name .. "_server"
end

os.remove(file_name)

hook.Add("game.tick", "ide_connection", function()
	local time = os.clock()

	if last_update < time then

		local input_file = io.open(file_name, "rb")

		if input_file then
			local content = input_file:read("*all")
			if content then
				for line in content:gmatch("(.-)\n12WD7\n") do
					handle_line(line)
				end
			end
			input_file:close()
			os.remove(file_name)
		end

		last_update = time + 0.1
	end
end)