local ax = require('autocomplete.ax')

local function withMeasurement(name, fn)
  local logger = hs.logger.new('timer', 'debug')

  local startTime = hs.timer.absoluteTime()

  fn()

  local endTime = hs.timer.absoluteTime()

  local diffNs = endTime - startTime
  local diffMs = diffNs / 1000000

  logger.i(name .. "took: " .. diffMs .. "ms")
end

local getSortedResults = nil

withMeasurement("load", function()
  getSortedResults = require('autocomplete.search')
end)

withMeasurement("search", function()
  getSortedResults("app")
end)

hs.hotkey.bind(hyper, '4', function()
  p("Current word: " .. ax.getCurrentWord())
end)

local t = hs.eventtap.new({ hs.eventtap.event.types.cursorUpdate }, function(event)
  p("Cursor update")
  return false
end)

t:start()
