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
