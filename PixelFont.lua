-- This is a template for a custom code extension for the Ironmon Tracker.
-- To use, first rename both this top-most function and the return value at the bottom: "CodeExtensionTemplate" -> "YourFileNameHere"
-- Then fill in each function you want to use with the code you want executed during Tracker runtime.
-- The name, author, and description attribute fields are used by the Tracker to identify this extension, please always include them.
-- You can safely remove unused functions; they won't be called.

local function PixelFont()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {}
	self.version = "1.4"
	self.name = "PixelFont"
	self.author = "Leopardly"
	self.description = "A font rendering replacement, using a handdrawn pixel font. Built for Linux users with font issues :)"
	self.github = "Leopardly/PixelFontExtension" -- Replace "MyUsername" and "ExtensionRepo" to match your GitHub repo url, if any
	self.url = string.format("https://github.com/%s", self.github or "") -- Remove this attribute if no host website available for this extension

	function self.checkForUpdates()
		-- Update the pattern below to match your version. You can check what this looks like by visiting the latest release url on your repo
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github or "")
		local downloadUrl = string.format("%s/releases/latest", self.url or "")
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	function self.startup()
		self.oldRef1 = Drawing.drawText
    self.oldRef2 = Utils.getMovesLearnedHeader
    Drawing.drawText = self.replaceDrawingText
    Utils.getMovesLearnedHeader = self.replaceUtilSpacing
	end 

	function self.unload()
		Drawing.drawText = self.oldRef1
    Utils.getMovesLearnedHeader = self.oldRef2
	end

  function self.replaceDrawingText(x, y, text, color, shadowcolor, size, family, style)
    if Utils.isNilOrEmpty(text) then return end
    --Font size 5 is only used for + and - on Natures so simply check text and draw approprite glyph
    if size == 5 then
        if string.find(text, "+") then
            Drawing.drawImageAsPixels({{0,1,0},{1,1,1},{0,1,0}},x, y, color, nil)
        end
        if string.find(text,"-") then
            Drawing.drawImageAsPixels({{1,1,1}},x, y+1, color, nil)
        end
        return
    end
    --HEADERS just print regular size but shuffled in and down a bit
    if size == 15 then
        x = x+3
        y = y+3
    end
    --Actual printing
    local xoffset = 0
    local yoffset = 0
    for c in tostring(text):gmatch(utf8.charpattern) do
      if c == utf8.char(10) then --check for \n and create new lines if found
        yoffset = yoffset + 1
        xoffset = 0
      else
        Drawing.drawImageAsPixels(self.PixelFont[c],x+xoffset+1,y+2,color,nil)
        xoffset = xoffset + Constants.charWidth(c) + 1
      end
    end
  end

  --Trying to simply call the old method and amend was not working correct
  --so I have reverted this. And now just replicate the logic, seems stable after revert
  function self.replaceUtilSpacing(pokemonID, level)
      if not PokemonData.isValid(pokemonID) or level == nil then
          return Resources.TrackerScreen.HeaderMoves, nil, nil
      end

      local movesLearned = 0
      local nextMoveLevel = 0
      local foundNextMove = false

      local allMoveLevels = PokemonData.Pokemon[pokemonID].movelvls[GameSettings.versiongroup]
      for _, lv in pairs(allMoveLevels) do
          if lv <= level then
              movesLearned = movesLearned + 1
          elseif not foundNextMove then
              nextMoveLevel = lv
              foundNextMove = true
          end
      end

      local movesText = Resources.TrackerScreen.HeaderMoves
      -- Don't show the asterisk on your own Pokemon
      if not Battle.isViewingOwn and #Tracker.getMoves(pokemonID) > 4 then
          movesText = movesText .. "*"
      end

      local header = string.format("%s %s/%s", movesText, movesLearned, #allMoveLevels)
      if foundNextMove then
          header = header .. " ("
          local nextMoveSpacing = Utils.calcWordPixelLength(header)
          header = header .. nextMoveLevel .. ")"
          return header, nextMoveLevel, (nextMoveSpacing+1)
      else
          return header, nil, nil
      end
  end

-- This is the font glyphs
  self.PixelFont = {
    [" "] = {
      {0,},
    },
    ["%"] = {
      {0,1,0,0,0,0,0,},
      {1,0,1,0,0,1,0,},
      {0,1,0,0,1,0,0,},
      {0,0,0,1,0,0,0,},
      {0,0,1,0,0,1,0,},
      {0,1,0,0,1,0,1,},
      {0,0,0,0,0,1,0,},
      },
    ["0"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
      },
    ["1"] = {
      {0,1,1,0,},
      {1,0,1,0,},
      {0,0,1,0,},
      {0,0,1,0,},
      {0,0,1,0,},
      {0,0,1,0,},
      {1,1,1,1,},
      },
    ["2"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {0,0,0,1,},
      {0,0,1,0,},
      {0,1,0,0,},
      {1,0,0,0,},
      {1,1,1,1,},
      },
    ["3"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {0,0,0,1,},
      {0,1,1,0,},
      {0,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
      },
    ["4"] = {
      {0,0,0,1,},
      {0,0,1,1,},
      {0,1,0,1,},
      {1,0,0,1,},
      {1,1,1,1,},
      {0,0,0,1,},
      {0,0,0,1,},
    },
    ["5"] = {
      {1,1,1,1,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,1,1,0,},
      {0,0,0,1,},
      {0,0,0,1,},
      {1,1,1,0,},
    },
    ["6"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,0,},
      {1,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["7"] = {
      {1,1,1,1,},
      {0,0,0,1,},
      {0,0,0,1,},
      {0,0,1,0,},
      {0,0,1,0,},
      {0,1,0,0,},
      {0,1,0,0,},
    },
    ["8"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["9"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,1,},
      {0,0,0,1,},
      {0,0,0,1,},
      {0,1,1,0,},
    },
    ["="] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {0,0,0,0,},
      {1,1,1,1,},
      {0,0,0,0,},
      {1,1,1,1,},
      {0,0,0,0,},
    },
    [","] = { --one taller
      {0,0,},
      {0,0,},
      {0,0,},
      {0,0,},
      {0,0,},
      {0,1,},
      {0,1,},
      {1,0,},
    },
    ["-"] = {
      {0,0,},
      {0,0,},
      {0,0,},
      {1,1,},
      {0,0,},
      {0,0,},
      {0,0,},
    },
    ["'"] = {
      {0,},
      {1,},
      {1,},
      {0,},
      {0,},
      {0,},
      {0,},
    },
    ["+"] = {
      {0,0,0,0,0,},
      {0,0,1,0,0,},
      {0,0,1,0,0,},
      {1,1,1,1,1,},
      {0,0,1,0,0,},
      {0,0,1,0,0,},
      {0,0,0,0,0,},
    },
    ["_"] = {
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,1,1,1,0,},
    },
    ["."] = {
      {0,},
      {0,},
      {0,},
      {0,},
      {0,},
      {0,},
      {1,},
    },
    ["!"] = {
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
      {0,},
      {1,},
    },
    ["("] = {
      {0,1,},
      {1,0,},
      {1,0,},
      {1,0,},
      {1,0,},
      {1,0,},
      {0,1,},
    },
    [")"] = {
      {1,0,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {1,0,},
    },
    ["["] = {
      {1,1,},
      {1,0,},
      {1,0,},
      {1,0,},
      {1,0,},
      {1,0,},
      {1,1,},
    },
    ["]"] = {
      {1,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {1,1,},
    },
    ["#"] = {
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,1,0,1,0,},
      {1,1,1,1,1,},
      {0,1,0,1,0,},
      {1,1,1,1,1,},
      {0,1,0,1,0,},
    },
    ["&"] = {
      {0,0,1,0,0,},
      {0,1,0,1,0,},
      {0,1,0,1,0,},
      {0,1,1,0,0,},
      {1,0,1,0,1,},
      {1,0,0,1,0,},
      {0,1,1,0,1,},
    },
    ["?"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {0,0,0,1,},
      {0,0,1,0,},
      {0,1,0,0,},
      {0,0,0,0,},
      {0,1,0,0,},
    },
    ["<"] = {
      {0,0,0,1,},
      {0,0,1,0,},
      {0,1,0,0,},
      {1,0,0,0,},
      {0,1,0,0,},
      {0,0,1,0,},
      {0,0,0,1,},
    },
    [">"] = {
      {1,0,0,0,},
      {0,1,0,0,},
      {0,0,1,0,},
      {0,0,0,1,},
      {0,0,1,0,},
      {0,1,0,0,},
      {1,0,0,0,},
    },
    ["/"] = {
      {0,0,0,1,},
      {0,0,0,1,},
      {0,0,1,0,},
      {0,0,1,0,},
      {0,1,0,0,},
      {0,1,0,0,},
      {1,0,0,0,},
      {1,0,0,0,},
    },
    [":"] = {
      {0,},
      {0,},
      {0,},
      {1,},
      {0,},
      {1,},
      {0,},
    },
    ["~"] = {
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {0,1,0,0,1,},
      {1,0,1,1,0,},
      {0,0,0,0,0,},
      {0,0,0,0,0,},
    },
    ["a"] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {0,1,1,0,},
      {0,0,0,1,},
      {0,1,1,1,},
      {1,0,0,1,},
      {0,1,1,1,},
    },
    ["A"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,1,1,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
    },
    ["b"] = {
      {1,0,0,0,},
      {1,0,0,0,},
      {1,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,1,1,0,},
    },
    ["B"] = {
      {1,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,1,1,0,},
    },
    ["c"] = {
      {0,0,0,},
      {0,0,0,},
      {0,1,1,},
      {1,0,0,},
      {1,0,0,},
      {1,0,0,},
      {0,1,1,},
    },
    ["C"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["d"] = {
      {0,0,0,1,},
      {0,0,0,1,},
      {0,1,1,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,1,},
    },
    ["D"] = {
      {1,1,1,0,0,},
      {1,0,0,1,0,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,1,0,},
      {1,1,1,0,0,},
    },
    ["e"] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,1,1,1,},
      {1,0,0,0,},
      {0,1,1,1,},
    },
    ["E"] = {
      {1,1,1,1,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,1,1,0,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,1,1,1,},
    },
    ["f"] = {
      {0,1,},
      {1,0,},
      {1,0,},
      {1,1,},
      {1,0,},
      {1,0,},
      {1,0,},
    },
    ["F"] = {
      {1,1,1,1,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,1,1,0,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,0,0,0,},
    },
    ["g"] = { --2 longer
      {0,0,0,0,},
      {0,0,0,0,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,1,},
      {0,0,0,1,},
      {0,1,1,0,},
    },
    ["G"] = {
      {0,1,1,1,0,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,0,},
      {1,0,0,1,1,},
      {1,0,0,0,1,},
      {0,1,1,1,0,},
    },
    ["h"] = {
      {1,0,0,0,},
      {1,0,0,0,},
      {1,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
    },
    ["H"] = {
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,1,1,1,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
    },
    ["i"] = {
      {0,},
      {1,},
      {0,},
      {1,},
      {1,},
      {1,},
      {1,},
    },
    ["I"] = {
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
    },
    ["j"] = {
      {0,0,},
      {0,1,},
      {0,0,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {1,0,},
    },
    ["J"] = {
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {0,1,},
      {1,0,},
    },
    ["k"] = {
      {1,0,0,0,},
      {1,0,0,0,},
      {1,0,0,1,},
      {1,0,1,0,},
      {1,1,0,0,},
      {1,0,1,0,},
      {1,0,0,1,},
    },
    ["K"] = {
      {1,0,0,0,1,},
      {1,0,0,1,0,},
      {1,0,1,0,0,},
      {1,1,0,0,0,},
      {1,0,1,0,0,},
      {1,0,0,1,0,},
      {1,0,0,0,1,},
    },
    ["l"] = {
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
      {1,},
    },
    ["L"] = {
      {1,0,0,},
      {1,0,0,},
      {1,0,0,},
      {1,0,0,},
      {1,0,0,},
      {1,0,0,},
      {1,1,1,},
    },
    ["m"] = {
      {0,0,0,0,0,0,0,},
      {0,0,0,0,0,0,0,},
      {0,1,1,0,1,1,0,},
      {1,0,0,1,0,0,1,},
      {1,0,0,1,0,0,1,},
      {1,0,0,1,0,0,1,},
      {1,0,0,1,0,0,1,},
    },
    ["M"] = {
      {1,0,0,0,0,1,},
      {1,1,0,0,1,1,},
      {1,0,1,1,0,1,},
      {1,0,0,0,0,1,},
      {1,0,0,0,0,1,},
      {1,0,0,0,0,1,},
      {1,0,0,0,0,1,},
    },
    ["n"] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {1,0,1,0,},
      {1,1,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
    },
    ["N"] = {
      {1,0,0,0,1,},
      {1,1,0,0,1,},
      {1,1,0,0,1,},
      {1,0,1,0,1,},
      {1,0,1,0,1,},
      {1,0,0,1,1,},
      {1,0,0,1,1,},
    },
    ["o"] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["O"] = {
      {0,1,1,1,0,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {0,1,1,1,0,},
    },
    ["p"] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,1,1,0,},
      {1,0,0,0,},
      {1,0,0,0,},
    },
    ["P"] = {
      {1,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,1,1,0,},
      {1,0,0,0,},
      {1,0,0,0,},
      {1,0,0,0,},
    },
    ["q"] = {
      {0,0,0,},
      {0,0,0,},
      {0,1,0,},
      {1,0,1,},
      {1,0,1,},
      {1,0,1,},
      {0,1,1,},
      {0,0,1,},
      {0,0,1,},
    },
    ["Q"] = {
      {0,1,1,1,0,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,1,0,1,},
      {1,0,0,1,0,},
      {0,1,1,0,1,},
    },
    ["r"] = {
      {0,0,},
      {0,0,},
      {0,1,},
      {1,0,},
      {1,0,},
      {1,0,},
      {1,0,},
    },
    ["R"] = {
      {1,1,1,1,0,},
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {1,0,0,1,0,},
      {1,1,1,0,0,},
      {1,0,0,1,0,},
      {1,0,0,0,1,},
    },
    ["s"] = {
      {0,0,0,},
      {0,0,0,},
      {0,1,1,},
      {1,0,0,},
      {0,1,0,},
      {0,0,1,},
      {1,1,0,},
    },
    ["S"] = {
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,0,},
      {0,1,1,0,},
      {0,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["t"] = {
      {0,0,},
      {1,0,},
      {1,1,},
      {1,0,},
      {1,0,},
      {1,0,},
      {0,1,},
    },
    ["T"] = {
      {1,1,1,},
      {0,1,0,},
      {0,1,0,},
      {0,1,0,},
      {0,1,0,},
      {0,1,0,},
      {0,1,0,},
    },
    ["u"] = {
      {0,0,0,0,},
      {0,0,0,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["U"] = {
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
    },
    ["v"] = {
      {0,0,0,},
      {0,0,0,},
      {1,0,1,},
      {1,0,1,},
      {1,0,1,},
      {1,0,1,},
      {0,1,0,},
    },
    ["V"] = {
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
      {0,1,1,0,},
      {0,1,1,0,},
      {0,1,1,0,},
    },
    ["w"] = {
      {0,0,0,0,0,},
      {0,0,0,0,0,},
      {1,0,0,0,1,},
      {1,0,1,0,1,},
      {1,0,1,0,1,},
      {1,0,1,0,1,},
      {0,1,0,1,0,},
    },
    ["W"] = {
      {1,0,0,0,0,0,1,},
      {1,0,0,1,0,0,1,},
      {1,0,1,0,1,0,1,},
      {1,0,1,0,1,0,1,},
      {0,1,0,0,0,1,0,},
      {0,1,0,0,0,1,0,},
      {0,1,0,0,0,1,0,},
    },
    ["x"] = {
      {0,0,0,},
      {0,0,0,},
      {1,0,1,},
      {1,0,1,},
      {0,1,0,},
      {1,0,1,},
      {1,0,1,},
    },
    ["X"] = {
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,0,0,1,},
      {1,0,0,1,},
    },
    ["y"] = { --2 longer
      {0,0,0,},
      {0,0,0,},
      {1,0,1,},
      {1,0,1,},
      {1,0,1,},
      {1,0,1,},
      {0,1,1,},
      {0,0,1,},
      {0,1,1,},
    },
    ["Y"] = {
      {1,0,0,0,1,},
      {1,0,0,0,1,},
      {0,1,0,1,0,},
      {0,1,1,1,0,},
      {0,0,1,0,0,},
      {0,0,1,0,0,},
      {0,0,1,0,0,},
    },
    ["z"] = {
      {0,0,0,},
      {0,0,0,},
      {1,1,1,},
      {0,0,1,},
      {0,1,0,},
      {1,0,0,},
      {1,1,1,},
    },
    ["Z"] = {
      {1,1,1,1,},
      {0,0,0,1,},
      {0,0,1,1,},
      {0,1,1,0,},
      {1,1,0,0,},
      {1,0,0,0,},
      {1,1,1,1,},
    },
    ["é"] = {
      {0,0,1,0,},
      {0,1,0,0,},
      {0,1,1,0,},
      {1,0,0,1,},
      {1,1,1,1,},
      {1,0,0,0,},
      {0,1,1,1,},
    }
  }

	return self
end
return PixelFont