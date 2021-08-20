-- local function enableDoNotDisturb()
--   hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true")
--   hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date \"`date -u +\"%Y-%m-%d %H:%M:%S +000\"`\"")
--   hs.execute("killall NotificationCenter")
-- end

local function enableDoNotDisturb()
  hs.osascript.applescript(
    [[
set checkboxName to "Do Not
Disturb"

tell application "System Events"
  click menu bar item "Control Center" of menu bar 1 of application process "ControlCenter"
  delay 0.1

  set isChecked to (value of checkbox checkboxName of group 1 of group 1 of window "Control Center" of application process "ControlCenter")

  if not (isChecked as boolean) then
    click checkbox checkboxName of group 1 of group 1 of window "Control Center" of application process "ControlCenter"
    delay 0.1
  end if

  click menu bar item "Control Center" of menu bar 1 of application process "ControlCenter"
end tell
    ]]
  )
end

local function enablePairingMode()
  enableDoNotDisturb()

  -- close embarrassing personal apps
  hs.execute("killall Signal")
  hs.execute("killall Messages")

  hs.alert("Entering pairing mode")
end

hyperKey:bind('p'):toFunction("Enable pairing mode", enablePairingMode)
