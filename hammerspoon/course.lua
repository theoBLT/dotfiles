local onModifierHold = require('which-key.on-modifier-hold')
local Overlay = require('which-key.overlay')

------------------------------------------

local WhichKey = {}

function WhichKey:new(modifiers)
  local instance = {}

  setmetatable(instance, self)
  self.__index = self

  instance.modifiers = modifiers

  -- For now, we'll fake the keybindings to make sure this is working correctly.
  instance.keyBindings = {
    { key = "b", binding = { name = "Toggle headphones" } },
    { key = "c", binding = { name = "Google Chrome" } },
    { key = "h", binding = { name = "Reload Hammerspoon" } },
    { key = "s", binding = { name = "Spotify" } },
    { key = "t", binding = { name = "Terminal" } },
    { key = "w", binding = { name = "Switch monitor input" } },
  }

  instance.overlay = Overlay:new(instance.keyBindings)

  local overlayTimeoutMs = 250 -- wait 250ms before showing overlay

  -- Show our Overlay on hold
  local onHold = function()
    instance.overlay:show()
  end

  -- Hide it on release
  local onRelease = function()
    instance.overlay:hide()
  end

  -- Create and start the "modifiers held" listener
  instance.holdTap = onModifierHold(
    modifiers,
    overlayTimeoutMs,
    onHold,
    onRelease
  )

  return instance
end

-- theKey = WhichKey:new({'cmd'})
