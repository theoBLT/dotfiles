local function getCurrentWord()
  local systemElement = hs.axuielement.systemWideElement()
  local textBox = systemElement:attributeValue("AXFocusedUIElement")

  local text = textBox:attributeValue('AXValue')
  local cursorRange = textBox:attributeValue('AXSelectedTextRange')

  if not text or not cursorRange then
    return nil
  end

  local index = cursorRange.location
  local char = text:sub(index, index)
  local word = ""

  while char ~= " " and index > 0 do
    word = char .. word

    index = index - 1
    char = text:sub(index, index)
  end

  return word
end

return {
  getCurrentWord = getCurrentWord,
}
