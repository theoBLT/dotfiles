local function readFile(path)
  local file = io.open(path, 'r')
  local contents = file:read("*all")
  file:close()

  return contents
end

local function buildTrie(words)
  local trie = {}
  local lines = hs.fnutils.split(words, "\n", nil, false)

  for _, word in ipairs(lines) do
    local currentElement = trie

    -- Loop through each character in the snippet keyword and insert a tree
    -- of nodes into the trie.
    for i = 1, #word do
      local char = word:sub(i, i)

      currentElement[char] = currentElement[char] or {}
      currentElement = currentElement[char]

      -- If we're on the last character, save off the word to the node as well.
      local isLastChar = i == #word

      if isLastChar then
        currentElement.word = word
      end
    end
  end

  return trie
end

wordsTrie = buildTrie(readFile(os.getenv('HOME') .. '/.hammerspoon/autocomplete/words.txt'))

local function recursiveWordFind(node)
  local results = {}

  for key, child in pairs(node) do
    if key == "word" then
      table.insert(results, child)
    else
      results = hs.fnutils.concat(results, recursiveWordFind(child))
    end
  end

  return results
end

local function findQuery(node, search)
  local currentNode = node

  for i = 1, #search do
    local char = search:sub(i, i)
    currentNode = currentNode[char] or {}
  end

  return recursiveWordFind(currentNode)
end

local function getSortedResults(searchQuery)
  results = findQuery(wordsTrie, searchQuery)

  table.sort(results, function(a, b)
    return #a < #b
  end)

  return results
end

return getSortedResults
