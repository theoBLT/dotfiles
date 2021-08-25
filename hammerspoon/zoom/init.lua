local MuteUi = require('zoom.mute-ui')
local statuses = require('zoom.status')

-----------------

muteStatus = MuteUi:new()

muteWatcher = hs.timer.new(0.25, function()
  local status = statuses.getStatus()

  if status == statuses.notMeeting then
    muteStatus:hide()
  else
    muteStatus:show()
    muteStatus:setMuted(status == statuses.muted)
  end
end)

zoomAppWatcher = hs.application.watcher.new(function(applicationName, eventType)
  if applicationName ~= "zoom.us" then return end

  if eventType == hs.application.watcher.launched then
    muteStatus:show()
  elseif eventType == hs.application.watcher.terminated then
    muteStatus:hide()
  end
end)

zoomAppWatcher:start()

if hs.application.find('zoom.us') then
  muteWatcher:start()
end

hyperKey:bind('z'):toFunction('Toggle mute status', function()
  muteStatus:toggle()
end)
