local bindKeySequence = require('vim-mode/bind-key-sequence')
local extendedModes = require('./vim-mode/extended-modes')
local motions = require('./vim-mode/motions')
local operators = require('./vim-mode/operators')
local utils = require('vim-mode/utils')

local function compose(...)
  local fns = {...}

  return function()
    for _, fn in ipairs(fns) do
      fn()
    end
  end
end

VimMode = {
  afterExitHooks = nil,
  commandState = nil,
  entered = false,
  enabled = true,
  mode = nil,
  sequence = nil
}

VimMode.buildCommandState = function()
  return {
    selection = false,
    visualMode = false,
    operatorFn = nil,
    motionDirection = 'forward'
  }
end

VimMode.dimScreen = function()
  hs.screen.primaryScreen():setGamma(
    {alpha=1.0,red=0.0,green=0.0,blue=0.0},
    {blue=0.0,green=1.0,red=0.0}
  )
end

VimMode.restoreDim = function()
  hs.screen.restoreGamma()
end

VimMode.new = function()
  local self = utils.deepcopy(VimMode)

  self.afterExitHooks = {}
  self.commandState = VimMode.buildCommandState()
  self.entered = false
  self.enabled = true
  self.mode = hs.hotkey.modal.new()

  self.sequence = {
    tap = nil,
    waitingForPress = false
  }

  self.watchers = {}

  return self
end

function VimMode:disable()
  hs.alert.show('disabling vim')
  self.enabled = false
end

function VimMode:resetState()
  self.commandState = VimMode.buildCommandState()
end

function VimMode:enable()
  hs.alert.show('enabling vim')
  self:resetState()
  self.enabled = true
end

function VimMode:disableForApp(disabledApp)
  local watcher =
    hs.application.watcher.new(function(applicationName, eventType)
      if disabledApp ~= applicationName then return end

      if eventType == hs.application.watcher.activated then
        self:exit()
        self:disable()
      elseif eventType == hs.application.watcher.deactivated then
        self:enable()
      end
    end)

  watcher:start()

  self.watchers[disabledApp] = watcher
end

function VimMode:enter()
  if self.enabled then
    hs.alert.show('vim.enter() entering')
    self.mode:enter()

    self.entered = true
    self:resetState()

    VimMode.dimScreen()
  else
    hs.alert.show('skipping')
  end
end

function VimMode:registerAfterExit(fn)
  table.insert(self.afterExitHooks, fn)
end

function VimMode:exit()
  self.mode:exit()

  VimMode.restoreDim()
  self.entered = false

  self:runAfterExitHooks()
end

function VimMode:runAfterExitHooks()
  for _, fn in ipairs(self.afterExitHooks) do
    fn()
  end
end

function VimMode:runOperator()
  if self.commandState.operatorFn then
    self.commandState.operatorFn(self)
    self:resetState()
  end
end

function VimMode:restoreCursor()
  if self.commandState.motionDirection == 'forward' then
    utils.sendKeys({}, 'left')
  else
    utils.sendKeys({}, 'right')
  end
end

function VimMode:enableKeySequence(key1, key2, modifiers)
  modifiers = modifiers or {}

  local waitingForPress = false
  local maxDelay = 200

  self.sequence.tap =
    hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
      if not self.enabled or self.entered then
        return false
      end

      local hasModifiers = event:getFlags():containExactly(modifiers)
      local keyPressed = hs.keycodes.map[event:getKeyCode()]

      hs.alert.show(keyPressed)

      if hasModifiers and keyPressed == key1 then
        hs.alert.show('waiting')
        self.sequence.waitingForPress = true

        hs.timer.doAfter(maxDelay / 1000, function()
          if not self.sequence.waitingForPress then return end
          self.sequence.waitingForPress = false

          hs.alert.show('canceling')
          self.sequence.tap:stop()

          utils.sendKeys(modifiers, key1)

          self.sequence.tap:start()
        end)

        return true
      end

      if self.sequence.waitingForPress then
        self.sequence.waitingForPress = false

        if hasModifiers and keyPressed == key2 then
          hs.alert.show('entering vim')
          self.sequence.tap:stop()
          self:enter()

          return true
        else
          -- Pass thru the first key as well as the second one if we aren't
          -- typing the sequence.
          utils.sendKeys(modifiers, key1)
          return false
        end
      end

      return false
    end)

  self:registerAfterExit(function()
    hs.alert.show('vim.afterExit')
    self.sequence.tap:start()
  end)

  self.sequence.tap:start()
end

function VimMode:isSelection()
  return not not self.commandState.selection
end

function VimMode:isVisualMode()
  return not not self.commandState.visualMode
end

function VimMode:toggleVisualMode()
  self.commandState.visualMode = true
  self.commandState.selection = not self.commandState.selection
end

function VimMode:bindHotKeys()
  local exit = function() self:exit() end

  local isNormalMode = function(fn)
    return function()
      if not self.commandState.visualMode then fn() end
    end
  end

  ------------ exiting
  self.mode:bind({}, 'i', exit)

  ------------ motions
  self.mode:bind({}, 'b', motions.backWord(self), nil, motions.backWord(self))
  self.mode:bind({}, 'w', motions.word(self), nil, motions.word(self))
  self.mode:bind({}, 'h', motions.left(self), nil, motions.left(self))
  self.mode:bind({}, 'j', motions.down(self), nil, motions.down(self))
  self.mode:bind({}, 'k', motions.up(self), nil, motions.up(self))
  self.mode:bind({}, 'l', motions.right(self), nil, motions.right(self))
  self.mode:bind({}, '0', motions.beginningOfLine(self), nil, motions.beginningOfLine(self))
  self.mode:bind({'shift'}, '4', motions.endOfLine(self), nil, motions.endOfLine(self))
  self.mode:bind({'shift'}, 'l', motions.endOfLine(self), nil, motions.endOfLine(self))
  self.mode:bind({'shift'}, 'g', motions.endOfText(self), nil, motions.endOfText(self))

  ------------ operators
  self.mode:bind({}, 'c', operators.change(self))
  self.mode:bind({}, 'd', operators.delete(self))
  self.mode:bind({}, 'p', operators.paste(self))
  self.mode:bind({}, 'u', operators.undo(self))
  self.mode:bind({}, 'y', operators.yank(self))

  ------------ shortcuts

  local deleteUnderCursor = compose(
    operators.delete(self),
    isNormalMode(motions.right(self))
  )

  local searchAhead = function()
    utils.sendKeys({'command'}, 'f')
  end

  local newLineBelow = function()
    utils.sendKeys({'command'}, 'right')
    self:exit()
    utils.sendKeys({}, 'Return')
  end

  local newLineAbove = function()
    utils.sendKeys({'command'}, 'left')
    self:exit()
    utils.sendKeys({}, 'Return')
    utils.sendKeys({}, 'up')
  end

  self.mode:bind({'shift'}, 'a', compose(motions.endOfLine(self), exit))
  self.mode:bind({'shift'}, 'c', compose(operators.change(self), motions.endOfLine(self)))
  self.mode:bind({'shift'}, 'i', compose(motions.beginningOfLine(self), exit))
  self.mode:bind({'shift'}, 'd', compose(operators.delete(self), motions.endOfLine(self)))
  self.mode:bind({}, 's', compose(deleteUnderCursor, exit))
  self.mode:bind({}, 'x', deleteUnderCursor)
  self.mode:bind({}, 'o', newLineBelow)
  self.mode:bind({'shift'}, 'o', newLineAbove)
  self.mode:bind({'ctrl'}, '8', function() hs.alert.show('hi') end)

  ---------- commands
  self.mode:bind({}, '/', searchAhead)
  self.mode:bind({}, 'v', vim.toggleVisualMode)
  self.mode:bind({}, 'r', extendedModes.replace(self))
end

return VimMode
