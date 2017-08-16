local setDarkMode = function(enabled)
	local script = string.format(
[[tell application "System Events"
	tell application "Alfred 3" to set theme "%s"
end tell]], enabled, enabled and 'Dark' or 'Light'
		)
	--tell appearance preferences to set dark mode to %s
	return function()
		hs.osascript.applescript(script)
	end
end

hs.timer.doAt('7:00', '1d', setDarkMode(false))
hs.timer.doAt('21:00', '1d', setDarkMode(true))

if 7 < time.hour and time.hour < 21 then
	setDarkMode(false)()
else
	setDarkMode(true)()
end
