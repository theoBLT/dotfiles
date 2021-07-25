local function get_window_under_mouse()
  -- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it
  -- and breaks itself
  local _ = hs.application

  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()

  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

drag_types = {
  move = 1,
  resize = 2,
}

dragging_win = nil
drag_type = nil

drag_event = hs.eventtap.new(
  {
    hs.eventtap.event.types.leftMouseDragged,
    hs.eventtap.event.types.rightMouseDragged,
  },
  function(event)
    if not dragging_win then return nil end

    local mouse = hs.mouse:getButtons()
    if not mouse.left then return nil end

    local dx = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
    local dy = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)

    if drag_type == drag_types.move then
      dragging_win:move({dx, dy}, nil, false, 0)
    elseif drag_type == drag_types.resize then
      local sz = dragging_win:size()
      local w1 = sz.w + dx
      local h1 = sz.h + dy

      dragging_win:setSize(w1, h1)
      -- local topLeft = dragging_win:topLeft()
      -- dragging_win:setFrame(hs.geometry.new(topLeft.x, topLeft.y, w1, h1), 0)
    end
  end
)

flag_event = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
  local flags = event:getFlags()

  if flags.cmd and flags.shift then
    dragging_win = get_window_under_mouse()
    drag_type = drag_types.move
    drag_event:start()
  elseif flags.ctrl and flags.shift then
    dragging_win = get_window_under_mouse()
    drag_type = drag_types.resize
    drag_event:start()
  else
    draggin_win = nil
    drag_type = nil
    drag_event:stop()
  end
end)

flag_event:start()

