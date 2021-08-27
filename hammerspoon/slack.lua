local function getSlackWindow()
  local app = hs.application.find("Slack")
  if not app then return end

  local window = app:mainWindow()
  window:focus()

  return window
end

local function fakeClick(point)
  local previousMousePosition = hs.mouse.absolutePosition()
  hs.eventtap.leftClick(point, 0)
  hs.mouse.absolutePosition(previousMousePosition) -- restore it
end

local function clearCursorToMainPane()
  local window = getSlackWindow()

  local frame = window:frame()
  local click = {
    x = frame.x + frame.w / 3,
    y = frame.y + frame.h - 8,
  }

  fakeClick(click)
end

local function clearCursorToThreadPane()
  local window = getSlackWindow()

  local frame = window:frame()
  local click = {
    x = frame.x + frame.w - 20,
    y = frame.y + frame.h - 8,
  }

  fakeClick(click)
end

local function focusMainMessageBox()
  clearCursorToMainPane()
  hs.eventtap.keyStroke({'shift'}, 'F6', 0)
end

-- TODO this doesn't work
local function focusThreadMessageBox()
  clearCursorToThreadPane()
  -- hs.eventtap.keyStroke({}, 'F6', 0)
end

local function openSlackReminder()
  hs.application.launchOrFocus("Slack")

  hs.timer.doAfter(0.3, function()
    focusMainMessageBox()

    hs.timer.doAfter(0.3, function()
      hs.eventtap.keyStrokes("/remind me at ")
    end)
  end)
end

hyperKey:bind('r'):toFunction("Slack /remind", openSlackReminder)

slackModal = hs.hotkey.modal.new()

local function slackUp()
  hs.eventtap.keyStroke({}, 'up', 0)
end

local function slackDown()
  hs.eventtap.keyStroke({}, 'down', 0)
end

local function slackThread()
  focusMainMessageBox()
  slackUp()

  hs.eventtap.keyStroke({}, 't', 0)

  hs.timer.doAfter(0.3, function()
    hs.eventtap.keyStroke({}, 'tab', 0)
    hs.eventtap.keyStroke({}, 'tab', 0)
    hs.eventtap.keyStroke({}, 'tab', 0)
    hs.eventtap.keyStroke({}, 'tab', 0)
    hs.eventtap.keyStroke({}, 'tab', 0)
    hs.eventtap.keyStroke({}, 'tab', 0)
    hs.eventtap.keyStroke({}, 'tab', 0)
  end)
end

local function findBox()
  local app = hs.application.find("Slack")
  if not app then return end

  local ax = hs.axuielement.applicationElement(app)
  local query = hs.axuielement.searchCriteriaFunction({
    attribute = "AXType",
    value = "AXTextArea",
  })

  ax:elementSearch(
    function(msg, results, count)
      p(msg)
      p(results)
      p(count)
    end,
    query
  )
end

-- slackModal:bind({'ctrl'}, 'h', nil, focusMainMessageBox, nil, focusMainMessageBox)
slackModal:bind({'ctrl'}, 'j', nil, slackDown, nil, slackDown)
slackModal:bind({'ctrl'}, 'k', nil, slackUp, nil, slackUp)
-- slackModal:bind({'ctrl'}, 'l', nil, focusThreadMessageBox, nil, focusThreadMessageBox)
slackModal:bind({'ctrl'}, 't', nil, slackThread, nil, slackThread)

slackWatcher = hs.application.watcher.new(function(applicationName, eventType)
  if applicationName ~= "Slack" then return end

  if eventType == hs.application.watcher.activated then
    slackModal:enter()
  elseif eventType == hs.application.watcher.deactivated then
    slackModal:exit()
  end
end)

slackWatcher:start()
