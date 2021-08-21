-- Turn off animations.
hs.window.animationDuration = 0

-- No margins between windows.
hs.grid.setMargins('0, 0')

local function setGridForScreens()
  -- Set screen grid depending on resolution
  for _, screen in pairs(hs.screen.allScreens()) do
    if screen:frame().w / screen:frame().h > 2 then
      -- 10 * 4 for ultra wide screen
      hs.grid.setGrid('10 * 4', screen)
    else
      if screen:frame().w < screen:frame().h then
        -- 4 * 8 for vertically aligned screen
        hs.grid.setGrid('4 * 8', screen)
      else
        -- 8 * 4 for normal screen
        hs.grid.setGrid('8 * 4', screen)
      end
    end
  end
end

-- Call this once on config load.
setGridForScreens()

-- Set screen watcher, in case you connect a new monitor, or unplug a monitor
local screenWatcher = hs.screen.watcher.new(function()
  setGridForScreens()
end)

screenWatcher:start()

-- Create a handy struct to hold the current window/screen and their grids.
local windowMeta = {}

-- Bind new method to windowMeta
function windowMeta.new()
  local self = {}

  self.window = hs.window.focusedWindow()
  self.screen = self.window:screen()
  self.windowGrid = hs.grid.get(self.window)
  self.screenGrid = hs.grid.getGrid(self.screen)

  return self
end

--------------------------------------
-- Configure module functions
--------------------------------------

local module = {}

-- Maximizes a window to fit the entire grid.
module.maximizeWindow = function ()
  local this = windowMeta.new()
  hs.grid.maximizeWindow(this.window)
end

-- Centers a window in the middle of the screen.
module.centerOnScreen = function ()
  local this = windowMeta.new()
  this.window:centerOnScreen(this.screen)
end

-- Throws a window 1 screen to the left
module.throwLeft = function ()
  local this = windowMeta.new()
  this.window:moveOneScreenWest()
end

-- Throws a window 1 screen to the right
module.throwRight = function ()
  local this = windowMeta.new()
  this.window:moveOneScreenEast()
end

-- 1. Moves a window all the way left
-- 2. Resizes it to take up the left half of the screen (grid)
module.leftHalf = function ()
  local this = windowMeta.new()
  local cell = hs.geometry(0, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- 1. Moves a window all the way right
-- 2. Resizes it to take up the right half of the screen (grid)
module.rightHalf = function ()
  local this = windowMeta.new()
  local cell = hs.geometry(0.5 * this.screenGrid.w, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- 1. Moves a window all the way to the top
-- 2. Resizes it to take up the top half of the screen (grid)
module.topHalf = function ()
  local this = windowMeta.new()
  local cell = hs.geometry(0, 0, this.screenGrid.w, 0.5 * this.screenGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- 1. Moves a window all the way to the bottom
-- 2. Resizes it to take up the bottom half of the screen (grid)
module.bottomHalf = function ()
  local this = windowMeta.new()
  local cell = hs.geometry(0, 0.5 * this.screenGrid.h, this.screenGrid.w, 0.5 * this.screenGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- Shrinks a window's size horizontally to the left.
module.shrinkLeft = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- Grows a window's size horizontally to the right.
module.growRight = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- Shrinks a window's size vertically up.
module.shrinkUp = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h - 1)

  hs.grid.set(this.window, cell, this.screen)
end

-- Grows a window's size vertically down.
module.growDown = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h + 1)

  hs.grid.set(this.window, cell, this.screen)
end

module.nudgeLeft = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x - 1, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

module.nudgeRight = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x + 1, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

module.nudgeUp = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y - 1, this.windowGrid.w, this.windowGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

module.nudgeDown = function()
  local this = windowMeta.new()
  local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y + 1, this.windowGrid.w, this.windowGrid.h)

  hs.grid.set(this.window, cell, this.screen)
end

-- module.leftToLeft = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x - 1, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)

--   if this.windowGrid.x > 0 then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Touching Left Edge :|")
--   end
-- end

-- module.leftToRight = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x + 1, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)

--   if this.windowGrid.w > 1 then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Small Enough :)")
--   end
-- end

-- module.rightToLeft = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)

--   if this.windowGrid.w > 1 then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Small Enough :)")
--   end
-- end

-- module.rightToRight = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)
--   if this.windowGrid.w < this.screenGrid.w - this.windowGrid.x then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Touching Right Edge :|")
--   end
-- end

-- -- Resizes the window from the bottom edge, in the up direction (making it smaller).
-- module.bottomUp = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h - 1)

--   if this.windowGrid.h > 1 then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Small Enough :)")
--   end
-- end

-- -- Resizes the window from the bottom edge, in the down direction (making it larger).
-- module.resizeDown = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h + 1)
--   if this.windowGrid.h < this.screenGrid.h - this.windowGrid.y then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Touching Bottom Edge :|")
--   end
-- end

-- -- Resizes the window from the top edge, in the up direction (making it larger).
-- module.topUp = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y - 1, this.windowGrid.w, this.windowGrid.h + 1)
--   if this.windowGrid.y > 0 then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Touching Top Edge :|")
--   end
-- end

-- module.topDown = function ()
--   local this = windowMeta.new()
--   local cell = hs.geometry(this.windowGrid.x, this.windowGrid.y + 1, this.windowGrid.w, this.windowGrid.h - 1)
--   if this.windowGrid.h > 1 then
--     hs.grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Small Enough :)")
--   end
-- end

return module
