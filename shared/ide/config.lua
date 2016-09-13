local G = ...

editor.usetabs = true
editor.tabwidth = 4
editor.usewrap = false
editor.fontsize = 9
editor.menuicon = true
format.apptitle = "Luacraft IDE"
styles.indicator.varglobal = nil

toolbar.icons = {}

package("packages/") -- relative to config.lua
