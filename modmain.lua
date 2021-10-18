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
-- Replaces every character's description dialogue for big Woby with "Woby mukbang"
local function WobyMukbang()
	local str = "Woby mukbang"
	debug_print("[Woby Mukbang] Changing character dialogues")
	for character, _ in pairs(GLOBAL.STRINGS.CHARACTERS) do
		debug_print("[Woby Mukbang] Character \"%s\"", tostring(character))
		GLOBAL.STRINGS.CHARACTERS[character].DESCRIBE.WOBYBIG = { str }
	end
end

-- Parses this mod's config options and returns a list of story names that need to be registered
local function GetStoriesToRegister()
	local wpp_stories = {}

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
				-- Add the story name and directory to `wpp_stories`
				local modded_name = remove_prefix(option_name, MODDED_STORY_PREFIX):upper()
				debug_print("[Config] Adding modded story: \"%s\" (%s)", option_name, modded_name)
				table.insert(wpp_stories, {
					name = modded_name,
					dir = MODDED_STORY_DIRECTORY
				})
			end

			if has_prefix(option_name, OTHER_STORY_PREFIX) and option_value == true then
				-- Add the story name and directory to `wpp_stories`
				local modded_name = remove_prefix(option_name, OTHER_STORY_PREFIX):upper()
				debug_print("[Config] Adding modded story: \"%s\" (%s)", option_name, modded_name)
				table.insert(wpp_stories, {
					name = modded_name,
					dir = OTHER_STORY_DIRECTORY
				})
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
	
	return wpp_stories
end

-- Finds the lua file associated with each story in `stories` and registers it
local function RegisterStories(stories)
	debug_print("[Stories] Adding modded stories to registry")
	for _, story in ipairs(stories) do
		-- Load the story and split it into lines
		debug_print("[Stories] Loading story \"%s\" (%s)", story.name, STORY_DIRECTORY..story.dir)
		local story_text = GLOBAL.require(STORY_DIRECTORY..story.dir) -- :gsub("([.,:;?!]) ", "%1\n")
		local story_lines = split(story_text, "\n")

		-- Load the story's line durations and text into `story`
		debug_print("[Stories] Parsing story")
		local story_formatted = {}
		for index, line in ipairs(story_lines) do
			story_formatted[index] = {
				duration = get_line_duration(line),
				line = line,
			}
		end

		-- Register the story
		debug_print("[Stories] Registering story")
		GLOBAL.STRINGS.STORYTELLER.WALTER.CAMPFIRE[story.name] = { lines = story_formatted }
	end
end

local function StoryTellerPostInit(storyteller)
	function storyteller:SetStoryToTellFn(fn)
		local function StoryToTellFn(inst, story_prop)
			if not GLOBAL.TheWorld.state.isnight then
				return "NOT_NIGHT"
			end
		
			local fueled = story_prop ~= nil and story_prop.components.fueled or nil
			if fueled ~= nil and story_prop:HasTag("campfire") then
				if fueled:IsEmpty() then
					return "NO_FIRE"
				end
		
				local campfire_stories = GLOBAL.STRINGS.STORYTELLER.WALTER["CAMPFIRE"]
				if campfire_stories ~= nil then
					if inst._story_proxy ~= nil then
						inst._story_proxy:Remove()
						inst._story_proxy = nil
					end
					inst._story_proxy = GLOBAL.SpawnPrefab("walter_campfire_story_proxy")
					inst._story_proxy:Setup(inst, story_prop)
		
					if self.laststory and self.lastline then
						print("[Walter++] [Story] Resuming story "..tostring(self.laststory.id))
						return {
							style = "CAMPFIRE",
							id = self.laststory.id,
							lines = {
								{ line="Where was I, again?", duration=3 },
								{ line="Oh, I remember", duration=2.5 },
								GLOBAL.unpack(self.laststory.lines, self.lastline)
							},
						}
					end

					local story_id = GLOBAL.GetRandomKey(campfire_stories)
					print("[Walter++] [Story] Starting story "..tostring(story_id))
					self.laststory = nil
					self.lastline = nil
					return {
						style = "CAMPFIRE",
						id = story_id,
						lines = campfire_stories[story_id].lines,
					}
				end
			end
		
			return nil
		end

		self.storytotellfn = StoryToTellFn
	end

	function storyteller:SetOnStoryOverFn(fn)
		local function StoryTellingDone(inst, story)
			if inst._story_proxy ~= nil and inst._story_proxy:IsValid() then
				inst._story_proxy:Remove()
				inst._story_proxy = nil
			end

			if story ~= nil then
				print("[Walter++] [Story] Ending story "..tostring(story.id))
			end
		end

		self.onstoryoverfn = StoryTellingDone
	end

	function storyteller:AbortStory(reason)
		print("[Walter++] [Story] Story aborted for reason: "..tostring(reason))

		if self.inst.components.talker ~= nil then
			self.laststory = self.story
			self.lastline = self.inst.components.talker.currentline
			print("[Walter++] [Story] Aborting story \""..tostring(self.laststory.id).."\" at line "..tostring(self.lastline))

			if reason then
				self.inst.components.talker:Say(reason)
			else
				self.inst.components.talker:ShutUp()
			end
		else
			self:OnDone()
		end
	end
end

local function TalkerPostInit(talker)
	if talker.inst:HasTag("player") then return end
	
	print("[Walter++] [Talker] HasTag player")
	print("[Walter++] [Talker] Prefab: "..tostring(talker.inst.prefab))
	
	local FollowText = require "widgets/followtext"
	
	local function sayfn(self, script, nobroadcast, colour)
		self.currentline = nil
		
		local player = GLOBAL.ThePlayer
		if (not self.disablefollowtext) and self.widget == nil and player ~= nil and player.HUD ~= nil then
			self.widget = player.HUD:AddChild(FollowText(self.font or GLOBAL.TALKINGFONT, self.fontsize or 35))
			self.widget:SetHUD(player.HUD.inst)
		end
		
		if self.widget ~= nil then
			self.widget.symbol = self.symbol
			self.widget:SetOffset(self.offset_fn ~= nil and self.offset_fn(self.inst) or self.offset or GLOBAL.DEFAULT_OFFSET)
			self.widget:SetTarget(self.inst)
			if colour ~= nil then
				self.widget.text:SetColour(GLOBAL.unpack(colour))
			elseif self.colour ~= nil then
				self.widget.text:SetColour(self.colour.x, self.colour.y, self.colour.z, 1)
			end
		end
		
		for i, line in ipairs(script) do
			print("[Walter++] [Talker] Saying line "..tostring(i)..": "..tostring(line.message))
			self.currentline = i
			
			local duration = math.min(line.duration or self.lineduration or TUNING.DEFAULT_TALKER_DURATION, TUNING.MAX_TALKER_DURATION)
			if line.message ~= nil then
				local display_message = GLOBAL.GetSpecialCharacterPostProcess(
					self.inst.prefab,
					self.mod_str_fn ~= nil and self.mod_str_fn(line.message) or line.message
				)
				
				if not nobroadcast then
					GLOBAL.TheNet:Talker(line.message, self.inst.entity, duration ~= TUNING.DEFAULT_TALKER_DURATION and duration or nil)
				end
				
				if self.widget ~= nil then
					self.widget.text:SetString(display_message)
				end
				
				if self.ontalkfn ~= nil then
					self.ontalkfn(self.inst, { noanim = line.noanim, message=display_message })
				end
				
				self.inst:PushEvent("ontalk", { noanim = line.noanim })
			elseif self.widget ~= nil then
				self.widget:Hide()
			end
			GLOBAL.Sleep(duration)
			if not self.inst:IsValid() or (self.widget ~= nil and not self.widget.inst:IsValid()) then
				return
			end
		end
		
		self.currentline = nil
		
		if self.widget ~= nil then
			self.widget:Kill()
			self.widget = nil
		end
		
		if self.donetalkingfn ~= nil then
			self.donetalkingfn(self.inst)
		end
		
		self.inst:PushEvent("donetalking")
		self.task = nil
	end
	
	local function CancelSay(self)
		if self.widget ~= nil then
			self.widget:Kill()
			self.widget = nil
		end
		
		if self.task ~= nil then
			GLOBAL.scheduler:KillTask(self.task)
			self.task = nil
			
			if self.donetalkingfn ~= nil then
				self.donetalkingfn(self.inst)
			end
			
			self.inst:PushEvent("donetalking")
		end
	end
	
	function talker:Say(script, time, noanim, force, nobroadcast, colour)
		print("[Walter++] [Talker] Say")
		if GLOBAL.TheWorld.speechdisabled then return nil end
		if GLOBAL.TheWorld.ismastersim then
			if not force
			and (self.ignoring ~= nil or
			(self.inst.components.health ~= nil and self.inst.components.health:IsDead() and self.inst.components.revivablecorpse == nil) or
			(self.inst.components.sleeper ~= nil and self.inst.components.sleeper:IsAsleep())) then
				return
			elseif self.ontalk ~= nil then
				self.ontalk(self.inst, script)
			end
		elseif not force then
			if self.inst:HasTag("ignoretalking") then
				return
			elseif self.inst.components.revivablecorpse == nil then
				local health = self.inst.replica.health
				if health ~= nil and health:IsDead() then
					return
				end
			end
		end
		
		CancelSay(self)
		local lines = type(script) == "string" and { GLOBAL.Line(script, noanim, time) } or script
		if lines ~= nil then
			self.task = self.inst:StartThread(function() sayfn(self, lines, nobroadcast, colour) end)
		end
	end
end



-- MAIN FUNCTION
local function script()
	if GetModConfigData("woby_mukbang") == true then
		WobyMukbang()
	end
	
	AddComponentPostInit("storyteller", StoryTellerPostInit)
	AddComponentPostInit("talker", TalkerPostInit)

	local wpp_stories = GetStoriesToRegister()
	RegisterStories(wpp_stories)
end

debug_print("[Init] Running script")
script()