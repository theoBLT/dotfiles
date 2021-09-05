local State = {}

function State:new()
  local state = {
    results = {},
    word = "",
    visible = false,
    onChange = function() end
  }

  setmetatable(state, self)
  self.__index = self

  return state
end

function State:onChangeEvent(fn)
  self.onChange = fn
end

function State:setState(updates)
  updates = updates or {}

  state.results = updates.results or state.results
  state.word = updates.word or state.word
  state.visible = updates.visible ~= nil and updates.visible or state.visible

  self.onChange()
end
