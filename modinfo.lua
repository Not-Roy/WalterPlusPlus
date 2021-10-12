name = "Walter++"
author = "Sam"
description = [[
This mod makes several improvements to Walter.
]]
version = "0.1.0"
dst_compatible = true
dont_starve_compatible = false
client_only_mod = false
all_clients_require_mod = true
forge_compatible = false
gorge_compatible = false
icon_atlas = nil
icon = nil
forumthread = ""
api_version_dst = 10
priority = 0
mod_dependencies = {}
server_filter_tags = {}
configuration_options = {
	{
		name = "",
		label = "Miscellaneous Options:",
		hover = "",
		options = {
			{ description = "", data = 0},
		},
		default = 0,
	},
	{
		name = "",
		label = "Vanilla Stories:",
		hover = "Stories already present in the base game",
		options = {
			{ description = "", data = 0},
		},
		default = 0,
	},
	-- Vanilla story names must begin with `story_vanilla_`,
	-- followed by the name of the story as listed in STRINGS.STORYTELLER.WALTER.CAMPFIRE
	{
		name = "",
		label = "Walter++ Stories:",
		hover = "Stories added by this mod",
		options = {
			{ description = "", data = 0},
		},
		default = 0,
	},
	-- Walter++ story names must begin with `story_wpp_`,
	-- followed by the name of the lua file containing the story in `WalterPlusPlus/scripts/stories/wpp/` (don't include the .lua extension)


	
	-- {
	-- 	name = "",
	-- 	label = "Custom Stories:",
	-- 	hover = "Custom stories added to this mod by someone else",
	-- 	options = {
	-- 		{ description = "", data = 0},
	-- 	},
	-- 	default = 0,
	-- },
	-- -- Custom story names must begin with `story_other_`,
	-- -- followed by the name of the lua file containing the story in `WalterPlusPlus/scripts/stories/other/` (don't include the .lua extension)
	-- {
	-- 	name = "story_other_yourstory",
	-- 	label = "Your Story",
	-- 	hover = "You can put the first line of the story here, or just a description",
	-- 	options = {
	-- 		{ description = "Disabled", data = false },
	-- 		{ description = "Enabled", data = true },
	-- 	},
	-- 	default = true, -- Change this to `false` if you want the default to be Disabled
	-- },
}