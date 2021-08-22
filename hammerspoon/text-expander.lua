local snippets = {
  ["=email"] = "d@balatero.com",
  ["=meet"] = "https://zoom.us/12345678",
  ["=date"] = function()
    return os.date("%B %d, %Y", os.time())
  end
}

local function buildTrie(snippets)
  local trie = {}

  for shortcode, snippet in pairs(snippets) do
    local currentElement = trie

    for i = 1, (#shortcode - 1) do
      local char = shortcode:sub(i, i)
      currentElement[char] = currentElement[char] or {}

      currentElement = currentElement[char]
    end

    local lastChar = shortcode:sub(#shortcode, #shortcode)

    if type(snippet) == "function" then
      currentElement[lastChar] = snippet
    else
      currentElement[lastChar] = function()
        return snippet
      end
    end
  end

  return trie
end

local snippetTrie = buildTrie(snippets)
local numPresses = 0
local currentTrieNode = snippetTrie

snippetWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local keyPressed = hs.keycodes.map[event:getKeyCode()]
  local shouldFireSnippet = keyPressed == "return" or keyPressed == "space"

  local reset = function()
    currentTrieNode = snippetTrie
    numPresses = 0
  end

  if type(currentTrieNode) == "function" then
    if shouldFireSnippet then
      for i = 1, numPresses do
        hs.eventtap.keyStroke({}, 'delete', 0)
      end

      local textToWrite = currentTrieNode()
      hs.eventtap.keyStrokes(textToWrite)

      hs.eventtap.keyStroke(event:getFlags(), keyPressed, 0)

      reset()
      return true
    else
      reset()
      return false
    end
  end

  if currentTrieNode[keyPressed] then
    currentTrieNode = currentTrieNode[keyPressed]
    numPresses = numPresses + 1
  else
    reset()
  end

  return false
end)

snippetWatcher:start()
