local utf8 = require('utf8')

-- Copies a rich link to your currently visible Chrome browser tab that you
-- can paste into Slack/anywhere else that supports it.
--
-- Link is basically formatted as:
--
--   <a href="http://the.url.com">Page title</a>
local function getRichLinkToCurrentChromeTab()
  local application = hs.application.frontmostApplication()

  -- only check chrome
  if application:bundleID() ~= "com.google.Chrome" then
    return
  end

  local script = [[
    tell application "Google Chrome"
      get title of active tab of first window
    end tell
  ]]

  local _, title = hs.osascript.applescript(script)

  -- remove trailing garbage from window title
  title = string.gsub(title, "- - Google Chrome.*", "")

  local encodedTitle = ""

  -- encode the title as html entities like (&#107;&#84;), so that we can
  -- print out unicode characters inside of `getStyledTextFromData`.
  for _, code in utf8.codes(title) do
    encodedTitle = encodedTitle .. "&#" .. code .. ";"
  end

  script = [[
    tell application "Google Chrome"
      get URL of active tab of first window
    end tell
  ]]

  local _, url = hs.osascript.applescript(script)
  local html = "<a href=\"" .. url .. "\">" .. encodedTitle .. "</a>"
  local styledText = hs.styledtext.getStyledTextFromData(html, "html")

  hs.pasteboard.writeObjects(styledText)

  hs.alert("Copied link to " .. title)
end

hyperKey:bind('g'):toFunction("Copy a link to current tab", getRichLinkToCurrentChromeTab)

