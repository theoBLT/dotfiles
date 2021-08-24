-- Converts "go/blah" to "<a href='http://go.corp.stripe.com/blah'>go/blah</a>" style link
local function makeRichGoLink(link)
  local suffix = hs.fnutils.split(link, "/", nil, true)[2]

  return hs.styledtext.getStyledTextFromData(
    "{\\field{\\*\\fldinst HYPERLINK \"http://go.corp.stripe.com/" .. suffix .. "\"}{\\fldrslt " .. link .. "}}",
    "rtf"
  )
end

local prefix = "=go/" -- this is really "+go/" but the keycode is technically "=" so...
local currentPrefixIndex = 1
local suffix = ""

goWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local keyPressed = hs.keycodes.map[event:getKeyCode()]

  if currentPrefixIndex <= prefix:len() then
    -- we want to increment our `currentPrefixIndex` pointer char-by-char until
    -- we detect that we've typed a prefix
    if keyPressed == prefix:sub(currentPrefixIndex, currentPrefixIndex) then
      currentPrefixIndex = currentPrefixIndex + 1
    else
      currentPrefixIndex = 1 -- reset back to 1, we didn't type the prefix
      suffix = ""
    end
  else
    if keyPressed == "space" then
      -- go link is typed in, time to convert it
      local numCharsToDeleteBack = #prefix + #suffix

      local richLink = makeRichGoLink("go/" .. suffix)
      local previousClipboardContents = hs.pasteboard.getContents()

      currentPrefixIndex = 1
      suffix = ""

      local changeCount = hs.pasteboard.changeCount()

      -- Put the link in the clipboard so it can write out the rich link.
      hs.pasteboard.writeObjects({
        richLink,
        trailingChar,
      })

      -- Wait for the clipboard to update with new contents, this can take
      -- ~100ms.
      hs.timer.waitUntil(
        function() return changeCount ~= hs.pasteboard.changeCount() end,
        function()
          -- Delete backwards over the typed +go/link
          for i = 1, numCharsToDeleteBack do
            hs.eventtap.keyStroke({}, 'delete', 0)
          end

          -- Paste
          hs.eventtap.keyStroke({'cmd'}, 'v', 0)

          hs.timer.doAfter(0.2, function()
            -- send the space key now
            hs.eventtap.keyStroke({}, 'space', 0)

            -- Restore the clipboard
            hs.pasteboard.setContents(previousClipboardContents)
          end)
        end
      )

      return true
    else
      -- keep track of what was typed
      suffix = suffix .. keyPressed
    end
  end

  return false
end)

goWatcher:start()
