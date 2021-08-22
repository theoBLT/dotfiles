-----------------------------------------

local onModifierHold = require('which-key.on-modifier-hold')
local bindings = require('which-key.bindings')
local Overlay = require('which-key.overlay')

----------------------------------------------------------------

local WhichKey = {}

function WhichKey:new(modifiers, options)
  options = options or {}
  local overlayTimeoutMs = options.overlayTimeoutMs or 250

  local instance = {}

  setmetatable(instance, self)
  self.__index = self

  instance.modifiers = modifiers
  instance.bindings = {}
  instance.overlay = Overlay:new(self.bindings)
  instance.holdTap = instance:_createOverlayTap(modifiers, overlayTimeoutMs)

  return instance
end

function WhichKey:bind(displayedKey, bindKey)
  bindKey = bindKey or displayedKey

  return {
    toApplication = function(_, applicationName)
      return self:_bind(
        displayedKey,
        bindKey,
        bindings.ApplicationBinding:new(applicationName)
      )
    end,
    toFunction = function(_, name, fn)
      return self:_bind(
        displayedKey,
        bindKey,
        bindings.FunctionBinding:new(name, fn)
      )
    end
  }
end

function WhichKey:_bind(key, bindKey, binding)
  table.insert(self.bindings, {
    key = string.upper(key),
    bindKey = bindKey,
    binding = binding
  })

  self.overlay = Overlay:new(self.bindings)

  hs.hotkey.bind(self.modifiers, bindKey, function()
    binding:launch()
  end)

  return self
end

function WhichKey:_createOverlayTap(modifiers, overlayTimeoutMs)
  local onHold = function()
    self.overlay:show()
  end

  local onRelease = function()
    self.overlay:hide()
  end

  return onModifierHold(modifiers, overlayTimeoutMs, onHold, onRelease)
end

return WhichKey
