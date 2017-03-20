--[[
tap rctrl  -> escape
tap shift -> corresponding paren

lshift + asdf -> ctrl + arrows
hold delay ctrl + hjkl -> vi mode
]]

-- should override input
local send = {
	escape = true,
	paren = true
}

local modals = {
	lshift = hs.hotkey.modal.new(),
	rctrl = hs.hotkey.modal.new()
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
	fn     = 63
}

-- timers for delayed actions
local timers = {
	ctrl = hs.timer.delayed.new(0.15, function()
		send.escape = false
	end),
	shift = hs.timer.delayed.new(0.15, function()
		send.paren = false
	end),
	viMode = hs.timer.delayed.new(0.20, function()
		modals.rctrl:enter()
	end)
}

-- keys to rebind to arrow keys
local viMode = {
	[hs.keycodes.map.h] = hs.keycodes.map.left,
	[hs.keycodes.map.j] = hs.keycodes.map.down,
	[hs.keycodes.map.k] = hs.keycodes.map.up,
	[hs.keycodes.map.l] = hs.keycodes.map.right
}

for key, code in pairs(viMode) do
	modals.rctrl:bind({'ctrl'}, key,
		function() hs.eventtap.event.newKeyEvent({}, code, true):post() end,
		function() hs.eventtap.event.newKeyEvent({}, code, false):post() end,
		function() hs.eventtap.event.newKeyEvent({}, code, true):post() end)
end

local ctrlBinds = {
	a = hs.keycodes.map.down,
	s = hs.keycodes.map.up,
	d = hs.keycodes.map.left,
	f = hs.keycodes.map.right
}

for key, code in pairs(ctrlBinds) do
	modals.lshift:bind({'shift'}, key,
		function() hs.eventtap.event.newKeyEvent({'ctrl'}, code, true):post() end,
		function() hs.eventtap.event.newKeyEvent({'ctrl'}, code, false):post() end)
end

-- modifiers enabled in previous invocation
local lastMods = hs.eventtap.checkKeyboardModifiers()

-- rebind shifts to parentheses
local shiftToParens = function(left, mods)
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

-- rebind control to escape + enable vi mode when delayed
local ctrlToEsc = function(mods)
	if lastMods.ctrl == mods.ctrl then
		return false
	end

	if not lastMods.ctrl then
		-- pressing down ctrl
		send.escape = true
		timers.ctrl:start()
		timers.viMode:start()
	else
		-- letting go of ctrl
		if send.escape then
			-- prevent exiting fullscreen in Safari
			if hs.application.frontmostApplication():name() == 'Safari' then
				local role = hs.uielement.focusedElement()
				role = role and role:role()
				if role == 'AXTextArea' or role == 'AXTextField' then
					hs.eventtap.keyStroke({'cmd'}, '.', 1000)
				else
					hs.eventtap.keyStroke({'alt'}, 'escape', 1000)
				end
			else
				-- emit escape for 1ms
				hs.eventtap.keyStroke({}, 'escape', 1000)
			end
		end
		timers.viMode:stop()
		timers.ctrl:stop()
	end
	modals.rctrl:exit()
	lastMods.ctrl = mods.ctrl

	return false
end

local leftShiftHandler = function(mods)
	-- enable if left shift was pressed first
	if not lastMods.shift then
		modals.lshift:enter()
	else
		modals.lshift:exit()
	end
	return shiftToParens(true, mods)
end

local rightShiftHandler = function(mods)
	-- if right was pressed second
	if lastMods.shift then
		modals.lshift:exit()
	end
	return shiftToParens(false, mods)
end

local modifierHandlers = {
	[keycodeMap.rctrl]  = ctrlToEsc,
	[keycodeMap.lshift] = leftShiftHandler,
	[keycodeMap.rshift] = rightShiftHandler
}

-- set default to noop
setmetatable(modifierHandlers, {
	__index = function()
		return function(mods)
			return false
		end
	end
})

local flagsChangedHandler = function(event)
	local newMods = event:getFlags()
	local keyCode = event:getKeyCode()
	-- log.i(keyCode)
	return modifierHandlers[keyCode](newMods)
end

flagsChanged = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, flagsChangedHandler)
flagsChanged:start()

other_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
	send.escape = false
	send.paren = false
	return false
end)
other_tap:start()