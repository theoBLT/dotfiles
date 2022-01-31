local utf8 = require('utf8')

-- Copies a rich link to your currently visible Chrome browser tab that you
-- can paste into Slack/anywhere else that supports it.
--
-- Link is basically formatted as:
--
--   <a href="http://the.url.com">Page title</a>
local function getRichLinkToCurrentChromeTab()
  local application = hs.application.frontmostApplication()

  -- Only copy from Chrome
  if application:bundleID() ~= "com.google.Chrome" then
    return
  end

  -- Grab the <title> from the page.
  local script = [[
    tell application "Google Chrome"
      get title of active tab of first window
    end tell
  ]]

  local _, title = hs.osascript.applescript(script)

  -- Remove trailing garbage from window title for a better looking link.
  local removePatterns = {
    " %- Jira",
    "- - Google Chrome.*",
    " – Dropbox Paper.*",
    " %- Google Docs",
    " %- Google Sheets",
    " – Figma",
  }

  for _, pattern in ipairs(removePatterns) do
    title = string.gsub(title, pattern, "")
  end

  -- Encode the title as html entities like (&#107;&#84;), so that we can
  -- print out unicode characters inside of `getStyledTextFromData` and have
  -- them render correctly in the link.
  local encodedTitle = ""

  for _, code in utf8.codes(title) do
    encodedTitle = encodedTitle .. "&#" .. code .. ";"
  end

  -- Get the current URL from the address bar.
  script = [[
    tell application "Google Chrome"
      get URL of active tab of first window
    end tell
  ]]

  local _, url = hs.osascript.applescript(script)

  -- Embed the URL + title in an <a> tag so macOS converts it to a rich link
  -- on paste.
  local html = "<a href=\"" .. url .. "\">" .. encodedTitle .. "</a>"

  -- Add fun emoji to the link depending on the source.
  -- 99 times 100 I'm pasting this to Slack.
  if url:find("paper.dropbox.com") then
    html = ":paper: " .. html
  elseif url:find("git.corp.stripe.com") then
    html = ":octocat: " .. html
  elseif url:find("docs.google.com/document") then
    html = ":google-docs: " .. html
  elseif url:find("docs.google.com/spreadsheets") then
    html = ":google-sheets: " .. html
  elseif url:find("jira.corp.stripe.com") then
    html = ":jira: " .. html
  elseif url:find("confluence.corp.stripe.com") then
    html = ":confluence: " .. html
  elseif url:find("figma.com") then
    html = ":figma-: " .. html
  end

  -- Insert the styled link into the clipboard
  local styledText = hs.styledtext.getStyledTextFromData(html, "html")
  hs.pasteboard.writeObjects(styledText)

  hs.alert("Copied link to \"" .. title .. "\"")
end

hyperKey:bind('g'):toFunction("Copy a link to current tab", getRichLinkToCurrentChromeTab)

