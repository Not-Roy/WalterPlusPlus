-- CONSTANTS

local STORY_DIRECTORY = "./stories/"

local STORY_PREFIX = "story_"
local MODDED_STORY_PREFIX = STORY_PREFIX.."wpp_"
local VANILLA_STORY_PREFIX = STORY_PREFIX.."vanilla_"

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

-- HIGH LEVEL FUNCTIONS

-- Parses this mod's config options and returns a list of story names that need to be registered
local function GetStoryNamesToRegister()
	local wpp_story_names = {}

	debug_print("[Config] Parsing config options")
	for _, option in pairs(GLOBAL.KnownModIndex:GetModInfo(modname).configuration_options) do
		if has_prefix(option.name, STORY_PREFIX) then
			local option_value = GetModConfigData(option.name)
			debug_print("[Config] Config option: \"%s\" (%s)", option.name, tostring(option_value))

			-- If this is a modded story and it is enabled
			if has_prefix(option.name, MODDED_STORY_PREFIX) and option_value == true then
				-- Add the story name to `wpp_story_names`
				local modded_name = remove_prefix(option.name, MODDED_STORY_PREFIX):upper()
				debug_print("[Config] Adding modded story: \"%s\" (%s)", option.name, modded_name)
				table.insert(wpp_story_names, modded_name)
			end

			-- If this is a vanilla story and it is disabled
			if has_prefix(option.name, VANILLA_STORY_PREFIX) and option_value == false then
				-- Remove the story from the global story index
				local vanilla_name = remove_prefix(option.name, VANILLA_STORY_PREFIX):upper()
				debug_print("[Config] Removing vanilla story: \"%s\" (%s)", option.name, vanilla_name)
				GLOBAL.STRINGS.STORYTELLER.WALTER.CAMPFIRE[vanilla_name] = nil
			end
		end
	end
	
	return wpp_story_names
end

-- MAIN FUNCTION

local function script()
	local wpp_story_names = GetStoryNamesToRegister()
end

debug_print("[Init] Running script")
script()
