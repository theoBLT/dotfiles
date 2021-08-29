local find = require('slack.find')

----------

local function getAxSlackWindow()
  local app = hs.application.find("Slack")
  if not app then return end

  -- Electron apps require this attribute to be set or else you cannot
  -- read the accessibility tree
  axApp = hs.axuielement.applicationElement(app)
  axApp:setAttributeValue('AXManualAccessibility', true)

  local window = app:mainWindow()
  window:focus()

  return hs.axuielement.windowElement(window)
end

local function hasClass(element, class)
  local classList = element:attributeValue('AXDOMClassList')
  if not classList then return false end

  return hs.fnutils.contains(classList, class)
end

-----------

local module = {}

module.mainMessageBox = function()
  local window = getAxSlackWindow()
  if not window then return end

  local textarea = find.searchByChain(window, {
    function(elem) return hasClass(elem, 'p-workspace-layout') end,
    function(elem) return elem:attributeValue('AXSubrole') == 'AXLandmarkMain' end,
    function(elem) return hasClass(elem, 'p-workspace__primary_view_contents') end,
    function(elem) return hasClass(elem, 'c-wysiwyg_container') end,
    function(elem) return elem:attributeValue('AXRole') == 'AXTextArea' end,
  })

  if textarea then
    textarea:setAttributeValue('AXFocused', true)
  end
end

module.threadMessageBox = function(withRetry)
  withRetry = withRetry or false

  local window = getAxSlackWindow()
  if not window then return end

  local findTextarea = function()
    return find.searchByChain(window, {
      function(elem) return hasClass(elem, 'p-workspace-layout') end,
      function(elem) return hasClass(elem, 'p-flexpane') end,
      function(elem) return hasClass(elem, 'p-threads_flexpane') end,
      function(elem) return hasClass(elem, 'c-wysiwyg_container') end,
      function(elem) return elem:attributeValue('AXRole') == 'AXTextArea' end,
    })
  end

  local textarea = nil

  local textareaVisible = function()
    textarea = findTextarea()
    return not not textarea
  end

  local focusTextarea = function()
    textarea:setAttributeValue('AXFocused', true)
  end

  if withRetry then
    -- Do it in a retry loop
    local loopTimer = hs.timer.waitUntil(textareaVisible, focusTextarea)

    -- Give up after 2 seconds
    hs.timer.doAfter(2, function()
      loopTimer:stop()
    end)
  elseif textareaVisible() then
    -- fire it once
    focusTextarea()
  end
end


return module
