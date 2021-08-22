local function isZoomMuted()
  local script = [[
    property btnTitle : "Mute audio"

    if application "zoom.us" is running then
      tell application "System Events"
        tell application process "zoom.us"
          if exists (menu item btnTitle of menu 1 of menu bar item "Meeting" of menu bar 1) then
            set returnValue to "Unmuted"
          else
            set returnValue to "Muted"
          end if
        end tell
      end tell
    else
      set returnValue to ""
    end if

    return returnValue
  ]]

  local _, value = hs.osascript.applescript(script)

  return value == "Muted"
end

local function rgba(r, g, b, a)
  a = a or 1.0

  return {
    red = r / 255,
    green = g / 255,
    blue = b / 255,
    alpha = a
  }
end

local MuteStatus = {}

function MuteStatus:new()
  local status = {
    indexes = {
      background = 1,
      icon = 2,
      muteText = 3,
      horizontalLine = 4,
      verticalLine = 5,
      toggleHotkeyText = 6,
      hideHotkeyText = 7,
    }
  }

  setmetatable(status, self)
  self.__index = self

  status.canvas = hs.canvas.new({ x = 930, y = 500, w = 225, h = 136 })
  status.canvas:level("overlay")

  status.canvas:insertElement(
    {
      type = 'rectangle',
      action = 'fill',
      roundedRectRadii = { xRadius = 10, yRadius = 10 },
      fillColor = rgba(0, 0, 0, 0.65),
      withShadow = true,
      shadow = {
        blurRadius = 5.0,
        color = { alpha = 1/3 },
        offset = { h = -2.0, w = 2.0 },
      }
    },
    status.indexes.background
  )

  status.canvas:insertElement(
    {
      type = 'image',
      action = 'fill',
      image = hs.image.imageFromPath(os.getenv('HOME') .. '/.hammerspoon/zoom/volume-off.png'),
      frame = {
        x = (status.canvas:size().w / 2) - 32,
        y = 4,
        w = 64,
        h = 64,
      },
    },
    status.indexes.icon
  )

  status.canvas:insertElement(
    {
      type = 'text',
      action = 'fill',
      text = "Muted",
      textAlignment = "center",
      textColor = rgba(255, 255, 255, 1.0),
      textFont = "Helvetica Bold",
      textSize = 14,
      frame = {
        x = (status.canvas:size().w / 2) - 32,
        y = 64,
        w = 64,
        h = 20,
      },
    },
    status.indexes.muteText
  )

  status.canvas:insertElement(
    {
      type = 'rectangle',
      action = 'fill',
      fillColor = rgba(255, 255, 255, 0.5),
      frame = {
        x = 0,
        y = 94,
        w = "100%",
        h = 1,
      },
    },
    status.indexes.horizontalLine
  )

  status.canvas:insertElement(
    {
      type = 'rectangle',
      action = 'fill',
      fillColor = rgba(255, 255, 255, 0.5),
      frame = {
        x = status.canvas:size().w / 2,
        y = 95,
        w = 1,
        h = status.canvas:size().h - 95,
      },
    },
    status.indexes.verticalLine
  )

  status.canvas:insertElement(
    {
      type = 'text',
      action = 'fill',
      text = "Toggle\n⌘⇧⌥⌃ M",
      textAlignment = "center",
      textColor = rgba(255, 255, 255, 0.9),
      textFont = "Helvetica Bold",
      textSize = 12,
      frame = {
        x = 0,
        y = 100,
        w = status.canvas:size().w / 2,
        h = status.canvas:size().h - 100,
      },
    },
    status.indexes.toggleHotkeyText
  )

  status.canvas:insertElement(
    {
      type = 'text',
      action = 'fill',
      text = "Hide\n⌘⇧⌥⌃ Z",
      textAlignment = "center",
      textColor = rgba(255, 255, 255, 0.9),
      textFont = "Helvetica Bold",
      textSize = 12,
      frame = {
        x = status.canvas:size().w / 2,
        y = 100,
        w = status.canvas:size().w / 2,
        h = status.canvas:size().h - 100,
      },
    },
    status.indexes.hideHotkeyText
  )

  return status
end

function MuteStatus:setMuted(muted)
  if muted then
    self.canvas:elementAttribute(
      self.indexes.icon,
      'image',
      hs.image.imageFromPath(os.getenv('HOME') .. '/.hammerspoon/zoom/volume-off.png')
    )

    self.canvas:elementAttribute(self.indexes.muteText, 'text', 'Muted')

    self.canvas:elementAttribute(
      self.indexes.muteText,
      'textColor',
      rgba(255, 255, 255, 1.0)
    )
  else
    self.canvas:elementAttribute(
      self.indexes.icon,
      'image',
      hs.image.imageFromPath(os.getenv('HOME') .. '/.hammerspoon/zoom/volume-on.png')
    )

    self.canvas:elementAttribute(self.indexes.muteText, 'text', 'Unmuted')

    self.canvas:elementAttribute(
      self.indexes.muteText,
      'textColor',
      rgba(255, 165, 0, 1.0)
    )
  end
end

function MuteStatus:show()
  self.canvas:show()
end

function MuteStatus:hide()
  self.canvas:hide()
end

muteStatus = MuteStatus:new()
-- muteStatus:show()
-- muteStatus:setMuted(false)
