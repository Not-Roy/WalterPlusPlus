name = "Walter++"
author = "Sam"
description = [[
This mod makes several improvements to Walter.
]]
version = "0.1.0"
forumthread = ""

dst_compatible = true
dont_starve_compatible = false
forge_compatible = false
gorge_compatible = false

client_only_mod = false
all_clients_require_mod = true

icon_atlas = nil
icon = nil

api_version_dst = 10
priority = 0
mod_dependencies = {}
server_filter_tags = {}

local function config_label(label, hover)
	return {
		name = "",
		label = label,
		hover = hover ~= nil and hover or "",
		options = {
			{ description = "", data = 0},
		},
		default = 0,
	}
end

local function config_toggle(options)
	return {
		name = options.name,
		label = options.label,
		hover = options.hover ~= nil and options.hover or "",
		options = {
			{ description = "Disabled", data = false },
			{ description = "Enabled", data = true },
		},
		default = options.default ~= nil and options.default or true,
	}
end

configuration_options = {
	config_label(
		"Miscellaneous Options"
	),
	config_toggle({
		name = "woby_mukbang",
		label = "Woby Mukbang",
		hover = "Replaces every character's voice line for inspecting Big Woby to \"Woby mukbang\"",
		default = true
	}),

	config_label(
		"Vanilla Stories",
		"Stories already present in the base game"
	),
	-- Vanilla story names must begin with `story_vanilla_`,
	-- followed by the name of the story as listed in STRINGS.STORYTELLER.WALTER.CAMPFIRE
	config_toggle({
		name = "story_vanilla_bog_monster",
		label = "Bog Monster",
		hover = "Ever heard of the bog monster?",
		default = true
	}),
	config_toggle({
		name = "story_vanilla_clocks",
		label = "Clocks",
		hover = "Alright, so there's this guy...",
		default = true
	}),
	
	config_label(
		"Walter++ Stories",
		"Stories added by this mod"
	),
	-- Walter++ story names must begin with `story_wpp_`,
	-- followed by the name of the lua file containing the story in `WalterPlusPlus/scripts/stories/wpp/` (don't include the .lua extension)
	config_toggle({
		name = "story_wpp_clones",
		label = "Clones",
		hover = "Clones, Clones, EVERYWHERE.",
		default = true
	}),
	config_toggle({
		name = "story_wpp_wendigo",
		label = "The Wendigo",
		hover = "They say the Wendigo was a lost hunter who turned to cannibalism during an exceedingly cold Winter",
		default = true
	}),
	config_toggle({
		name = "story_wpp_rickroll",
		label = "Rickroll",
		hover = "Never Gonna Give You Up",
		default = true
	}),



	-- config_label(
	-- 	"Custom Stories",
	-- 	"Custom stories added to this mod by someone else"
	-- ),
	-- -- Custom story names must begin with `story_other_`,
	-- -- followed by the name of the lua file containing the story in `WalterPlusPlus/scripts/stories/other/` (don't include the .lua extension)
	-- config_toggle({
	-- 	name = "story_other_yourstory",
	-- 	label = "Your Story",
	-- 	hover = "You can put a description of the story here",
	-- 	default = true, -- Change this to `false` if you want the story to be Disabled by default
	-- }),
}