local G = ...

local default_project_dir = "../../shared/lua"
local default_file = "/tutorial/intro.lua"
local default_interpreter = "luacraft"


editor.usetabs = true
editor.tabwidth = 4
editor.usewrap = false
editor.fontsize = 9
editor.menuicon = true
styles.indicator.varglobal = nil

if os.getenv("USER") ~= "caps" then
	excludelist = {
		"extensions/",
	}
end

package("packages/") -- relative to config.lua

local temp
temp = ide:AddTimer(wx.wxGetApp(), function()
	temp:Stop()

	do -- set default project directory
		local obj = wx.wxFileName(default_project_dir)
		obj:Normalize()

		ProjectUpdateProjectDir(obj:GetFullPath())
	end

	do -- open default file
		if #ide:GetDocuments() == 0 then
			LoadFile(ide.config.path.projectdir .. default_file)
		end
	end

	do -- set default interpreter
		ProjectSetInterpreter(default_interpreter)
	end
end)
temp:Start(0.1,false)

do
	local options = {
		pauseOnLostFocus = "false",
	}

	local file_name = "../minecraft/run/options.txt"
	local file, str

	file = assert(io.open(file_name, "rb"))
	str = file:read("*all")
	file:close()

	for k, v in pairs(options) do
		str = str:gsub(k .. ":.-\n", k .. ":" .. v .. "\n")
	end

	os.remove(file_name)

	file = io.open(file_name, "wb")
	file:write(str)
	file:close()
end
