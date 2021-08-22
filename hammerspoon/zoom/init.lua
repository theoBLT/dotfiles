local MuteStatus = require('zoom.mute-status')

local function isZoomMuted()
  local script = [[
    property btnTitle : "Mute audio"

    if application "zoom.us" is running then
      tell application "System Events"
        tell application process "zoom.us"
          if exists (menu item btnTitle of menu 1 of menu bar item "Meeting" of menu bar 1) then
            set returnValue to "Unmuted"
          else
            set returnValue to "Muted"
          end if
        end tell
      end tell
    else
      set returnValue to ""
    end if

    return returnValue
  ]]

  local _, value = hs.osascript.applescript(script)

  return value == "Muted"
end

muteStatus = MuteStatus:new()

muteWatcher = hs.timer.new(0.25, function()
  muteStatus:setMuted(isZoomMuted())
end)

muteWatcher:start()

zoomAppWatcher = hs.application.watcher.new(function(applicationName, eventType)
  if applicationName ~= "zoom.us" then return end

  if eventType == hs.application.watcher.launched then
    muteStatus:show()
  elseif eventType == hs.application.watcher.terminated then
    muteStatus:hide()
  end
end)

zoomAppWatcher:start()

hyperKey:bind('z'):toFunction('Toggle mute status', function()
  muteStatus:toggle()
end)
