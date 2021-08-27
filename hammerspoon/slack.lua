local function clearCursorFromMessageBox()
  local app = hs.application.find("Slack")
  if not app then return end

  local window = app:mainWindow()
  window:focus()

  local frame = window:frame()
  local click = {
    x = frame.x + frame.w - 100,
    y = frame.y + 20,
  }

  local previousMousePosition = hs.mouse.absolutePosition()

  hs.eventtap.leftClick(click, 0)
  hs.mouse.absolutePosition(previousMousePosition) -- restore it
end

local function focusSlackMessageBox()
  clearCursorFromMessageBox()

  -- hs.eventtap.keyStroke({'shift'}, 'F6', 0)
end

local function openSlackReminder()
  hs.application.launchOrFocus("Slack")

  hs.timer.doAfter(0.3, function()
    focusSlackMessageBox()

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
  focusSlackMessageBox()
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

-- slackModal:bind({'ctrl'}, 'h', nil, findBox, nil, findBox)
slackModal:bind({'ctrl'}, 'j', nil, slackDown, nil, slackDown)
slackModal:bind({'ctrl'}, 'k', nil, slackUp, nil, slackUp)
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
