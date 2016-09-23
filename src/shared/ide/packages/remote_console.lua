local PLUGIN = {
	name = "remote console",
	description = "",
	author = "CapsAdmin",
	version = 0.1,
}
ide.config.keymap[ID.STARTDEBUG] = nil
ide.config.keymap[ID.RUN] = nil

function PLUGIN:Setup()
	local function setup_console(id, name, cmd_line, icon, on_key)
		return
		{
			id = id,
			name = name,
			cmd_line = cmd_line,
			icon = icon,

			working_directory = "../",
			env_vars = {
				JAVA_HOME = "../jdk",
			},

			start = function(console)

			end,
			stop = function(console)

			end,
			run_string = function(console, str)
				local file = assert(io.open(console.working_directory .. "minecraft/run_" .. id .. "/ide_input_" .. console.id, "ab"))
				file:write(str)
				file:write("\n12WD7\n")
				file:close()
			end,
			run_script = function(console, path)
				console:Print("loading: ", path)
				console:run_string("local path = [["..path.."]] assert(loadfile(path))() print('script ran successfully')")
			end,
			print = function(console, ...)
				console:Print(...)
			end,
			on_update = function(console)
				if console.socket then
					console.socket:Update()
				end
			end,
			on_save = function(console, path)
				if path:lower():find("^.+/"..id.."/[^/]+$") then
					console:run_script(path)
				elseif not path:lower():find("^.+/server/[^/]+$") and not path:lower():find("^.+/client/[^/]+$") then
					console:run_script(path)
				end
			end,
			on_key = on_key,
		}
	end

	local server_icon = wx.wxBitmap{
		"16 16 22 1",
		" 	c #383838",".	c #353535","+	c #333333",
		"@	c #303030","#	c #2F2F2F","$	c #2D2D2D",
		"%	c #242424","&	c #3B3B3B","*	c #272727",
		"=	c #363636","-	c #323232",";	c #808080",
		">	c #292929",",	c #2B2B2B","'	c #232323",
		")	c #3A3A3A","!	c #FFFFFF","~	c #4B4B4B",
		"{	c #C0C0C0","]	c #3F3F3F","^	c #4A4A4A",
		"/	c #4D4D4D",
		" ..+@#$$%& .$*=-",	" ;;;;;;;;;;;;;;-",
		">;************;@",	"$;************;>",
		" ;************;%",	",;************;%",
		"-;************;'",	"#;************;)",
		"#;*!**********;&",	"~{**!*********{]",
		"~{*!**!!!*****{@",	"~{************{-",
		"~{{{{{{{{{{{{{{$",	"^{{{{{{{{{{{**{-",
		"/{{{{{{{{{{{{{{$",	"]--@@@@@@$@@@@--"
	}	;


	local client_icon = wx.wxBitmap{
		"16 16 43 1",
		" 	c #2F200D",".	c #2B1E0D","+	c #2F1F0F",
		"@	c #281C0B","#	c #241808","$	c #261A0A",
		"%	c #2A1D0D","&	c #332411","*	c #422A12",
		"=	c #3F2A15","-	c #2C1E0E",";	c #B6896C",
		">	c #BD8E72",",	c #C69680","'	c #BD8B72",
		")	c #BD8E74","!	c #AC765A","~	c #342512",
		"{	c #AA7D66","]	c #B4846D","^	c #AD806D",
		"/	c #9C725C","(	c #BB8972","_	c #9C694C",
		":	c #FFFFFF","<	c #523D89","[	c #B57B67",
		"}	c #9C6346","|	c #B37B62","1	c #B78272",
		"2	c #6A4030","3	c #BE886C","4	c #A26A47",
		"5	c #805334","6	c #905E43","7	c #965F40",
		"8	c #774235","9	c #8F5E3E","0	c #815339",
		"a	c #6F452C","b	c #6D432A","c	c #7A4E33",
		"d	c #83553B",
		"  ..++@@##$$..%%",	"  ..++@@##$$..%%",
		"......&&**==--@@",	"......&&**==--@@",
		"..;;>>,,''))!!~~",	"..;;>>,,''))!!~~",
		"{{]]{{^^//((____",	"{{]]{{^^//((____",
		"]]::<<[[((<<::{{",	"]]::<<[[((<<::{{",
		"}}||112222334455",	"}}||112222334455",
		"6677888888889900",	"6677888888889900",
		"aabb0000ccddddcc",	"aabb0000ccddddcc"
	}
;

	return {
		setup_console("server", "Server", jit.os ~= "Windows" and "bash server.bash" or "server.cmd", server_icon),
		setup_console("client", "Client", jit.os ~= "Windows" and "bash client.bash" or "client.cmd", client_icon, function(console, key, mod)
			if (key == wx.WXK_F5 or key == wx.WXK_F6) then
				if mod == wx.wxMOD_SHIFT then
					console:Stop()
				else
					console:Start()
				end
				return false
			end
		end),
	}
end

function PLUGIN:IsRunning(id)
	local console = self.consoles[id]
	return console.pid and wx.wxProcess.Exists(console.pid)
end

function PLUGIN:StartProcess(id)
	local console = self.consoles[id]

	if self:IsRunning(console.id) then
		console:print("already started")
	end

	if console.start then
		console:start()
	end

	console:print("launching...")

	for k,v in pairs(console.env_vars) do
		v = v:gsub("LUA(%b{})", function(code) return assert(loadstring("local console = ... return " .. code:sub(2, -2)))(console) end)
		wx.wxSetEnv(k, v)
	end

	local tb = ide:GetToolBar()

	console.pid = CommandLineRun(
		console.cmd_line,
		console.working_directory,
		true,--tooutput,
		true,--nohide,
		function(...) console:print(...) end,
		"luacraft_" .. id,
		function()
			tb:ToggleTool(console.wx_start_id, false)
			tb:EnableTool(console.wx_run_id, false)
			tb:Realize()
			ide:GetUIManager():Update()

			self:StopProcess(console.id)
		end
	)

	tb:ToggleTool(console.wx_start_id, true)
	tb:EnableTool(console.wx_run_id, true)
	tb:Realize()
	ide:GetUIManager():Update()

	console.shellbox:SetFocus()
end

function PLUGIN:StopProcess(id)
	local console = self.consoles[id]

	if self:IsRunning(console.id) then
		local pid = self.consoles[id].pid
		console:print("stopping " .. console.name .. (" (pid: %d) ... "):format(pid))
		os.execute("taskkill /F /T /PID " .. pid)
		local ret = wx.wxProcess.Kill(pid, wx.wxSIGKILL, wx.wxKILL_CHILDREN)
		if ret == wx.wxKILL_OK then
			console:print(("stopped process (pid: %d)."):format(pid))
		elseif ret ~= wx.wxKILL_NO_PROCESS then
			wx.wxMilliSleep(250)
			if wx.wxProcess.Exists(pid) then
				console:print(("unable to stop process (pid: %d), code %d."):format(pid, ret))
			end
		end

		if console.stop then
			console:stop()
		end
	end
end

local MAKE_ID = NewID()

function PLUGIN:onRegister()
	self.consoles = {}

	local tb = ide:GetToolBar()

	for _, info in ipairs(self:Setup()) do
		local console = {}

		for k,v in pairs(info) do console[k] = v end

		console.wx_start_id = NewID()
		console.Start = function() self:StartProcess(console.id) end
		console.Stop = function() self:StopProcess(console.id) end
		console.IsRunning = function() return self:IsRunning(console.id) end
		console.Print = function(_, ...) console.shellbox:Print(...) end

		tb:AddTool(console.wx_start_id, console.icon, console.icon, true)
		ide:GetMainFrame():Connect(console.wx_start_id, wx.wxEVT_COMMAND_MENU_SELECTED, function(event)
			if event:IsChecked() then
				self:StartProcess(console.id)
			else
				self:StopProcess(console.id)
			end
		end)
		tb:AddLabel(console.wx_start_id, "Start " .. console.name)

		console.shellbox = self:CreateRemoteConsole(console.name .. " Console", function(str)
			if self:IsRunning(console.id) then
				console:run_string(str)
			else
				console:print("Program is not launched")
			end
		end, console.icon)

		self.consoles[console.id] = console
	end

	tb:AddSeparator()

	for _, console in pairs(self.consoles) do
		console.wx_run_id = NewID()

		tb:AddTool(console.wx_run_id, "", console.icon)
		ide:GetMainFrame():Connect(console.wx_run_id, wx.wxEVT_COMMAND_MENU_SELECTED, function(event)
			if self:IsRunning(console.id) then
				local path = ide:GetDocument(ide:GetEditor()).filePath:gsub("\\", "/")
				path = path:match("shared/lua/(.+)") or path
				console:run_script(path)
			end
		end)
		tb:AddLabel(console.wx_run_id, "Run On " .. console.name)
		tb:EnableTool(console.wx_run_id, false)
	end

	tb:Realize()
	ide:GetUIManager():Update()
end

function PLUGIN:onUnregister()
	for _, console in pairs(self.consoles) do
		console:Stop()
	end
end

function PLUGIN:onEditorKeyDown(editor, event)
	local keycode = event:GetKeyCode()
	local mod = event:GetModifiers()

	for _, console in pairs(self.consoles) do
		if console.on_key then
			local res = console:on_key(keycode, mod)
			if res ~= nil then
				return res
			end
		end
	end
end

function PLUGIN:onIdle()
	for _, console in pairs(self.consoles) do
		if console.on_update then
			console:on_update()
		end
	end
end

function PLUGIN:onEditorSave(editor)
	local path = ide:GetDocument(editor).filePath:gsub("\\", "/")
	path = path:match("shared/lua/(.+)") or path

	for _, console in pairs(self.consoles) do
		if console.on_save and self:IsRunning(console.id) then
			console:on_save(path)
		end
	end
end

function PLUGIN:CreateRemoteConsole(name, on_execute, bitmap)
	--ide.frame.bottomnotebook:RemovePage(0)

	local shellbox = ide:CreateStyledTextCtrl(ide.frame.bottomnotebook, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxBORDER_NONE)
	local page = ide.frame.bottomnotebook:AddPage(shellbox, name, false, bitmap)

	-- Copyright 2011-15 Paul Kulchenko, ZeroBrane LLC
	-- authors: Luxinia Dev (Eike Decker & Christoph Kubisch)
	---------------------------------------------------------

	local ide = ide
	local unpack = table.unpack or unpack

	local bottomnotebook = ide.frame.bottomnotebook
	local out = shellbox
	local remotesend

	local PROMPT_MARKER = StylesGetMarker("prompt")
	local PROMPT_MARKER_VALUE = 2^PROMPT_MARKER
	local ERROR_MARKER = StylesGetMarker("error")
	local OUTPUT_MARKER = StylesGetMarker("output")
	local MESSAGE_MARKER = StylesGetMarker("message")
	local ANY_MARKER_VALUE = 2^25-1 -- marker numbers 0 to 24 have no pre-defined function

	out:SetFont(ide.font.oNormal)
	out:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, ide.font.oNormal)
	out:SetBufferedDraw(not ide.config.hidpi and true or false)
	out:StyleClearAll()

	out:SetTabWidth(ide.config.editor.tabwidth or 2)
	out:SetIndent(ide.config.editor.tabwidth or 2)
	out:SetUseTabs(ide.config.editor.usetabs and true or false)
	out:SetViewWhiteSpace(ide.config.editor.whitespace and true or false)
	out:SetIndentationGuides(true)

	out:SetWrapMode(wxstc.wxSTC_WRAP_WORD)
	out:SetWrapStartIndent(0)
	out:SetWrapVisualFlagsLocation(wxstc.wxSTC_WRAPVISUALFLAGLOC_END_BY_TEXT)
	out:SetWrapVisualFlags(wxstc.wxSTC_WRAPVISUALFLAG_END)

	out:MarkerDefine(StylesGetMarker("prompt"))
	out:MarkerDefine(StylesGetMarker("error"))
	out:MarkerDefine(StylesGetMarker("output"))
	out:MarkerDefine(StylesGetMarker("message"))
	out:SetReadOnly(false)

	local jumptopatterns = {
		-- <filename>(line,linepos):
		"^%s*(.-)%((%d+),(%d+)%)%s*:",
		-- <filename>(line):
		"^%s*(.-)%((%d+).*%)%s*:",
		--[string "<filename>"]:line:
		'^.-%[string "([^"]+)"%]:(%d+)%s*:',
		-- <filename>:line:linepos
		"^%s*(.-):(%d+):(%d+):",
		-- <filename>:line:
		"^%s*(.-):(%d+)%s*:",
		-- <filename>:line
		"(%S+%.lua):(%d+)",
		"Line (%d+).-@(%S+%.lua)",
		"(%d+)%s-@(%S+%.lua)",
		"@(%S+%.lua)",
	}

	out:Connect(wxstc.wxEVT_STC_DOUBLECLICK, function(event)
		local line = out:GetCurrentLine()
		local linetx = out:GetLineDyn(line)

		-- try to detect a filename and line in linetx
		local fname, jumpline, jumplinepos
		for _,pattern in ipairs(jumptopatterns) do
			fname,jumpline,jumplinepos = linetx:match(pattern)

			if tonumber(fname) then
				local line = tonumber(fname)
				fname = jumpline
				jumpline = line
			end

			if fname then break end
		end

		jumpline = jumpline or 0

		if not fname then return end

		-- fname may include name of executable, as in "path/to/lua: file.lua";
		-- strip it and try to find match again if needed.
		-- try the stripped name first as if it doesn't match, the longer
		-- name may have parts that may be interpreter as network path and
		-- may take few seconds to check.
		local name
		local fixedname = fname:match(":%s+(.+)")
		if fixedname then
			name = GetFullPathIfExists(FileTreeGetDir(), fixedname) or FileTreeFindByPartialName(fixedname)
		end
		name = name or GetFullPathIfExists(FileTreeGetDir(), fname) or FileTreeFindByPartialName(fname)

		ide:Print(name, fname, jumpline, jumplinepos)

		local editor = LoadFile(name or fname,nil,true)
		if not editor then
			local ed = GetEditor()
			if ed and ide:GetDocument(ed):GetFileName() == (name or fname) then
				editor = ed
			end
		end
		if editor then
			jumpline = tonumber(jumpline)
			jumplinepos = tonumber(jumplinepos)

			editor:GotoPos(editor:PositionFromLine(math.max(0,jumpline-1))
				+ (jumplinepos and (math.max(0,jumplinepos-1)) or 0))
			editor:EnsureVisibleEnforcePolicy(jumpline)
			editor:SetFocus()
		end

		-- doubleclick can set selection, so reset it
		local pos = event:GetPosition()
		if pos == -1 then pos = out:GetLineEndPosition(event:GetLine()) end
		out:SetSelection(pos, pos)
	end)

	SetupKeywords(out,"lua",nil,ide.config.stylesoutshell,ide.font.oNormal,ide.font.oItalic)

	local function getPromptLine()
		local totalLines = out:GetLineCount()
		return out:MarkerPrevious(totalLines+1, PROMPT_MARKER_VALUE)
	end

	local function getPromptText()
		local prompt = getPromptLine()
		return out:GetTextRangeDyn(out:PositionFromLine(prompt), out:GetLength())
	end

	local function setPromptText(text)
		local length = out:GetLength()
		out:SetSelectionStart(length - string.len(getPromptText()))
		out:SetSelectionEnd(length)
		out:ClearAny()
		out:AddTextDyn(text)
		-- refresh the output window to force recalculation of wrapped lines;
		-- otherwise a wrapped part of the last line may not be visible.
		out:Update(); out:Refresh()
		out:GotoPos(out:GetLength())
	end

	local function positionInLine(line)
		return out:GetCurrentPos() - out:PositionFromLine(line)
	end

	local function caretOnPromptLine(disallowLeftmost, line)
		local promptLine = getPromptLine()
		local currentLine = line or out:GetCurrentLine()
		local boundary = disallowLeftmost and 0 or -1
		return (currentLine > promptLine
		or currentLine == promptLine and positionInLine(promptLine) > boundary)
	end

	local function chomp(line) return (line:gsub("%s+$", "")) end

	local function getInput(line)
		local nextMarker = line
		local count = out:GetLineCount()

		repeat -- check until we find at least some marker
		nextMarker = nextMarker+1
		until out:MarkerGet(nextMarker) > 0 or nextMarker > count-1
		return chomp(out:GetTextRangeDyn(
		out:PositionFromLine(line), out:PositionFromLine(nextMarker)))
	end

	local currentHistory
	local function getNextHistoryLine(forward, promptText)
		local count = out:GetLineCount()
		if currentHistory == nil then currentHistory = count end

		if forward then
		currentHistory = out:MarkerNext(currentHistory+1, PROMPT_MARKER_VALUE)
		if currentHistory == -1 then
			currentHistory = count
			return ""
		end
		else
		currentHistory = out:MarkerPrevious(currentHistory-1, PROMPT_MARKER_VALUE)
		if currentHistory == -1 then
			return ""
		end
		end
		-- need to skip the current prompt line
		-- or skip repeated commands
		if currentHistory == getPromptLine()
		or getInput(currentHistory) == promptText then
		return getNextHistoryLine(forward, promptText)
		end
		return getInput(currentHistory)
	end

	local function getNextHistoryMatch(promptText)
		local count = out:GetLineCount()
		if currentHistory == nil then currentHistory = count end

		local current = currentHistory
		while true do
		currentHistory = out:MarkerPrevious(currentHistory-1, PROMPT_MARKER_VALUE)
		if currentHistory == -1 then -- restart search from the last item
			currentHistory = count
		elseif currentHistory ~= getPromptLine() then -- skip current prompt
			local input = getInput(currentHistory)
			if input:find(promptText, 1, true) == 1 then return input end
		end
		-- couldn't find anything and made a loop; get out
		if currentHistory == current then return end
		end

		assert(false, "getNextHistoryMatch coudn't find a proper match")
	end

	local function concat(sep, ...)
		local text = ""
		for i=1, select('#',...) do
		text = text .. (i > 1 and sep or "") .. tostring(select(i,...))
		end

		-- split the text into smaller chunks as one large line
		-- is difficult to handle for the editor
		local prev, maxlength = 0, ide.config.debugger.maxdatalength
		if #text > maxlength and not text:find("\n.") then
		text = text:gsub("()(%s+)", function(p, s)
			if p-prev >= maxlength then
				prev = p
				return "\n"
			else
				return s
			end
			end)
		end
		return text
	end

	local partial = false
	local function shellPrint(marker, text, newline)
		if not text or text == "" then return end -- return if nothing to print
		if newline then text = text:gsub("\n+$", "").."\n" end
		local isPrompt = marker and (getPromptLine() > -1)
		local lines = out:GetLineCount()
		local promptLine = isPrompt and getPromptLine() or nil
		local insertLineAt = isPrompt and not partial and getPromptLine() or out:GetLineCount()-1
		local insertAt = isPrompt and not partial and out:PositionFromLine(getPromptLine()) or out:GetLength()
		out:InsertTextDyn(insertAt, out.useraw and text or FixUTF8(text, function (s) return '\\'..string.byte(s) end))
		local linesAdded = out:GetLineCount() - lines

		partial = text:find("\n$") == nil

		if marker then
		if promptLine then out:MarkerDelete(promptLine, PROMPT_MARKER) end
		for line = insertLineAt, insertLineAt + linesAdded - 1 do
			out:MarkerAdd(line, marker)
		end
		if promptLine then out:MarkerAdd(promptLine+linesAdded, PROMPT_MARKER) end
		end

		out:EmptyUndoBuffer() -- don't allow the user to undo shell text
		out:GotoPos(out:GetLength())
		out:EnsureVisibleEnforcePolicy(out:GetLineCount()-1)
	end

	local DisplayShell = function (...) shellPrint(OUTPUT_MARKER, concat("\t", ...), true) end
	local DisplayShellErr = function (...) shellPrint(ERROR_MARKER, concat("\t", ...), true) end
	local DisplayShellMsg = function (...) shellPrint(MESSAGE_MARKER, concat("\t", ...), true) end
	local DisplayShellDirect = function (...) shellPrint(nil, concat("\t", ...), true) end
		-- don't print anything; just mark the line with a prompt mark
	local DisplayShellPrompt = function (...) out:MarkerAdd(out:GetLineCount()-1, PROMPT_MARKER) end

	function out:Print(...) return DisplayShell(...) end
	function out:Write(...) return shellPrint(OUTPUT_MARKER, concat("", ...), false) end

	local function executeShellCode(tx)
		if tx == nil or tx == '' then return end

		local forcelocalprefix = '^!'
		local forcelocal = tx:find(forcelocalprefix)
		tx = tx:gsub(forcelocalprefix, '')

		DisplayShellPrompt('')

		on_execute(tx)
	end

	out:Connect(wx.wxEVT_KEY_DOWN,
		function (event)
		-- this loop is only needed to allow to get to the end of function easily
		-- "return" aborts the processing and ignores the key
		-- "break" aborts the processing and processes the key normally
		while true do
			local key = event:GetKeyCode()
			if key == wx.WXK_UP or key == wx.WXK_NUMPAD_UP then
				-- if we are below the prompt line, then allow to go up
				-- through multiline entry
				if out:GetCurrentLine() > getPromptLine() then break end

				-- if we are not on the caret line, move normally
				if not caretOnPromptLine() then break end

				local promptText = getPromptText()
				setPromptText(getNextHistoryLine(false, promptText))
				return
			elseif key == wx.WXK_DOWN or key == wx.WXK_NUMPAD_DOWN then
				-- if we are above the last line, then allow to go down
				-- through multiline entry
				local totalLines = out:GetLineCount()-1
				if out:GetCurrentLine() < totalLines then break end

				-- if we are not on the caret line, move normally
				if not caretOnPromptLine() then break end

				local promptText = getPromptText()
				setPromptText(getNextHistoryLine(true, promptText))
				return
			elseif key == wx.WXK_TAB then
				-- if we are above the prompt line, then don't move
				local promptline = getPromptLine()
				if out:GetCurrentLine() < promptline then return end

				local promptText = getPromptText()
				-- save the position in the prompt text to restore
				local pos = out:GetCurrentPos()
				local text = promptText:sub(1, positionInLine(promptline))
				if #text == 0 then return end

				-- find the next match and set the prompt text
				local match = getNextHistoryMatch(text)
				if match then
					setPromptText(match)
					-- restore the position to make it easier to find the next match
					out:GotoPos(pos)
				end
				return
			elseif key == wx.WXK_ESCAPE then
				setPromptText("")
				return
			elseif key == wx.WXK_BACK then
				if not caretOnPromptLine(true) then return end
			elseif key == wx.WXK_DELETE or key == wx.WXK_NUMPAD_DELETE then
				if not caretOnPromptLine() or out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
					return
				end
			elseif key == wx.WXK_PAGEUP or key == wx.WXK_NUMPAD_PAGEUP
				or key == wx.WXK_PAGEDOWN or key == wx.WXK_NUMPAD_PAGEDOWN
				or key == wx.WXK_END or key == wx.WXK_NUMPAD_END
				or key == wx.WXK_HOME or key == wx.WXK_NUMPAD_HOME
				or key == wx.WXK_LEFT or key == wx.WXK_NUMPAD_LEFT
				or key == wx.WXK_RIGHT or key == wx.WXK_NUMPAD_RIGHT
				or key == wx.WXK_SHIFT or key == wx.WXK_CONTROL
				or key == wx.WXK_ALT then
				break
			elseif key == wx.WXK_RETURN or key == wx.WXK_NUMPAD_ENTER then
				if not caretOnPromptLine()
				or out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
					return
				end

			-- allow multiline entry for shift+enter
			if caretOnPromptLine(true) and event:ShiftDown() then break end

			local promptText = getPromptText()
			if #promptText == 0 then return end -- nothing to execute, exit
				if promptText == 'clear' then
					out:Erase()
				else
					DisplayShellDirect('\n')
					executeShellCode(promptText)
				end
				currentHistory = getPromptLine() -- reset history
				return -- don't need to do anything else with return
			elseif event:GetModifiers() == wx.wxMOD_NONE or out:GetSelectedText() == "" then
				-- move cursor to end if not already there
				if not caretOnPromptLine() then
					out:GotoPos(out:GetLength())
				-- check if the selection starts before the prompt line and reset it
				elseif out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
					out:GotoPos(out:GetLength())
					out:SetSelection(out:GetSelectionEnd()+1,out:GetSelectionEnd())
				end
			end
			break
		end
		event:Skip()
	end)

	local function inputEditable(line)
		return caretOnPromptLine(false, line) and
		not (out:LineFromPosition(out:GetSelectionStart()) < getPromptLine())
	end

	-- new Scintilla (3.2.1) changed the way markers move when the text is updated
	-- ticket: http://sourceforge.net/p/scintilla/bugs/939/
	-- discussion: https://groups.google.com/forum/?hl=en&fromgroups#!topic/scintilla-interest/4giFiKG4VXo
	if ide.wxver >= "2.9.5" then
		-- this is a workaround that stores a position of the last prompt marker
		-- before insert and restores the same position after (as the marker)
		-- could have moved if the text is added at the beginning of the line.
		local promptAt
		out:Connect(wxstc.wxEVT_STC_MODIFIED,
		function (event)
			local evtype = event:GetModificationType()
			if bit.band(evtype, wxstc.wxSTC_MOD_BEFOREINSERT) ~= 0 then
			local promptLine = getPromptLine()
			if promptLine and event:GetPosition() == out:PositionFromLine(promptLine)
			then promptAt = promptLine end
			end
			if bit.band(evtype, wxstc.wxSTC_MOD_INSERTTEXT) ~= 0 then
			local promptLine = getPromptLine()
			if promptLine and promptAt then
				out:MarkerDelete(promptLine, PROMPT_MARKER)
				out:MarkerAdd(promptAt, PROMPT_MARKER)
				promptAt = nil
			end
			end
		end)
	end

	out:Connect(wxstc.wxEVT_STC_UPDATEUI,
		function (event) out:SetReadOnly(not inputEditable()) end)

	-- only allow copy/move text by dropping to the input line
	out:Connect(wxstc.wxEVT_STC_DO_DROP,
		function (event)
		if not inputEditable(out:LineFromPosition(event:GetPosition())) then
			event:SetDragResult(wx.wxDragNone)
		end
		end)

	if ide.config.outputshell.nomousezoom then
		-- disable zoom using mouse wheel as it triggers zooming when scrolling
		-- on OSX with kinetic scroll and then pressing CMD.
		out:Connect(wx.wxEVT_MOUSEWHEEL,
		function (event)
			if wx.wxGetKeyState(wx.WXK_CONTROL) then return end
			event:Skip()
		end)
	end

	function out:Erase()
		self:ClearAll()
	end

	shellbox:Connect(wx.wxEVT_CONTEXT_MENU,
	function (event)
	  local menu = ide:MakeMenu {
		  { ID_UNDO, TR("&Undo") },
		  { ID_REDO, TR("&Redo") },
		  { },
		  { ID_CUT, TR("Cu&t") },
		  { ID_COPY, TR("&Copy") },
		  { ID_PASTE, TR("&Paste") },
		  { ID_SELECTALL, TR("Select &All") },
		  { },
		  { ID_CLEARCONSOLE, TR("C&lear Console Window") },
		}
	  if ide.osname == "Unix" then UpdateMenuUI(menu, shellbox) end
	  shellbox:PopupMenu(menu)
	end)

	shellbox:Connect(ID_CLEARCONSOLE, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) shellbox:Erase() end)

	return shellbox, page
end

return PLUGIN
