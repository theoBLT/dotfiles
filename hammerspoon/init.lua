hs.loadSpoon("SpoonInstall")

require "config-watch"
require "window-management"
require "key-bindings"
require "mute-on-sleep"
require "audio-switcher"

local logger = hs.logger.new('exp', 'debug')

-- local vim = hs.loadSpoon('VimMode')

-- vim:disableForApp('zoom.us')
-- vim:disableForApp('iTerm')
-- vim:disableForApp('iTerm2')

-- vim:enableKeySequence('j', 'k')

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
-- http://lua-users.org/wiki/SimpleLuaClasses
function class(base, init)
  local c = {}    -- a new class instance

  if not init and type(base) == 'function' then
    init = base
    base = nil
  elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
    for i, value in pairs(base) do
      c[i] = value
    end

    c._base = base
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c

  -- expose a constructor which can be called by <classname>(<args>)
  local mt = {}

  mt.__call = function(class_tbl, ...)
    local obj = {}
    setmetatable(obj,c)

    if init then
      init(obj,...)
    else
      -- make sure that any stuff from the base class is initialized!
      if base and base.init then
        base.init(obj, ...)
      end
    end

    return obj
  end

  c.init = init

  c.is_a = function(self, klass)
    local m = getmetatable(self)

    while m do
      if m == klass then return true end
      m = m._base
    end

    return false
  end

  setmetatable(c, mt)

  return c
end

local vim = {
  state = {
    operation = nil,
    motion = nil
  }
}

local vimMode = hs.hotkey.modal.new()

local function exitVim()
  vimMode:exit()
end

local function handlerWithWrapper(fn)
  return function()
    fn()
  end
end

local function bindHandler(mods, key, fn)
  local wrappedFn = handlerWithWrapper(fn)
  vimMode:bind(mods, key, nil, wrappedFn, nil, wrappedFn)
end

local Thing = class()

function Thing:run()
end

local Motion = class(Thing)

function Motion:run()
end

local motions = {}

motions.word = class(Motion)

function motions.word:selection()
end

local function keyStroke(modifiers, key, delay)
  delay = delay or 0

  return hs.eventtap.keyStroke(modifiers, key, delay)
end

local function copyAndWait()
  local count = hs.pasteboard.changeCount()

  local result = keyStroke({'cmd'}, 'c')

  while count == hs.pasteboard.changeCount() do
  end

  return result
end

local function getCurrentSelection(callbackFn)
  local oldClipboard = hs.pasteboard.getContents()
  local changeCount = hs.pasteboard.changeCount()

  local function copyHasFired()
    return changeCount < hs.pasteboard.changeCount()
  end

  keyStroke({'cmd'}, 'c')

  local timer
  local timeout
  local copied = false

  timeout = hs.timer.doAfter(0.03, function()
    timeout:stop()

    if not copied then
      timer:stop()

      hs.pasteboard.setContents(oldClipboard)
      callbackFn(selection)
    end
  end)

  timer = hs.timer.waitUntil(copyHasFired, function ()
    copied = true

    local selection = hs.pasteboard.getContents()

    hs.pasteboard.setContents(oldClipboard)
    callbackFn(selection)
  end, 0.005)
end

  -- while hs.pasteboard.getContents() ~= "__selectionrange__" do
  -- end

  -- logger.i("past the first one")

  -- keyStroke({'cmd'}, 'c')

  -- while hs.pasteboard.getContents() == "__selectionrange__" do
  -- end

  -- logger.i("past the second one")

  -- local contents = hs.pasteboard.getContents()
  -- logger.i(contents)


  -- keyStroke({'cmd','shift'}, 'right')
  -- copyAndWait()

  -- local rightSide = hs.pasteboard.getContents()

  -- logger.i(rightSide)
  -- return "ok"

  -- if rightSide ~= "" then
  --   hs.eventtap.keyStroke({}, 'left')
  -- end

  -- hs.pasteboard.setContents("")

  -- hs.eventtap.keyStroke({'cmd','shift'}, 'left')
  -- hs.eventtap.keyStroke({'cmd'}, 'c')

  -- local leftSide = hs.pasteboard.getContents()

  -- if leftSide ~= "" then
  --   hs.eventtap.keyStroke({}, 'right')
  -- end

  -- return {
  --   left = leftSide,
  --   right = rightSide,
  --   selection = {
  --     position = string.len(leftSide),
  --     length = 0
  --   }
  -- }


-- TODO ui sfx
-- defaults write com.apple.systemsound 'com.apple.sound.uiaudio.enabled' -int 0
local key = hs.hotkey.new({ "cmd", "alt", "ctrl" }, "0", nil, function()
  local selectionLength = 0

  getCurrentSelection(function(selection)
    if selection then
      selectionLength = string.len(selection)
      keyStroke({}, 'left')
    else
      logger.i("no selection")
    end

    logger.i("going left")
    keyStroke({'cmd','shift'}, 'left')

    getCurrentSelection(function(leftSide)
      if leftSide then keyStroke({}, 'right') end

      local position = leftSide and string.len(leftSide) or 0

      keyStroke({'cmd','shift'}, 'right')

      getCurrentSelection(function(rightSide)
        if rightSide then keyStroke({}, 'left') end

        local context = {
          leftSide = leftSide,
          rightSide = rightSide,
          selection = {
            position = position,
            length = selectionLength
          }
        }

        logger.i(hs.inspect.inspect(context))
      end)
    end)
  end)
end)

key:enable()
