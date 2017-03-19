log = hs.logger.new('init', 'debug')
log.i('Initializing')

local rawTime = hs.timer.localTime()
time = {
	hour   = rawTime // 3600,
	minute = rawTime % 3600 // 60,
	second = rawTime % 60
}

modules = {'keyboard', 'darkmode'}
for i, m in ipairs(modules) do
	require(m)
end