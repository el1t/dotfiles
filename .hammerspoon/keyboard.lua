hs.hotkey.bind({}, hs.keycodes.map.f16, hs.reload)
hs.hotkey.bind({}, hs.keycodes.map.f17, hs.toggleConsole)

--[[
tap shift -> corresponding paren

lshift + asdf -> ctrl + arrows
rshift + hjkl -> vi mode
]]
--[[

-- should override input
local send = {
	paren = true,
}

local modals = {
	lshift = hs.hotkey.modal.new(),
	rshift = hs.hotkey.modal.new(),
}

-- hs.keycodes.map does not include modifiers
local keycodeMap = {
	cmd    = 55,
	lshift = 56,
	capslk = 57,
	lalt   = 58,
	lctrl  = 59,
	rshift = 60,
	ralt   = 61,
	rctrl  = 62,
	fn     = 63,
}

-- timers for delayed actions
local timers = {
	shift = hs.timer.delayed.new(0.15, function()
		send.paren = false
	end),
}

-- keys to rebind to arrow keys
local viMode = {
	[hs.keycodes.map.h] = hs.keycodes.map.left,
	[hs.keycodes.map.j] = hs.keycodes.map.down,
	[hs.keycodes.map.k] = hs.keycodes.map.up,
	[hs.keycodes.map.l] = hs.keycodes.map.right,
}

for key, code in pairs(viMode) do
	-- todo: also fire with other mods held (cmd, ctrl)
	modals.rshift:bind({'shift'}, key,
		function() hs.eventtap.event.newKeyEvent({}, code, true):post() end,
		function() hs.eventtap.event.newKeyEvent({}, code, false):post() end,
		function() hs.eventtap.event.newKeyEvent({}, code, true):post() end
	)
end

local ctrlBinds = {
	a = hs.keycodes.map.down,
	s = hs.keycodes.map.up,
	d = hs.keycodes.map.left,
	f = hs.keycodes.map.right,
}

for key, code in pairs(ctrlBinds) do
	modals.lshift:bind({'shift'}, key,
		function() hs.eventtap.event.newKeyEvent({'ctrl'}, code, true):post() end,
		function() hs.eventtap.event.newKeyEvent({'ctrl'}, code, false):post() end
	)
end

-- modifiers enabled in previous invocation
local lastMods = hs.eventtap.checkKeyboardModifiers()

-- rebind shifts to parentheses
local shiftToParens = function(left, mods)
	-- ignore if other mods are held
	if mods.ctrl or mods.alt or mods.cmd or mods.fn then
		if send.paren then
			send.paren = false
			timers.shift:stop()
		end
		return false
	end
	if not lastMods.shift then
		-- first key down
		send.paren = true
		timers.shift:start()
	elseif not mods.shift then
		-- keyup
		if send.paren then
			local key = left and '9' or '0'
			hs.eventtap.keyStroke({'shift'}, key, 1000)
		end
		timers.shift:stop()
	else -- lastMods.shift == mods.shift == true
		-- second key down
		if not send.paren then
			return false
		end
		if left then
			-- right -> left = caps lock
			-- hs.eventtap.event.newSystemKeyEvent('CAPS_LOCK', true):post()
			-- hs.timer.usleep(1000)
			-- hs.eventtap.event.newSystemKeyEvent('CAPS_LOCK', false):post()
			-- hs.eventtap.keyStroke({}, 57, 1000)
			hs.eventtap.keyStrokes('()')
		else
			-- left -> right = both shifts
			hs.eventtap.keyStrokes('()')
		end
		timers.shift:stop()
		send.paren = false
		return false
	end

	lastMods.shift = mods.shift
	return false
end

local leftShiftHandler = function(mods)
	-- disable if lshift was pressed second
	if lastMods.shift then
		modals.lshift:exit()
		modals.rshift:exit()
	else
		modals.lshift:enter()
	end
	return shiftToParens(true, mods)
end

local rightShiftHandler = function(mods)
	-- if right was pressed second
	if lastMods.shift then
		modals.lshift:exit()
		modals.rshift:exit()
	else
		modals.rshift:enter()
	end
	return shiftToParens(false, mods)
end

local modifierHandlers = {
	[keycodeMap.lshift] = leftShiftHandler,
	[keycodeMap.rshift] = rightShiftHandler,
}

local flagsChangedHandler = function(event)
	local newMods = event:getFlags()
	local keyCode = event:getKeyCode()
	-- log.i(keyCode)
	if modifierHandlers[keyCode] then
		return modifierHandlers[keyCode](newMods)
	else
		send.paren = false
		return false
	end
end

flagsChanged = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, flagsChangedHandler)
flagsChanged:start()

other_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
	send.paren = false
	return false
end)
other_tap:start()
]]