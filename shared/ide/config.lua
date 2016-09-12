local G = ...

editor.usetabs = true
editor.tabwidth = 4
editor.usewrap = false
editor.fontsize = 9
editor.menuicon = true
format.apptitle = "Luacraft IDE"
styles.indicator.varglobal = nil

toolbar.icons = {
	ID.NEW, ID.OPEN, ID.SAVE, ID.SAVEALL, ID.PROJECTDIRFROMFILE, ID.PROJECTDIRCHOOSE,
	ID.SEPARATOR,
	ID.FIND, ID.REPLACE, ID.FINDINFILES,
	ID.SEPARATOR,
  --[[
	ID.SEPARATOR,
	ID.RUN, ID.STARTDEBUG, ID.RUNNOW, ID.STOPDEBUG, ID.DETACHDEBUG, ID.BREAK,
	ID.STEP, ID.STEPOVER, ID.STEPOUT, ID.RUNTO,
	ID.SEPARATOR,
	ID.BREAKPOINTTOGGLE, ID.BOOKMARKTOGGLE, ID.VIEWCALLSTACK, ID.VIEWWATCHWINDOW,
  [ID.FINDINFILES] = false,]]
}

package("packages/") -- relative to config.lua

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
