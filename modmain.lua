-- CONSTANTS

local STORY_DIRECTORY = "./stories/"
local MODDED_STORY_DIRECTORY = "wpp/"
local OTHER_STORY_DIRECTORY = "other/"

local STORY_PREFIX = "story_"
local MODDED_STORY_PREFIX = "wpp_"
local VANILLA_STORY_PREFIX = "vanilla_"
local OTHER_STORY_PREFIX = "other_"

-- HELPER FUNCTIONS

-- Effectively printf() but with a "[Walter++]" prefix on the output
local function debug_print(message, ...)
	print(string.format("[Walter++] "..tostring(message), ...))
end

-- Checks if `str` starts with `prefix`
local function has_prefix(str, prefix)
	return str:sub(1, #prefix) == prefix
end

-- Assumes that `str` starts with `prefix`.
-- Removes `prefix` from the beginning of `str`
local function remove_prefix(str, prefix)
	return tostring(str:sub(string.len(prefix) + 1))
end

-- Splits `str` at every instance of `delimiter`, returns the resulting array
local function split(str, delimiter)
	local result = {}

	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end

	return result
end

-- Returns the duration that `line` should be spoken for, in seconds.
-- Used when registering a story for Walter that is only text
local function get_line_duration(line)
	return math.floor(0.5 + 2 * (0.04423210518 * (#line) + 1.202100937)) / 2
end


-- HIGH LEVEL FUNCTIONS

-- Parses this mod's config options and returns a list of story names that need to be registered
local function GetStoryNamesToRegister()
	local wpp_story_names = {}

	-- Loop over the config options
	debug_print("[Config] Parsing config options")
	for _, option in pairs(GLOBAL.KnownModIndex:GetModInfo(modname).configuration_options) do
		-- If this option refers to a story
		if has_prefix(option.name, STORY_PREFIX) then
			local option_name = remove_prefix(option.name, STORY_PREFIX)
			local option_value = GetModConfigData(option_name)
			debug_print("[Config] Config option: \"%s\" (%s)", option_name, tostring(option_value))

			-- If this is a modded story and it is enabled
			if has_prefix(option_name, MODDED_STORY_PREFIX) and option_value == true then
				-- Add the story name to `wpp_story_names`
				local modded_name = remove_prefix(option_name, MODDED_STORY_PREFIX):upper()
				debug_print("[Config] Adding modded story: \"%s\" (%s)", option_name, modded_name)
				table.insert(wpp_story_names, modded_name)
			end

			-- If this is a vanilla story and it is disabled
			if has_prefix(option_name, VANILLA_STORY_PREFIX) and option_value == false then
				-- Unregister the story
				local vanilla_name = remove_prefix(option_name, VANILLA_STORY_PREFIX):upper()
				debug_print("[Config] Removing vanilla story: \"%s\" (%s)", option_name, vanilla_name)
				GLOBAL.STRINGS.STORYTELLER.WALTER.CAMPFIRE[vanilla_name] = nil
			end
		end
	end
	
	return wpp_story_names
end

-- Finds the lua file associated with each story in `stories` and registers it
local function RegisterStories(stories)
	debug_print("[Stories] Adding modded stories to registry")
	for _, story_name in ipairs(stories) do
		-- Load the story and split it into lines
		debug_print("[Stories] Loading story \"%s\" (%s)", story_name, STORY_DIRECTORY..story_name:lower())
		local story_text = GLOBAL.require(STORY_DIRECTORY..string.lower(story_name)) -- :gsub("([.,:;?!]) ", "%1\n")
		local story_lines = split(story_text, "\n")

		-- Load the story's line durations and text into `story`
		debug_print("[Stories] Parsing story")
		local story = {}
		for index, line in ipairs(story_lines) do
			story[index] = {
				duration = get_line_duration(line),
				line = line,
			}
		end

		-- Register the story
		debug_print("[Stories] Registering story")
		GLOBAL.STRINGS.STORYTELLER.WALTER.CAMPFIRE[story_name] = { lines = story }
	end
end

-- MAIN FUNCTION

local function script()
	local wpp_story_names = GetStoryNamesToRegister()
	RegisterStories(wpp_story_names)
end

debug_print("[Init] Running script")
script()
