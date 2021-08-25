ReadLater = {}

ReadLater.menu = hs.menubar.new()
ReadLater.menu:setIcon(hs.image.imageFromPath(os.getenv('HOME') .. '/.hammerspoon/read-later/book.png'))
ReadLater.menu:setTitle("(0)")

ReadLater.articles = {}

local saveCurrentTabArticle = nil
local updateMenu = nil

--- sync functions
ReadLater.jsonSyncPath = os.getenv('HOME') .. "/Dropbox/read-later.json"

local function readArticlesFromDisk()
  local file = io.open(ReadLater.jsonSyncPath, 'r')

  if file then
    local contents = file:read("*all")
    file:close()

    ReadLater.articles = hs.json.decode(contents) or {}
    updateMenu()
  end
end

local function writeArticlesToDisk()
  hs.json.write(ReadLater.articles, ReadLater.jsonSyncPath, true, true)
end

--- read/remove functions

local function openUrl(url)
  local task = hs.task.new(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    nil,
    function() end, -- noop
    {
      url
    }
  )

  task:start()
end

local function readArticle(article)
  openUrl(article.url)
  removeArticle(article)
end

local function readRandomArticle()
  local index = math.random(1, #ReadLater.articles)
  readArticle(ReadLater.articles[index])
end

local function removeArticle(article)
  ReadLater.articles = hs.fnutils.filter(ReadLater.articles, function(savedArticle)
    return savedArticle.url ~= article.url
  end)

  updateMenu()
  writeArticlesToDisk()
end

--- menu code

updateMenu = function()
  local items = {
    {
      title = "ReadLater",
      disabled = true
    },
  }

  -- Add a divider line
  table.insert(items, { title = "-" })

  if #ReadLater.articles == 0 then
    table.insert(items, {
      title = "No more articles to read",
      disabled = true
    })
  else
    for _, article in ipairs(ReadLater.articles) do
      table.insert(items, {
        title = article.title,
        fn = function()
          readArticle(article)
        end,
        menu = {
          {
            title = "Remove article",
            fn = function()
              removeArticle(article)
            end,
          },
        }
      })
    end
  end

  table.insert(items, { title = "-" })
  table.insert(items, {
    title = "Save current tab          (⌘⌥⌃ S)",
    fn = function()
      saveCurrentTabArticle()
    end,
  })

  table.insert(items, {
    title = "Read random article",
    fn = readRandomArticle,
  })

  ReadLater.menu:setMenu(items)
  ReadLater.menu:setTitle("(" .. tostring(#ReadLater.articles) .. ")")
end

local function getCurrentArticle()
  if not hs.application.find('Google Chrome') then
    -- Chrome isn't running right now.
    return nil
  end

  local _, title = hs.osascript.applescript(
    [[
      tell application "Google Chrome"
        get title of active tab of first window
      end tell
    ]]
  )

  -- Remove trailing garbage from window title
  title = string.gsub(title, "- - Google Chrome.*", "")

  local _, url = hs.osascript.applescript(
    [[
      tell application "Google Chrome"
        get URL of active tab of first window
      end tell
    ]]
  )

  return {
    url = url,
    title = title,
  }
end

saveCurrentTabArticle = function()
  article = getCurrentArticle()

  if not article then
    return
  end

  table.insert(ReadLater.articles, article)

  writeArticlesToDisk()
  updateMenu()

  hs.alert("Saved " .. title)
end

superKey:bind('s'):toFunction('Read later', saveCurrentTabArticle)

----

updateMenu()
readArticlesFromDisk()
