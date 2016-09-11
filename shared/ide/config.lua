local G = ...

local default_project_dir = "../../shared"
local default_file = "/addons/test/lua/autorun/hello_world.lua"
local default_interpreter = "luacraft"


editor.usetabs = true
editor.tabwidth = 4
editor.usewrap = false
editor.fontsize = 9
editor.menuicon = true

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
