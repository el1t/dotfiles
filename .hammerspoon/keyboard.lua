--[[
tap ctrl  -> escape
tap shift -> corresponding paren

rshift + hjkl -> ctrl + arrows
hold delay ctrl + hjkl -> vi mode
]]

-- should override input
local send = {
	escape = true,
	paren = true,
	viMode = false,
	viCtrlMode = false
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
		send.viMode = true
	end)
}

-- keys to rebind to arrow keys
local viMode = {
	[hs.keycodes.map.h] = hs.keycodes.map.left,
	[hs.keycodes.map.j] = hs.keycodes.map.down,
	[hs.keycodes.map.k] = hs.keycodes.map.up,
	[hs.keycodes.map.l] = hs.keycodes.map.right
}

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
	send.viMode = false
	lastMods.ctrl = mods.ctrl

	return false
end

local leftShiftHandler = function(mods)
	-- if left was pressed second
	if lastMods.shift then
		send.viCtrlMode = false
	end
	return shiftToParens(true, mods)
end

local rightShiftHandler = function(mods)
	-- enable if right shift was pressed first
	send.viCtrlMode = not lastMods.shift
	return shiftToParens(false, mods)
end

local modifierHandlers = {
	[keycodeMap.lctrl]  = ctrlToEsc,
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
	-- if event:getFlags().fn then
	if send.viMode or send.viCtrlMode then
		local key = viMode[event:getKeyCode()]
		if key then
			-- event:setKeyCode(key)
			-- event:setFlags({ctrl = true})
			hs.eventtap.keyStroke({send.viCtrlMode and 'ctrl' or nil}, key, 1000)
			return true
		end
	end
	return false
end)
other_tap:start()