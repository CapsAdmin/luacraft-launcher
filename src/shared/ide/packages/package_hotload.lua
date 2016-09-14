do return end
local PLUGIN = {
	name = "package hotload",
	description = "reload package on save",
	author = "CapsAdmin"
}

function PLUGIN:onEditorSave(editor)
	for name in pairs(ide.packages) do
		local path = ide:GetPackage(name):GetFilePath()

		if path == ide:GetDocument(editor).filePath then

			ide:PackageUnRegister(path)
			ide:PackageRegister(path)

			ide:Print("reloaded package: " .. name)

			return
		end
	end
end

return PLUGIN
