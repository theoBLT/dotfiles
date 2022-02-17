-- wtf this file
-- if you copy a block of code to your clipboard
-- you can paste it into Google Docs with the hotkey all the way below
-- it will prompt you what language to format as (select Plain Text for no format)
--
-- and this will format it as a 2x1 table with line numbers on the left column
-- and the code, syntax highlighted, on the right column
-- then paste it into gdocs
-- then restore your clipboard
--
-- phew

local header = [[
{\rtf1\ansi\ansicpg1252\cocoartf2636
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 RobotoMono-Regular;}
{\colortbl;\red255\green255\blue255;\red33\green118\blue199;\red180\green187\blue194;\red251\green251\blue251;
\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c14902\c54510\c82353;\cssrgb\c75686\c78039\c80392;\cssrgb\c98824\c98824\c98824;
\cssrgb\c0\c0\c0;}
\margl1440\margr1440\vieww20180\viewh8400\viewkind0
\deftab720

\itap1\trowd \taflags1 \trgaph108\trleft-108 \trbrdrt\brdrnil \trbrdrl\brdrnil \trbrdrt\brdrnil \trbrdrr\brdrnil
\clvertalt \clshdrawnil \clwWidth640\clftsWidth3 \clbrdrt\brdrs\brdrw20\brdrcf3 \clbrdrl\brdrs\brdrw20\brdrcf3 \clbrdrb\brdrs\brdrw20\brdrcf3 \clbrdrr\brdrs\brdrw20\brdrcf4 \clpadt133 \clpadl133 \clpadb133 \clpadr133 \gaph\cellx4320
\clvertalt \clcbpat4 \clwWidth19420\clftsWidth3 \clbrdrt\brdrs\brdrw20\brdrcf3 \clbrdrl\brdrs\brdrw20\brdrcf4 \clbrdrb\brdrs\brdrw20\brdrcf3 \clbrdrr\brdrs\brdrw20\brdrcf3 \clpadt133 \clpadl133 \clpadb133 \clpadr133 \gaph\cellx10640
\pard\intbl\itap1\pardeftab720\qr\partightenfactor0

\f0\fs32 \cf2 \expnd0\expndtw0\kerning0

]]

local middle = [[
\cell
\pard\intbl\itap1\pardeftab720\partightenfactor0

]]

local footer = [[

\cell \lastrow\row
}
]]

-- \f0\fs32 \cf0 MARS
-- \f1\fs24 \

-- \f0\fs32 JUPITER
-- \f1\fs24

local function trim(s)
  return s:gsub("%s+$", "")
end

local function generateLineNumbers(code)
  local lines = hs.fnutils.split(code, "\n", nil, true)
  local count = #lines

  local numbers = {
    -- line 1
    [[\outl0\strokewidth0 \strokec2 1
\f0\fs24 \cf0 \strokec5 \]]
  }

  for i=2,count do
    local value = tostring(i)

    if i < count then
      value = value .. "\\par"
    end

    table.insert(
      numbers,
      [[\f0\fs32 \cf2 \strokec2 ]] .. value
    )
  end

  return table.concat(numbers, "\n\n")
end

local function pasteToGdocs(language)
  -- Get code from clipboard
  local code = trim(hs.pasteboard.getContents())

  -- Write to tmp file
  local file = io.open("/tmp/code.txt", "w+")
  io.output(file)
  io.write(code)
  io.close(file)

  -- Get code highlighted as RTF
  local codeRtf = hs.execute("cat /tmp/code.txt | /usr/local/bin/highlight --no-trailing-nl -O rtf --font 'Roboto Mono' --font-size 16 --syntax " .. language .. " -s 'solarized-light'")

  local rtf = header ..
    generateLineNumbers(code) ..
    middle ..
    codeRtf ..
    footer

  -- Convert to styled text
  local newClipboardContents = hs.styledtext.getStyledTextFromData(rtf, 'rtf')

  local changeCount = hs.pasteboard.changeCount()

  clipboardHasUpdated = function()
    return changeCount ~= hs.pasteboard.changeCount()
  end

  hs.pasteboard.writeObjects(newClipboardContents)

  hs.timer.waitUntil(
    clipboardHasUpdated,
    function()
      -- Fire a paste
      hs.eventtap.keyStroke({'cmd'}, 'v', 0)

      -- We need to wait to give a chance for the paste to finish.
      hs.timer.doAfter(1, function()
        -- Restore the clipboard
        hs.pasteboard.setContents(code)
      end)
    end,
    0.1
  )
end

local function runPaste()
  local onChoose = function(choice)
    if not choice then
      return
    end

    pasteToGdocs(choice.language)
  end

  local chooser = hs.chooser.new(onChoose)
  chooser:width(20)
  chooser:placeholderText("Choose a format language to paste as")

  chooser:choices({
    {
      text = "Bash",
      language = "bash",
    },
    {
      text = "Java",
      language = "java",
    },
    {
      text = "JavaScript",
      language = "js",
    },
    {
      text = "JSON",
      language = "json",
    },
    {
      text = "JSX",
      language = "jsx",
    },
    {
      text = "Lua",
      language = "lua",
    },
    {
      text = "Plain text (txt)",
      language = "txt",
    },
    {
      text = "Python",
      language = "python",
    },
    {
      text = "Ruby",
      language = "ruby",
    },
    {
      text = "Scala",
      language = "scala",
    },
    {
      text = "TSX",
      language = "tsx",
    },
    {
      text = "TypeScript",
      language = "tsx",
    },
    {
      text = "YAML",
      language = "yaml",
    },
  })

  chooser:show()
end


hs.hotkey.bind(super, 'g', runPaste)
