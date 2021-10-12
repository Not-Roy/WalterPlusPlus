-- CONSTANTS

local STORY_DIRECTORY = "./stories/"

-- HELPER FUNCTIONS

-- Effectively printf() but with a "[Walter++]" prefix on the output
local function debug_print(message, ...)
	print(string.format("[Walter++] "..tostring(message), ...))
end

-- HIGH LEVEL FUNCTIONS



-- MAIN FUNCTION

local function script()

end

debug_print("[Init] Running script")
script()
