local PLUGIN = {
	name = "editor defaults for luacraft",
	description = "sets default interpreter and hides some things that are not needed",
	author = "CapsAdmin",
}
local default_project_dir = "../../shared/lua"
local default_file = "/tutorial/intro.lua"
local default_interpreter = "luacraft"

if os.getenv("USER") == "caps" then
	default_project_dir = "../../shared/"
	default_file = nil
	--default_interpreter = nil
else
	excludelist = {
		"extensions/",
	}
end

function PLUGIN:onAppLoad()
	if default_project_dir then -- set default project directory
		local obj = wx.wxFileName(default_project_dir)
		obj:Normalize()

		ProjectUpdateProjectDir(obj:GetFullPath())
	end

	if default_file then -- open default file
		if #ide:GetDocuments() == 0 then
			LoadFile(ide.config.path.projectdir .. default_file)
		end
	end

	if default_interpreter then -- set default interpreter
		ProjectSetInterpreter(default_interpreter)
	end
end

function PLUGIN:onProjectLoaded(menu, editor, event)
	return false
end

return PLUGIN