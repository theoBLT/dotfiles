-- lock screen shortcut
superKey:bind('s'):toFunction("Lock screen", hs.caffeinate.startScreensaver)

-- reload Hammerspoon
hyperKey:bind('h'):toFunction('Reload Hammerspoon', function()
  hs.application.launchOrFocus("Hammerspoon")
  hs.reload()
end)
