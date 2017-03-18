local log = hs.logger.new('init', 'debug')
log.i('Initializing')

local send = {
	escape = true,
	paren = true
}

local keycodeMap = {
	lshift = 56,
	rshift = 60,
	lctrl  = 59
}

local timers = {
	ctrl = hs.timer.delayed.new(0.15, function()
		send.escape = false
	end),
	shift = hs.timer.delayed.new(0.15, function()
		send.paren = false
	end)
}

local lastMods = hs.eventtap.checkKeyboardModifiers()

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

local ctrlToEsc = function(mods)
	if lastMods.ctrl == mods.ctrl then
		return false
	end

	if not lastMods.ctrl then
		send.escape = true
		timers.ctrl:start()
	else
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
		timers.ctrl:stop()
	end
	lastMods.ctrl = mods.ctrl

	return false
end

local modifierHandlers = {
	[keycodeMap.lctrl]  = ctrlToEsc,
	[keycodeMap.lshift] = function(mods) return shiftToParens(true, mods) end,
	[keycodeMap.rshift] = function(mods) return shiftToParens(false, mods) end
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

local viMode = {
	h = hs.keycodes.map.left,
	j = hs.keycodes.map.down,
	k = hs.keycodes.map.up,
	l = hs.keycodes.map.right
}

other_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
	send.escape = false
	send.paren = false
	if event:getFlags().fn then
		local key = viMode[event:getCharacters()]
		if key then
			-- event:setKeyCode(key)
			-- event:setFlags({ctrl = true})
			hs.eventtap.keyStroke({'ctrl'}, key, 1000)
			return true
		end
	end
	return false
end)
other_tap:start()